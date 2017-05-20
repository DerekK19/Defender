//
//  HIDServiceAgent.swift
//  Mustang
//
//  Created by Derek Knight on 4/08/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import IOKit.hid
import Flogger

// from IOHIDDevicePlugIn.h
private let kIOHIDDeviceTypeID = CFUUIDGetConstantUUIDWithBytes(nil,
                                                                0x7d, 0xde, 0xec, 0xa8, 0xa7, 0xb4, 0x11, 0xda,
                                                                0x8a, 0x0e, 0x00, 0x14, 0x51, 0x97, 0x58, 0xef)

private let kIOHIDDeviceDeviceInterfaceID = CFUUIDGetConstantUUIDWithBytes(nil,
                                                                           0x47, 0x4b, 0xdc, 0x8e, 0x9f, 0x4a, 0x11, 0xda,
                                                                           0xb3, 0x66, 0x00, 0x0d, 0x93, 0x6d, 0x06, 0xd2 )

// interface UUIDs. Keep these in step with the interface type aliases below
let HIDDeviceUUID = kIOHIDDeviceDeviceInterfaceID

// type aliases for interfaces
typealias HIDDeviceType = UnsafeMutablePointer<UnsafeMutablePointer<IOHIDDeviceDeviceInterface>>

// type aliases for closures
typealias HIDDeviceBlockType = (_ device: IOHIDDevice?) -> Void

// Fender constants
private let FenderVendorId: Int = 0x1ed8

// Apple constants
private let AppleVendorId: Int = 0x05ac
private let iPhoneProductId: Int = 0x12a8

// ThingM constants
private let ThingMVendorId: Int = 0x27b8

// Device detection
private var notifyPort: IONotificationPortRef?
private var observer: UnsafeMutableRawPointer? = nil
private var runLoopSource: Unmanaged<CFRunLoopSource>!
private var portAddedIterator: io_iterator_t = 0
private var portInterestIterator: io_iterator_t = 0

internal protocol HIDServiceAgentDelegate {
    func HIDAgent(agent: HIDServiceAgent, didChangeSetting: [UInt8], length: Int)
}

internal class HIDServiceAgent: BaseServiceAgent, HIDServiceAgentProtocol {
    
    internal var delegate: HIDServiceAgentDelegate?
    
    private var managerRef: IOHIDManager!
    
    var deviceTimeout: Int64
    
    let reportSize = 64 //Device specific
    var report: UnsafeMutablePointer<UInt8>!
    var reportSemaphore: DispatchSemaphore
    var reportTimeout: Int64
    var reportResponse = [[UInt8]]()
    var reportExpect: Int?
    var reportTerminator: [UInt8]?
    
    // MARK: Constructors
    override init() {
        managerRef = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        deviceTimeout = Int64(3 * NSEC_PER_SEC)
        report = UnsafeMutablePointer<UInt8>.allocate(capacity: self.reportSize)
        reportSemaphore = DispatchSemaphore(value: 0)
        reportTimeout = Int64(4 * NSEC_PER_SEC)
        super.init()
        setupNotifications()
    }
    
    // MARK: - Internal behaviour
    internal func getDevices() -> [DLHIDDevice] {
        var rValue = [DLHIDDevice]()
        
        rValue.append(contentsOf: getAllDevicesWithVendorId(vendorId))
        return rValue
    }
    
    internal func getPresetsForDeviceWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, onSuccess: @escaping (_ data: [[UInt8]]?) -> (), onFail: () -> ()) {
        
        whenDeviceIsOpen(vendorId, productId: productId, locationId: locationId) { (device) in
            
            self.sendToDevice(device, data: [0xff, 0xc1], terminator: [0xff, 0x01]) { (response) in
                self.logDebug(" Got settings\n")
                onSuccess(response)
            }
        }
    }
    
    internal func getPresetForDeviceWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, data: [UInt8], onSuccess: @escaping (_ data: [[UInt8]]?) -> (), onFail: () -> ()) {
        
        whenDeviceIsOpen(vendorId, productId: productId, locationId: locationId) { (device) in
            
            self.sendToDevice(device, data: data, terminator: [0x1c, 0x01, 0x00, 0x00]) { (response) in
                self.logDebug(" Got preset\n")
                onSuccess(response)
            }
        }
    }
    
    internal func setPresetForDeviceWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, data: [[UInt8]], onSuccess: @escaping (_ data: [[UInt8]]?) -> (), onFail: () -> ()) {
        
        whenDeviceIsOpen(vendorId, productId: productId, locationId: locationId) { (device) in
            // This just saves the amp settings, not the effects, or the name
            self.sendToDevice(device, data: data, terminator: [0x00, 0x00, 0x1c, 0x00]) { (response) in
                self.logDebug(" Set preset\n")
                onSuccess(data)
            }
        }
    }
    
    internal func savePresetForDeviceWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, data: [UInt8], onSuccess: @escaping () -> (), onFail: () -> ()) {
        
        whenDeviceIsOpen(vendorId, productId: productId, locationId: locationId) { (device) in
            
            self.sendToDevice(device, data: data) { () in
                self.logDebug(" Save preset\n")
                onSuccess()
            }
        }
    }
    
    internal func confirmChangeWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, onSuccess: @escaping (_ data: [[UInt8]]?) -> (), onFail: () -> ()) {
        
        whenDeviceIsOpen(vendorId, productId: productId, locationId: locationId) { (device) in
            
            self.sendToDevice(device, data:[0x1c, 0x03], terminator: [0x00, 0x00, 0x1c, 0x00]) { (response) in
                self.logDebug(" Confirmed change\n")
                onSuccess(response)
            }
        }
    }
    
    // MARK: - Private behaviour
    fileprivate func whenDeviceIsOpen(_ vendorId: Int,
                                 productId: Int?,
                                 locationId: UInt32?,
                                 HIDDeviceBlock: @escaping HIDDeviceBlockType) {

        DispatchQueue.global().async {
            let deviceKey = StorageAgent.sharedInstance.addDevice(nil, vendor: vendorId, product: productId, location: locationId, initialised: false)
            if StorageAgent.sharedInstance.deviceInitialised(deviceKey) {
                if let device = StorageAgent.sharedInstance.deviceForDevice(deviceKey) {
                    HIDDeviceBlock(device)
                    return
                }
            }
            let semaphore = StorageAgent.sharedInstance.semaphoreForDevice(deviceKey)
            if case .timedOut = semaphore.wait(timeout: DispatchTime.now() + Double(self.deviceTimeout) / Double(NSEC_PER_SEC)) {
                NSLog("Timed out")
                HIDDeviceBlock(nil)
            } else {
                if let device = StorageAgent.sharedInstance.deviceForDevice(deviceKey) {
                    HIDDeviceBlock(device)
                }
            }
        }
    }
    
    // MARK: Notifications
    // The handler functions should not be private
    
    fileprivate func setupNotifications() {
        if let runLoop = CFRunLoopGetCurrent() {
            let deviceMatch = [kIOHIDVendorIDKey: vendorId]
            
            IOHIDManagerSetDeviceMatching(managerRef, deviceMatch as CFDictionary?)
            IOHIDManagerScheduleWithRunLoop(managerRef, runLoop, CFRunLoopMode.defaultMode.rawValue)
            IOHIDManagerOpen(managerRef, 0)
            
            let matchingCallback : IOHIDDeviceCallback = { inContext, inResult, inSender, inIOHIDDeviceRef in
                let this : HIDServiceAgent = unsafeBitCast(inContext, to: HIDServiceAgent.self)
                this.handleDeviceConnected(inResult, inSender: inSender!, inIOHIDDeviceRef: inIOHIDDeviceRef)
            }
            
            let removalCallback : IOHIDDeviceCallback = { inContext, inResult, inSender, inIOHIDDeviceRef in
                let this : HIDServiceAgent = unsafeBitCast(inContext, to: HIDServiceAgent.self)
                this.handleDeviceRemoved(inResult, inSender: inSender!, inIOHIDDeviceRef: inIOHIDDeviceRef)
            }
            
            IOHIDManagerRegisterDeviceMatchingCallback(managerRef, matchingCallback, unsafeBitCast(self, to: UnsafeMutableRawPointer.self))
            IOHIDManagerRegisterDeviceRemovalCallback(managerRef, removalCallback, unsafeBitCast(self, to: UnsafeMutableRawPointer.self))
        }
    }
    
    func handleDeviceConnected(_ inResult: IOReturn, inSender: UnsafeMutableRawPointer, inIOHIDDeviceRef: IOHIDDevice!) {
        
        var kr: kern_return_t = 0

        // It would be better to look up the report size and create a chunk of memory of that size
        let report = UnsafeMutablePointer<UInt8>.allocate(capacity: reportSize)
        let device = inIOHIDDeviceRef

        let vendorId: Int? = getPropertyForDevice(device, property: kIOHIDVendorIDKey as CFString!)
        let productId: Int? = getPropertyForDevice(device, property: kIOHIDProductIDKey as CFString!)
        let location: Int? = getPropertyForDevice(device, property: kIOHIDLocationIDKey as CFString!)
        let uint32Location: UInt32? = location != nil ? UInt32(location!) : nil
        let deviceKey = StorageAgent.sharedInstance.addDevice(device, vendor: vendorId, product: productId, location: uint32Location, initialised: false)
        StorageAgent.sharedInstance.updateDevice(deviceKey, device: device!)
        let inputCallback : IOHIDReportCallback = { inContext, inResult, inSender, type, reportId, report, reportLength in
            let this : HIDServiceAgent = unsafeBitCast(inContext, to: HIDServiceAgent.self)
            this.handleInputReport(inResult, inSender: inSender!, type: type, reportId: reportId, report: report, reportLength: reportLength)
        }
//        let valueCallback : IOHIDValueCallback = { inContext, inResult, inSender, value in
//            let this : HIDServiceAgent = unsafeBitCast(inContext, to: HIDServiceAgent.self)
//            this.handleValueReport(inResult, inSender: inSender!, value: value)
//        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: Mustang.deviceConnectedNotificationName), object: nil, userInfo: ["class": NSStringFromClass(type(of: self))])

        // Hook up input callback
        IOHIDDeviceRegisterInputReportCallback(device!, report, reportSize, inputCallback, unsafeBitCast(self, to: UnsafeMutableRawPointer.self))
//        IOHIDDeviceRegisterInputValueCallback(device!, valueCallback, unsafeBitCast(self, to: UnsafeMutableRawPointer.self))
        reportSemaphore = DispatchSemaphore(value: 0)
        
        self.sendToDevice(device, data: [0x00, 0xc3], expect: 1) { (data) in
            self.sendToDevice(device, data: [0x1a, 0x03], expect: 1) { (data) in
                kr = IOHIDDeviceOpen(device!, 0)
                self.logError("IOHIDDeviceOpen failed", kr: kr)
                if kr == kIOReturnSuccess {
                    self.logDebug(" Device OPENED\n")
                    let semaphore = StorageAgent.sharedInstance.semaphoreForDevice(deviceKey)
                    StorageAgent.sharedInstance.updateDevice(deviceKey, initialised: true)
                    semaphore.signal()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Mustang.deviceOpenedNotificationName), object: nil, userInfo: ["class": NSStringFromClass(type(of: self))])
                }
            }
        }
    }

    func handleDeviceRemoved(_ inResult: IOReturn, inSender: UnsafeMutableRawPointer, inIOHIDDeviceRef: IOHIDDevice!) {
        logDebug("Device removed")

        /* Doesn't make sense to close the device after it has been removed!
        var kr: kern_return_t = 0
         
        let device = inIOHIDDeviceRef
         
        kr = IOHIDDeviceClose(device, 0)
        self.logError("IOHIDDeviceClose failed", kr: kr)
        if kr == kIOReturnSuccess {
            logDebug("\n\n device CLOSED\n\n")
            NSNotificationCenter.defaultCenter().postNotificationName(Mustang.deviceClosedNotificationName, object: nil, userInfo: ["class": NSStringFromClass(self.dynamicType)])
        }
         */
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: Mustang.deviceDisconnectedNotificationName), object: nil, userInfo: ["class": NSStringFromClass(type(of: self))])
    }

    func handleInputReport(_ inResult: IOReturn, inSender: UnsafeMutableRawPointer, type: IOHIDReportType, reportId: UInt32, report: UnsafeMutablePointer<UInt8>, reportLength: CFIndex) {
        let message = Data(bytes: UnsafePointer<UInt8>(report), count: reportLength)
        var array = [UInt8](repeating: 0, count: reportLength)
        // copy bytes into array
        (message as NSData).getBytes(&array, length: reportLength * MemoryLayout<UInt8>.size)
        if reportExpect == nil && reportTerminator == nil {
            delegate?.HIDAgent(agent: self, didChangeSetting: array, length: Int(reportLength))
        } else {
            debugPrint("recv", bytes: array)
            reportResponse.append(array)
            if let expected = reportExpect {
                if reportResponse.count >= expected {
                    reportExpect = nil
                    reportSemaphore.signal()
                }
            }
            if let terminator = reportTerminator {
                if array.starts(with: terminator) {
                    reportTerminator = nil
                    reportSemaphore.signal()
                }
            }
        }
    }

    func handleValueReport(_ inResult: IOReturn, inSender: UnsafeMutableRawPointer, value: IOHIDValue) {
        debugPrint(value)
    }
    
    // MARK: Private functions
    
    fileprivate func getAllDevicesWithVendorId(_ vendorId: Int) -> [DLHIDDevice] {
        
        var rValue = [DLHIDDevice]()
        
        var kr: kern_return_t = 0
        
        let masterPort: mach_port_t = kIOMasterPortDefault
        
        let classesToMatch = IOServiceMatching(kIOHIDDeviceKey) as NSMutableDictionary
        classesToMatch[kIOHIDVendorIDKey] = vendorId
//        classesToMatch[kIOHIDProductIDKey] = productId ?? 0xff
        
        // the iterator that will contain the results of IOServiceGetMatchingServices
        var matchingServices: io_iterator_t = 0
        kr = IOServiceGetMatchingServices(masterPort, classesToMatch, &matchingServices)
        if kr != KERN_SUCCESS ||  matchingServices == 0 {
            logError("IOServiceGetMatchingServices failed", kr: kr)
            // There are no devices from this vendor connected by USB
            return rValue
        }
        var hidService: io_object_t
        repeat {
            hidService = IOIteratorNext(matchingServices)
            if (hidService != 0) {
                
                let deviceName = getDeviceNameForService(hidService)
                logVerbose("deviceName: \(deviceName ?? "Unknown")")
                
                if let devicePtr = getHIDDeviceForService(hidService) {
                    let thisVendorId: Int? = getPropertyForDevice(devicePtr, property: kIOHIDVendorIDKey as CFString!)
                    let productId: Int? = getPropertyForDevice(devicePtr, property: kIOHIDProductIDKey as CFString!)
                    let locationId: Int? = getPropertyForDevice(devicePtr, property: kIOHIDLocationIDKey as CFString!)
                    if let thisVendorId = thisVendorId, let productId = productId, let locationId = locationId {
                        let location = UInt32(locationId)
                        if thisVendorId == vendorId {
                            debugPrint(devicePtr)
                            let name: String? = getPropertyForDevice(devicePtr, property: kIOHIDProductKey as CFString!)
                            if let name = name {
                                let device = DLHIDDevice(withVendor: vendorId, product: productId, name: name, locationId: location)
                                rValue.append(device)
                            }
                        }
                    }
                }
            }
        } while hidService != 0
        return rValue
    }

    // MARK: Functions to get interfaces from UUIDs

    fileprivate func getHIDDeviceForService(_ hidService: io_object_t) -> HIDDeviceType? {
        return getInterfaceForService(hidService,
                                      clientId: kIOHIDDeviceTypeID!,
                                      interface: HIDDeviceUUID!,
                                      mustStart: false)
    }
    
    fileprivate func getInterfaceForService<T>(_ usbService: io_object_t, clientId: CFUUID, interface: CFUUID, mustStart: Bool) -> T? {
        var kr: kern_return_t = 0
        var res: HRESULT = 0
        var plugInPtr: UnsafeMutablePointer<UnsafeMutablePointer<IOCFPlugInInterface>?>? = nil
        var score: Int32 = 0
        
        // Create an intermediate plug-in
        kr = IOCreatePlugInInterfaceForService(usbService,
                                               clientId,
                                               kIOCFPlugInInterfaceID,
                                               &plugInPtr,
                                               &score)
        
        logError("IOCreatePlugInInterfaceForService returned", kr: kr)
        if kr != kIOReturnSuccess || plugInPtr == nil {
            return nil
        }
        
        let plugIn = plugInPtr?.pointee?.pointee
        logVerbose("Plugin: \(String(describing: plugIn))")
        logVerbose("score \(score)")
        
        if mustStart {
            let dict = Dictionary<String, AnyObject>()
            res = plugIn!.Start(plugInPtr, dict as CFDictionary?, usbService)
            logError("Start(2) returned", hr: res)
        }
        
        // Use the plugin interface to retrieve the interface
        let interfacePtr = UnsafeMutablePointer<T?>.allocate(capacity: 1)
        res = interfacePtr.withMemoryRebound(to: (LPVOID?).self, capacity: 1) { interfacePtr in
            let interfacePtrTemp: UnsafeMutablePointer<LPVOID?>? = interfacePtr
            return plugIn?.QueryInterface(plugInPtr,
                                          CFUUIDGetUUIDBytes(interface),
                                          interfacePtrTemp) ?? 0
        }
        
        if mustStart {
            res = (plugIn?.Stop(plugInPtr))!
            logError("Stop(2) returned", hr: res)
        }
        
        // Release the intermediate plug-in, we will be using the interface from now on
        _ = plugIn?.Release(plugInPtr)
        
        if res != 0 {
            logError("QueryInterface for 'interface' returned", hr: res)
            return nil
        }
        return interfacePtr.pointee
    }
    
    // MARK: Convenience functions to get service/device/interface properties
    fileprivate func getDeviceNameForService(_ usbService: io_service_t) -> String? {
        var kr: kern_return_t = 0
        let deviceNamePtr = UnsafeMutablePointer<io_name_t>.allocate(capacity: 1)
        defer {deviceNamePtr.deallocate(capacity: 1)}
        
        var deviceName: String?
        
        // Get the USB device's name.
        kr = IORegistryEntryGetName(usbService, UnsafeMutableRawPointer(deviceNamePtr).assumingMemoryBound(to: Int8.self))
        if kr != KERN_SUCCESS {
            deviceNamePtr.pointee.0 = 0
        }
        
        deviceName = String(cString: UnsafeRawPointer(deviceNamePtr).assumingMemoryBound(to: CChar.self))
        return deviceName
    }
    
    fileprivate func getPropertyForDevice<T>(_ devicePtr: HIDDeviceType, property: CFString!) -> T? {
        var kr: kern_return_t = 0
        let device = devicePtr.pointee.pointee
        let valuePtr = UnsafeMutablePointer<Unmanaged<CFTypeRef>?>.allocate(capacity: 1)
        defer {valuePtr.deallocate(capacity: 1)}
        let valuePtrTemp: UnsafeMutablePointer<Unmanaged<CFTypeRef>?>? = valuePtr
        kr = device.getProperty(devicePtr, property, valuePtrTemp)
        if kr != KERN_SUCCESS {
            logError("getProperty returned", kr: kr)
            return nil
        }
        
        let value: AnyObject? = valuePtr.pointee?.takeUnretainedValue()
        if let rValue = value as? T {
            return rValue
        }
        NSLog("getPropertyForDevice(\(property)) would return \(String(describing: value))")
        return value as? T
    }
    
    fileprivate func getPropertyForDevice<T>(_ device: IOHIDDevice?, property: CFString!) -> T? {
        if let device = device {
            let value = IOHIDDeviceGetProperty(device, property)
            
            if let rValue = value as? T {
                return rValue
            }
            NSLog("getPropertyForDevice(\(property)) would return \(value)")
            return value as? T
        }
        return nil
    }
    
    fileprivate func sendToDevice(_ device: IOHIDDevice?, data: [UInt8], onSent: @escaping ()-> ()) {
        var kr: kern_return_t = 0
        if (data.count > reportSize) {
            Flogger.log.error("output data too large for USB report")
            return
        }
        let reportId : CFIndex = 0
        if let device = device {
            var bytes = [UInt8](repeating: 0x00, count: self.reportSize)
            for i in 0..<data.count {
                bytes[i] = data[i]
            }
            let nsdata = Data(bytes: UnsafePointer<UInt8>(bytes), count: self.reportSize)
            debugPrint("send", bytes: bytes)
            self.reportResponse = [[UInt8]]()
            self.reportExpect = nil
            DispatchQueue.global().async {
                kr = IOHIDDeviceSetReport(device, kIOHIDReportTypeOutput, reportId, (nsdata as NSData).bytes.bindMemory(to: UInt8.self, capacity: nsdata.count), nsdata.count);
                self.logError("IOHIDDeviceSetReport returned", kr: kr)
                self.reportSemaphore = DispatchSemaphore(value: 0)
                onSent()
            }
        }
    }
    
    fileprivate func sendToDevice(_ device: IOHIDDevice?, data: [[UInt8]], terminator: [UInt8], onReplied: @escaping ()-> ()) {
        if let first = data.first {
            sendToDevice(device, data: first, terminator: terminator) { (response) in
                self.sendToDevice(device, data: Array(data.dropFirst()), terminator: terminator) {
                    onReplied()
                }
            }
        } else {
            onReplied()
        }
    }
    
    fileprivate func sendToDevice(_ device: IOHIDDevice?, data: [UInt8], expect: Int, onReplied: @escaping (_ response: [[UInt8]]?)-> ()) {
        var kr: kern_return_t = 0
        if (data.count > reportSize) {
            Flogger.log.error("output data too large for USB report")
            return
        }
        let reportId : CFIndex = 0
        if let device = device {
            var bytes = [UInt8](repeating: 0x00, count: self.reportSize)
            for i in 0..<data.count {
                bytes[i] = data[i]
            }
            let nsdata = Data(bytes: UnsafePointer<UInt8>(bytes), count: self.reportSize)
            debugPrint("send", bytes: bytes)
            self.reportResponse = [[UInt8]]()
            self.reportExpect = expect
            DispatchQueue.global().async {
                kr = IOHIDDeviceSetReport(device, kIOHIDReportTypeOutput, reportId, (nsdata as NSData).bytes.bindMemory(to: UInt8.self, capacity: nsdata.count), nsdata.count);
                self.logError("IOHIDDeviceSetReport returned", kr: kr)
                self.reportSemaphore = DispatchSemaphore(value: 0)
                if case .timedOut = self.reportSemaphore.wait(timeout: DispatchTime.now() + Double(self.reportTimeout) / Double(NSEC_PER_SEC)) {
                    NSLog("report timed out")
                    onReplied(nil)
                } else {
                    onReplied(self.reportResponse)
                }
            }
        }
    }
    
    fileprivate func sendToDevice(_ device: IOHIDDevice?, data: [UInt8], terminator: [UInt8], onReplied: @escaping (_ response: [[UInt8]]?)-> ()) {
        var kr: kern_return_t = 0
        if (data.count > reportSize) {
            Flogger.log.error("output data too large for USB report")
            return
        }
        let reportId : CFIndex = 0
        if let device = device {
            var bytes = [UInt8](repeating: 0x00, count: self.reportSize)
            for i in 0..<data.count {
                bytes[i] = data[i]
            }
            let nsdata = Data(bytes: UnsafePointer<UInt8>(bytes), count: self.reportSize)
            debugPrint("send", bytes: bytes)
            self.reportResponse = [[UInt8]]()
            self.reportTerminator = terminator
            DispatchQueue.global().async {
                kr = IOHIDDeviceSetReport(device, kIOHIDReportTypeOutput, reportId, (nsdata as NSData).bytes.bindMemory(to: UInt8.self, capacity: nsdata.count), nsdata.count);
                self.logError("IOHIDDeviceSetReport returned", kr: kr)
                self.reportSemaphore = DispatchSemaphore(value: 0)
                if case .timedOut = self.reportSemaphore.wait(timeout: DispatchTime.now() + Double(self.reportTimeout) / Double(NSEC_PER_SEC)) {
                    NSLog("report timed out")
                    onReplied(nil)
                } else {
                    onReplied(self.reportResponse)
                }
            }
        }
    }
    
    // MARK: Logging and debugging
    fileprivate func debugPrint(_ reason: String, bytes: [UInt8]) {
        if dataDebug {
            var text = "\(reason): <"
            var i = 0
            bytes.forEach { if i > 0 && i % 4 == 0 { text += " " }; text += "\(String(format: "%02x", $0))"; i += 1 }
            text += ">"
            Flogger.log.debug(text)
        }
    }
    
    fileprivate func debugPrint(_ devicePtr: HIDDeviceType) {
        let vendorId: Int? = getPropertyForDevice(devicePtr, property: kIOHIDVendorIDKey as CFString!)
        let productId: Int? = getPropertyForDevice(devicePtr, property: kIOHIDProductIDKey as CFString!)
        let version: Int? = getPropertyForDevice(devicePtr, property: kIOHIDVersionNumberKey as CFString!)
        let manufacturer: String? = getPropertyForDevice(devicePtr, property: kIOHIDManufacturerKey as CFString!)
        let product: String? = getPropertyForDevice(devicePtr, property: kIOHIDProductKey as CFString!)
        let serial: String? = getPropertyForDevice(devicePtr, property: kIOHIDSerialNumberKey as CFString!)
        let location: Int? = getPropertyForDevice(devicePtr, property: kIOHIDLocationIDKey as CFString!)
        let uniqueId: Int? = getPropertyForDevice(devicePtr, property: kIOHIDUniqueIDKey as CFString!)
        let transport: String? = getPropertyForDevice(devicePtr, property: kIOHIDTransportKey as CFString!)
        let maxInReport: Int? = getPropertyForDevice(devicePtr, property: kIOHIDMaxInputReportSizeKey as CFString!)
        let maxOutReport: Int? = getPropertyForDevice(devicePtr, property: kIOHIDMaxOutputReportSizeKey as CFString!)
        let maxFeatureReport: Int? = getPropertyForDevice(devicePtr, property: kIOHIDMaxFeatureReportSizeKey as CFString!)
        let reportInterval: Int? = getPropertyForDevice(devicePtr, property: kIOHIDReportIntervalKey as CFString!)
        
        var text = "HID device\n"
        text += " vendor: 0x\(vendorId != nil ? String(format: "%04x", vendorId!) : "Unknown")\n"
        text += " product Id: 0x\(productId != nil ? String(format: "%04x", productId!) : "Unknown")\n"
        text += " version 0x\(version != nil ? String(format: "%04x", version!) : "Unknown")\n"
        text += " unique Id: 0x\(uniqueId != nil ? String(format: "%04x", uniqueId!) : "Unknown")\n"
        text += " manufacturer: \(manufacturer != nil ? manufacturer! : "Unknown")\n"
        text += " product: \(product != nil ? product! : "Unknown")\n"
        text += " serial: \(serial != nil ? serial! : "Unknown")\n"
        text += " location: 0x\(location != nil ? String(format: "%04x", location!) : "Unknown")\n"
        text += " transport: \(transport != nil ? transport! : "Unknown")\n"
        text += " in report: \(maxInReport != nil ? String(format: "%d", maxInReport!) : "Unknown")\n"
        text += " out report: \(maxOutReport != nil ? String(format: "%d", maxOutReport!) : "Unknown")\n"
        text += " feature report: \(maxFeatureReport != nil ? String(format: "%d", maxFeatureReport!) : "Unknown")\n"
        text += " report interval: \(reportInterval != nil ? String(format: "%d", reportInterval!) : "Unknown")\n"
        logDebug(text)
    }
    
    fileprivate func descriptionForMessageType(_ messageType: natural_t) -> String {
        switch messageType {
        case kIOMessageServiceIsTerminated:
            return "kIOMessageServiceIsTerminated"
        case kIOMessageServiceIsSuspended:
            return "kIOMessageServiceIsSuspended"
        case kIOMessageServiceIsResumed:
            return "kIOMessageServiceIsResumed"
        case kIOMessageServiceIsRequestingClose:
            return "kIOMessageServiceIsRequestingClose"
        case kIOMessageServiceIsAttemptingOpen:
            return "kIOMessageServiceIsAttemptingOpen"
        case kIOMessageServiceWasClosed:
            return "kIOMessageServiceWasClosed"
        case kIOMessageServiceBusyStateChange:
            return "kIOMessageServiceBusyStateChange"
        case kIOMessageConsoleSecurityChange:
            return "kIOMessageConsoleSecurityChange"
        case kIOMessageServicePropertyChange:
            return "kIOMessageServicePropertyChange"
        case kIOMessageCanDevicePowerOff:
            return "kIOMessageCanDevicePowerOff"
        case kIOMessageDeviceWillPowerOff:
            return "kIOMessageDeviceWillPowerOff"
        case kIOMessageDeviceWillNotPowerOff:
            return "kIOMessageDeviceWillNotPowerOff"
        case kIOMessageDeviceHasPoweredOn:
            return "kIOMessageDeviceHasPoweredOn"
        case kIOMessageCopyClientID:
            return "kIOMessageCopyClientID"
        case kIOMessageSystemCapabilityChange:
            return "kIOMessageSystemCapabilityChange"
        case kIOMessageDeviceSignaledWakeup:
            return "kIOMessageDeviceSignaledWakeup"
        default:
            return "Unknown"
        }
    }
    
    fileprivate func debugPrint(_ value: IOHIDValue) {
        let len = IOHIDValueGetLength(value)
        let int = UInt8(IOHIDValueGetIntegerValue(value) & 0xff)
        let ele = IOHIDValueGetElement(value)
        let typ = IOHIDElementGetType(ele)
        let tim = IOHIDValueGetTimeStamp(value)
        let usa = IOHIDElementGetUsage(ele)
        let pag = IOHIDElementGetUsagePage(ele)
        let uni = IOHIDElementGetUnit(ele)
        var bytes = ""
        if len > 1 {
            let ptr = IOHIDValueGetBytePtr(value)
            let message = Data(bytes: UnsafePointer<UInt8>(ptr), count: len)
            bytes = ": <"
            var i = 0
            message.forEach { if i > 0 && i % 4 == 0 { bytes += " " }; bytes += "\(String(format: "%02x", $0))"; i += 1 }
            bytes += ">"
            //logDebug("value type: ele \(ele) usa \(usa) pag \(String(format: "%02x", pag)) uni \(uni) typ \(typ.rawValue), tim \(tim) len \(len) \(bytes)")
        } else {
            bytes = "\(int)"
            logDebug("value type: ele \(ele) usa \(usa) pag \(String(format: "%02x", pag)) uni \(uni) typ \(typ.rawValue), tim \(tim) len \(len) \(bytes)")
        }
    }
}

//
//  USBServiceAgent.swift
//  Mustang
//
//  Created by Derek Knight on 26/06/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import IOKit.usb.IOUSBUserClient
import IOKit.usb.IOUSBLib

// from usb.h
private func iokit_usb_msg(_ message: UInt32)->UInt32 {return(sys_iokit|sub_iokit_usb|message)}
private func iokit_usb_err(_ message: UInt32)->UInt32 {return(sys_iokit|sub_iokit_usb|message)}

private let kIOUSBMessageHubResetPort					= iokit_usb_msg(0x01)	// Hub will reset a particular port
private let kIOUSBMessageHubSuspendPort					= iokit_usb_msg(0x02)	// Hub will suspend a particular port
private let kIOUSBMessageHubResumePort					= iokit_usb_msg(0x03)	// Hub will resume a particular port
private let kIOUSBMessageHubIsDeviceConnected			= iokit_usb_msg(0x04)	// Hub inquires whether a particular port has a device connected or not
private let kIOUSBMessageHubIsPortEnabled				= iokit_usb_msg(0x05)	// Hub inquires whether a particular port is enabled or not
private let kIOUSBMessageHubReEnumeratePort				= iokit_usb_msg(0x06)	// Hub reenumerates the device attached to a particular port
private let kIOUSBMessagePortHasBeenReset				= iokit_usb_msg(0x0a)	// Device will indicate that the port it is attached to has been reset
private let kIOUSBMessagePortHasBeenResumed				= iokit_usb_msg(0x0b)	// Device will indicate that the port it is attached to has been resumed
private let kIOUSBMessageHubPortClearTT					= iokit_usb_msg(0x0c)	// Hub will clear the transaction translator
private let kIOUSBMessagePortHasBeenSuspended			= iokit_usb_msg(0x0d)	// Device will indicate that the port it is attached to has been suspended
private let kIOUSBMessageFromThirdParty					= iokit_usb_msg(0x0e)	// Third party.  Uses IOUSBThirdPartyParam to encode the sender's ID
private let kIOUSBMessagePortWasNotSuspended			= iokit_usb_msg(0x0f)	// Hub driver received a resume request for a port that was not suspended
private let kIOUSBMessageExpressCardCantWake			= iokit_usb_msg(0x10)	// Driver to a bus that an express card will disconnect on sleep and shouldn't wake
private let kIOUSBMessageCompositeDriverReconfigured    = iokit_usb_msg(0x11)	// Composite driver indicating that it has finished re-configuring the device after a reset
private let kIOUSBMessageHubSetPortRecoveryTime			= iokit_usb_msg(0x12)	// Hub will set the # of ms required when resuming a particular port
private let kIOUSBMessageOvercurrentCondition			= iokit_usb_msg(0x13)   // Clients of the device's hub parent, when a device causes an overcurrent condition.  The message argument contains the locationID of the device
private let kIOUSBMessageNotEnoughPower					= iokit_usb_msg(0x14)   // Clients of the device's hub parent, when a device causes an low power notice to be displayed.  The message argument contains the locationID of the device
private let kIOUSBMessageController						= iokit_usb_msg(0x15)	// Generic message sent from controller user client to controllers
private let	kIOUSBMessageRootHubWakeEvent				= iokit_usb_msg(0x16)	// HC Wakeup code indicating that a Root Hub port has a wake event
private let kIOUSBMessageReleaseExtraCurrent			= iokit_usb_msg(0x17)	// Clients using extra current to release it if possible
private let kIOUSBMessageReallocateExtraCurrent			= iokit_usb_msg(0x18)	// Clients using extra current to attempt to allocate it some more
private let kIOUSBMessageEndpointCountExceeded			= iokit_usb_msg(0x19)	// Device when endpoints cannot be created because the USB controller ran out of resources
private let kIOUSBMessageDeviceCountExceeded			= iokit_usb_msg(0x1a)	// Hub when a device cannot be enumerated because the USB controller ran out of resources
private let kIOUSBMessageHubPortDeviceDisconnected      = iokit_usb_msg(0x1b)	// Built-in hub when a device was disconnected
private let kIOUSBMessageUnsupportedConfiguration		= iokit_usb_msg(0x1c)   // Clients of the device when a device is not supported in the current configuration.  The message argument contains the locationID of the device
private let kIOUSBMessageHubCountExceeded               = iokit_usb_err(0x1d)   // A 6th hub was plugged in and was not enumerated, as the USB spec only support 5 hubs in a chain
private let kIOUSBMessageTDMLowBattery                  = iokit_usb_err(0x1e)   // An attached TDM system battery is running low.
private let kIOUSBMessageLegacySuspendDevice            = iokit_usb_err(0x1f)   // Legacy interfaces when SuspedDevice() is called
private let kIOUSBMessageLegacyResetDevice              = iokit_usb_err(0x20)   // Legacy interfaces when ResetDevice() is called
private let kIOUSBMessageLegacyReEnumerateDevice        = iokit_usb_err(0x21)   // Legacy interfaces when ReEnumerateDevice() is called

// from IOUSBLib.h
private let kIOUSBDeviceUserClientTypeID = CFUUIDGetConstantUUIDWithBytes(nil,
                                                                          0x9d, 0xc7, 0xb7, 0x80, 0x9e, 0xc0, 0x11, 0xD4,
                                                                          0xa5, 0x4f, 0x00, 0x0a, 0x27, 0x05, 0x28, 0x61)
private let kIOUSBDeviceInterfaceID = CFUUIDGetConstantUUIDWithBytes(nil,
                                                                     0x5c, 0x81, 0x87, 0xd0, 0x9e, 0xf3, 0x11, 0xD4,
                                                                     0x8b, 0x45, 0x00, 0x0a, 0x27, 0x05, 0x28, 0x61)
private let kIOUSBDeviceInterfaceID650 = CFUUIDGetConstantUUIDWithBytes(nil,
                                                                        0x4A, 0xAC, 0x1B, 0x2E, 0x24, 0xC2, 0x47, 0x6A,
                                                                        0x96, 0x4D, 0x91, 0x33, 0x35, 0x34, 0xF2, 0xCC)

private let kIOUSBInterfaceUserClientTypeID = CFUUIDGetConstantUUIDWithBytes(nil,
                                                                             0x2d, 0x97, 0x86, 0xc6, 0x9e, 0xf3, 0x11, 0xD4,
                                                                             0xad, 0x51, 0x00, 0x0a, 0x27, 0x05, 0x28, 0x61)
private let kIOUSBInterfaceInterfaceID = CFUUIDGetConstantUUIDWithBytes(nil,
                                                                        0x73, 0xc9, 0x7a, 0xe8, 0x9e, 0xf3, 0x11, 0xD4,
                                                                        0xb1, 0xd0, 0x00, 0x0a, 0x27, 0x05, 0x28, 0x61)

private let kIOUSBInterfaceInterfaceID700 = CFUUIDGetConstantUUIDWithBytes(nil,
                                                                           0x17, 0xF9, 0xE5, 0x9C, 0xB0, 0xA1, 0x40, 0x1D,
                                                                           0x9A, 0xC0, 0x8D, 0xE2, 0x7A, 0xC6, 0x04, 0x7E)

private let kIOUSBFindInterfaceDontCare: UInt16 = 0xFFFF

// interface UUIDs. Keep these in step with the interface type aliases below
let USBDeviceUUID = kIOUSBDeviceInterfaceID650
let USBInterfaceUUID = kIOUSBInterfaceInterfaceID700

// type aliases for interfaces
typealias USBDeviceType = UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface650>>
typealias USBInterfaceType = UnsafeMutablePointer<UnsafeMutablePointer<IOUSBInterfaceInterface700>>

// type aliases for closures
typealias USBDeviceBlockType = (_ device: USBDeviceType, _ deviceName: String?, _ productId: Int, _ locationId: UInt32?) -> AnyObject?
typealias InterfaceBlockType = (_ interface: USBInterfaceType, _ deviceName: String?, _ productId: Int?, _ locationId: UInt32?) -> AnyObject?

// Device detection
private var notifyPort: IONotificationPortRef?
private var observer: UnsafeMutableRawPointer? = nil
private var runLoopSource: Unmanaged<CFRunLoopSource>!
private var portAddedIterator: io_iterator_t = 0
private var portInterestIterator: io_iterator_t = 0

internal class USBServiceAgent: BaseServiceAgent, USBServiceAgentProtocol {
    
    var lastInterfaceService: io_object_t = 0
    var lastDeviceService: io_object_t = 0
    var lastDevice: USBDeviceType?
    var lastInterface: USBInterfaceType?
    var lastCompletion: ((_ opened: Bool) -> ())?
    
    // MARK: Constructors
    override init() {
        super.init()
        setupNotifications()
        startDetectingDevicesWithVendorId(vendorId)
    }

    // MARK: - Internal behaviour
    internal func getDevices() -> [DLUSBDevice] {
        var rValue = [DLUSBDevice]()
        rValue.append(contentsOf: getAllDevicesWithVendorId(vendorId))
        return rValue
    }
    
    internal func getInfoForDeviceWithId(_ locationId: UInt32) -> DLUSBDevice? {
        if let device = getOneDeviceWithVendorId(vendorId, locationId: locationId) {
            return device
        }
        return nil
    }
    
    // MARK: - Private behaviour
    // MARK: Notifications
    fileprivate func setupNotifications() {
        // To set up asynchronous notifications, create a notification port and
        // add its run loop event source to the program’s run loop
        if notifyPort == nil {
            notifyPort = IONotificationPortCreate(kIOMasterPortDefault)
            
            runLoopSource = IONotificationPortGetRunLoopSource(notifyPort!)
            CFRunLoopAddSource(CFRunLoopGetCurrent(),
                               runLoopSource.takeUnretainedValue(),
                               CFRunLoopMode.defaultMode)
            
            observer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        }
    }
    
    fileprivate func startDetectingDevicesWithVendorId(_ vendorId: Int) {
        var kr: kern_return_t = 0
        
        let matchingDict = IOServiceMatching(kIOUSBDeviceClassName) as NSMutableDictionary
        matchingDict[kUSBVendorID] = vendorId
        matchingDict[kUSBProductID] = "*"
        
        kr = IOServiceAddMatchingNotification(
            notifyPort!,
            kIOFirstMatchNotification,
            matchingDict,
            { (thisSelf, itt) in
                let thisclass = Unmanaged<USBServiceAgent>.fromOpaque(thisSelf!).takeUnretainedValue()
                thisclass.handleDeviceAdded(itt)
            },
            observer,
            &portAddedIterator)
        logError("IOServiceAddMatchingNotification failed", kr: kr)
        
        handleDeviceAdded(portAddedIterator)
    }
    
    fileprivate func detectGeneralInterestForDevice(_ device: USBDeviceType, service usbService: io_service_t) {
        var kr: kern_return_t = 0
        
        lastDevice = device
        lastDeviceService = usbService
        
        // Start a detector for usb events
        kr = IOServiceAddInterestNotification(
            notifyPort!,
            usbService,
            kIOGeneralInterest,
            { (refCon: UnsafeMutableRawPointer?, service: io_service_t, messageType: natural_t, messageArgument: UnsafeMutableRawPointer?) in
                if let refCon = refCon {
                    let thisclass = Unmanaged<USBServiceAgent>.fromOpaque(refCon).takeUnretainedValue()
                    thisclass.handleGeneralInterest(messageType, service: service, messageArgument: messageArgument)
                }
            },
            observer,
            &portInterestIterator)
        logError("IOServiceAddInterestNotification failed", kr: kr)
    }
    
    fileprivate func detectGeneralInterestForInterface(_ usbService: io_service_t) {
        var kr: kern_return_t = 0
        
        lastInterfaceService = usbService
        
        // Start a detector for usb events
        kr = IOServiceAddInterestNotification(
            notifyPort!,
            usbService,
            kIOGeneralInterest,
            { (refCon: UnsafeMutableRawPointer?, service: io_service_t, messageType: natural_t, messageArgument: UnsafeMutableRawPointer?) in
                if let refCon = refCon {
                    let thisclass = Unmanaged<USBServiceAgent>.fromOpaque(refCon).takeUnretainedValue()
                    thisclass.handleGeneralInterest(messageType, service: service, messageArgument: messageArgument)
                }
            },
            observer,
            &portInterestIterator)
        logError("IOServiceAddInterestNotification failed", kr: kr)
    }
    
    fileprivate func handleDeviceAdded(_ iterator: io_iterator_t) {
        let usbService = IOIteratorNext(iterator)
        if usbService != 0 {
            logDebug("USB - Something was added : \(usbService)")
            if let devicePtr = getDeviceForService(usbService, interface: USBDeviceUUID!) {
                let device = devicePtr.pointee.pointee
                logVerbose("Device \(device)")
                debugPrint(devicePtr)
                detectGeneralInterestForDevice(devicePtr, service: usbService)
            } else {
                NSLog("Some USB device, but not ours")
            }
        }
    }
    
    fileprivate func handleGeneralInterest(_ messageType: natural_t, service: io_service_t, messageArgument: UnsafeMutableRawPointer?) {
        
        switch messageType {
        case kIOMessageServiceIsTerminated:
            logDebug("USB - Something was removed : \(service) \(String(describing: messageArgument))")
            if service != 0 {
                logDebug("USB Device removed: \(service).")
                startDetectingDevicesWithVendorId(vendorId)
            }
        case kIOMessageServiceIsAttemptingOpen:
            logDebug("USB - Something will open - service:\(service) device:\(lastDeviceService) interface:\(lastInterfaceService)) \(String(describing: messageArgument))")
        case kIOMessageServiceWasClosed:
            logDebug("USB - Something did close - service:\(service) device:\(lastDeviceService) interface:\(lastInterfaceService)) \(String(describing: messageArgument))")
            var tryToOpenInterface = false
            if lastDeviceService == service {
                if let lastDevice = lastDevice {
                    logDebug("Closing the device")
                    self.closeDevice(lastDevice)
                    self.lastDeviceService = 0
                    self.lastDevice = nil
                    tryToOpenInterface = true
                }
            }
            if lastInterfaceService == service || tryToOpenInterface{
                if let lastInterface = lastInterface, let lastCompletion = lastCompletion {
                    logDebug("Attempting Open again \(lastInterfaceService) (\(String(describing: messageArgument)))")
                    if let success = self.openInterface(lastInterface) {
                        lastCompletion(success)
                    } else {
                        logDebug("Still not able to open the interface")
                        self.lastInterfaceService = 0
                        self.lastInterface = nil
                        self.lastCompletion = nil
                    }
                }
            }
        default:
            logVerbose("USB General interest: \(service) 0x\(String(format: "%08x", messageType)) (\(descriptionForMessageType(messageType)))")
        }
    }
    
    // MARK: Private functions
    
    fileprivate func getAllDevicesWithVendorId(_ vendorId: Int) -> [DLUSBDevice] {
        
        var rValue = [DLUSBDevice]()
        
        _ = executeOnDevice(vendorId, productId: nil, locationId: nil) { (name, productId, locationId, USBDevice, audio, interface) -> AnyObject? in
            
            self.debugPrint(name, USBDevice: USBDevice, interface: interface, audio: audio)
            
            if let name = name, let productId = productId, let locationId = locationId {
                let device = DLUSBDevice(withVendor: vendorId, product: productId, name: name, locationId: locationId)
                rValue.append(device)
                return device
            }
            return nil
        }
        return rValue
    }
    
    fileprivate func getOneDeviceWithVendorId(_ vendorId: Int, locationId: UInt32) -> DLUSBDevice? {
        let object = executeOnDevice(vendorId, productId: nil, locationId: locationId) { (name, productId, locationId, USBDevice, audio, interface) in
            
            self.debugPrint(name, USBDevice: USBDevice, interface: interface, audio: audio)
            
            if let name = name, let productId = productId, let locationId = locationId {
                return DLUSBDevice(withVendor: vendorId, product: productId, name: name, locationId: locationId)
            }
            return nil
        }
        if let rValue = object as? DLUSBDevice {
            return rValue
        }
        return nil
    }
    
    // MARK: General purpose executors
    fileprivate func executeOnDevice(_ vendorId: Int,
                                 productId: Int?,
                                 locationId: UInt32?,
                                 block: @escaping (_ deviceName: String?,
                                         _ productId: Int?,
                                         _ locationId: UInt32?,
                                         _ USBDevice: USBDeviceType?,
                                         _ audio: AnyObject?,
                                         _ interface: USBInterfaceType?) -> AnyObject?) -> AnyObject? {
        
        return executeOnDevice(vendorId,
                               productId: productId,
                               locationId: locationId,
                               interface: USBDeviceUUID!,
                               USBDeviceBlock: { (device, deviceName, productId, locationId) -> AnyObject? in
                                block(deviceName, productId, locationId, device, nil, nil) },
//                               audioBlock: { (audio, deviceName, productId, locationId) -> AnyObject? in
//                                block(deviceName: deviceName, productId: productId, locationId: locationId, USBDevice: nil, audio: audio, interface: nil)})
                               interfaceBlock: { (interface, deviceName, productId, locationId) -> AnyObject? in
                                block(deviceName, productId, locationId, nil, nil, interface)})
    }
    
    fileprivate func executeOnDevice(_ vendorId: Int,
                                 productId: Int?,
                                 locationId: UInt32?,
                                 interface: CFUUID,
                                 USBDeviceBlock: USBDeviceBlockType,
                                 interfaceBlock: InterfaceBlockType) -> AnyObject? {
                                                
        var kr: kern_return_t = 0
        var rValue: AnyObject? = nil
        
        let masterPort: mach_port_t = kIOMasterPortDefault

        let classesToMatch = IOServiceMatching(kIOUSBDeviceClassName) as NSMutableDictionary
        classesToMatch[kUSBVendorID] = vendorId
        classesToMatch[kUSBProductID] = productId ?? "*"
        
        // the iterator that will contain the results of IOServiceGetMatchingServices
        var matchingServices: io_iterator_t = 0
        kr = IOServiceGetMatchingServices(masterPort, classesToMatch, &matchingServices)
        if kr != KERN_SUCCESS ||  matchingServices == 0 {
        logError("IOServiceGetMatchingServices failed", kr: kr)
            // There are no devices from this vendor connected by USB
            return nil
        }
        var usbService: io_object_t
        repeat {
            usbService = IOIteratorNext(matchingServices)
            if (usbService != 0) {
                
                let deviceName = getDeviceNameForService(usbService)
                logVerbose("deviceName: \(deviceName ?? "Unknown")")
                
                if let devicePtr = getDeviceForService(usbService, interface: interface) {
                    let device = devicePtr.pointee.pointee
                    logVerbose("Device \(device)")

                    detectGeneralInterestForDevice(devicePtr, service:usbService)
                    
                    // Now that we have the IOUSBDeviceInterface, we can call the routines in IOUSBLib.h.
                    // In this case, fetch the product and locationID. The locationID uniquely identifies the device
                    // and will remain the same, even across reboots, so long as the bus topology doesn't change.
                    
                    let thisProductId = getProductIdforDevice(devicePtr)
                    let thisLocationId = getLocationForDevice(devicePtr)
                    
                    if let thisProductId = thisProductId, let thisLocationId = thisLocationId {
                        if let _ = deviceName {
                            if locationId != thisLocationId {
                                rValue = USBDeviceBlock(devicePtr, deviceName, Int(thisProductId), thisLocationId)
                                return rValue
                            }
                        }
                        
                        kr = device.USBDeviceOpen(devicePtr)
                        logError("USBDeviceOpen returned", kr: kr)
                        
                        var request = IOUSBFindInterfaceRequest()
                        request.bInterfaceClass = kIOUSBFindInterfaceDontCare // 1 // AUDIO
                        request.bInterfaceSubClass = kIOUSBFindInterfaceDontCare // 1 // CONTROL
                        request.bInterfaceProtocol = kIOUSBFindInterfaceDontCare
                        request.bAlternateSetting = kIOUSBFindInterfaceDontCare
                        var iterator: io_iterator_t = 0
                        kr = device.CreateInterfaceIterator(devicePtr, &request, &iterator)
                        logError("CreateInterfaceIterator returned", kr: kr)
                        
                        
                        var usbInterface: io_object_t
                        repeat {
                            usbInterface = IOIteratorNext(iterator)
                            if usbInterface != 0 {
                                logDebug(" Interface: 0x\(String(format: "%08x", usbInterface))")
                                if let interfacePtr = getInterfaceForInterface(usbInterface) {
                                    let interface = interfacePtr.pointee.pointee
                                    var interfaceNumber: UInt8 = 0
                                    kr = interface.GetInterfaceNumber(interfacePtr, &interfaceNumber)
                                    logError("GetInterfaceNumber returned", kr: kr)
                                    // We only want to use interface 0 - the HID interface
                                    if interfaceNumber == 0 {
                                        logVerbose("Interface: \(interface)")
                                        
//                                        detectGeneralInterestForInterface(usbInterface)
//                                        
//                                        var endpointCount: UInt8 = 0
//                                        interface.GetNumEndpoints(interfacePtr, &endpointCount)
//                                        
//                                        // Open the interface. This will instantiate the pipes associated with the endpoints
//                                        openInterface(interfacePtr) { (opened) in
//                                            if opened {
//                                                var port: mach_port_t = 0
//                                                
//                                                kr = interface.CreateInterfaceAsyncPort(interfacePtr, &port)
//                                                self.logError("CreateInterfaceAsyncPort returned", kr: kr)
//                                                
//                                                kr = interface.GetPipeStatus(interfacePtr, 0)
//                                                self.logError("GetPipeStatus[0] returned", kr: kr)
//                                                var pipeDirection: UInt8 = 0
//                                                var pipeNumber: UInt8 = 0
//                                                var pipeTransferType: UInt8 = 0
//                                                var pipeMaxPacketSize: UInt16 = 0
//                                                var pipeInterval: UInt8 = 0
//                                                kr = interface.GetPipeProperties(interfacePtr, 0, &pipeDirection, &pipeNumber, &pipeTransferType, &pipeMaxPacketSize, &pipeInterval)
//                                                self.logError("GetPipeProperties[0] returned", kr: kr)
//                                                
//                                                logDebug(" Endpoints (\(endpointCount))")
//                                                if endpointCount > 0 {
//                                                    for pipeRef: UInt8 in 1 ... endpointCount {
//                                                        self.logVerbose("pipeRef: \(pipeRef)")
//
//                                                        kr = interface.GetPipeStatus(interfacePtr, pipeRef)
//                                                        self.logError("GetPipeStatus returned", kr: kr)
//                                                        var pipeDirection: UInt8 = 0
//                                                        var pipeNumber: UInt8 = 0
//                                                        var pipeTransferType: UInt8 = 0
//                                                        var pipeMaxPacketSize: UInt16 = 0
//                                                        var pipeInterval: UInt8 = 0
//                                                        kr = interface.GetPipeProperties(interfacePtr, pipeRef, &pipeDirection, &pipeNumber, &pipeTransferType, &pipeMaxPacketSize, &pipeInterval)
//                                                        self.logError("GetPipeProperties returned", kr: kr)
//                                                    }
//                                                }
//                                                
                                                rValue = interfaceBlock(interfacePtr, deviceName, Int(thisProductId), thisLocationId)
//                                                
//                                                kr = interface.USBInterfaceClose(interfacePtr)
//                                                self.logError("USBInterfaceClose returned", kr: kr)
//                                            }
//                                            //
//                                            // Release the interface
//                                            interface.Release(interfacePtr)
//                                        }
                                    }
                                }
                                // Release the service object after getting the interface
                                kr = IOObjectRelease(usbInterface)
                                logError("Unable to release interface", kr: kr)
                                if kr != kIOReturnSuccess
                                {
                                    continue
                                }
                            }
                        }  while usbInterface != 0
                        return rValue
                    }
                }
            }
        } while usbService != 0
        return nil
    }

    fileprivate func executeOnDevice(_ vendorId: Int,
                                 productId: Int?,
                                 locationId: UInt32?,
                                 interface: CFUUID,
                                 USBDeviceBlock: USBDeviceBlockType) -> AnyObject? {
        
        var kr: kern_return_t = 0
        var rValue: AnyObject? = nil
        
        let masterPort: mach_port_t = kIOMasterPortDefault
        
        let classesToMatch = IOServiceMatching(kIOUSBDeviceClassName) as NSMutableDictionary
        classesToMatch[kUSBVendorID] = vendorId
        classesToMatch[kUSBProductID] = productId ?? "*"
        
        // the iterator that will contain the results of IOServiceGetMatchingServices
        var matchingServices: io_iterator_t = 0
        kr = IOServiceGetMatchingServices(masterPort, classesToMatch, &matchingServices)
        if kr != KERN_SUCCESS ||  matchingServices == 0 {
            logError("IOServiceGetMatchingServices failed", kr: kr)
            // There are no devices from this vendor connected by USB
            return nil
        }
        var usbService: io_object_t
        repeat {
            usbService = IOIteratorNext(matchingServices)
            if (usbService != 0) {
                
                let deviceName = getDeviceNameForService(usbService)
                logVerbose("deviceName: \(deviceName ?? "Unknown")")
                
                if let devicePtr = getDeviceForService(usbService, interface: interface) {
                    let device = devicePtr.pointee.pointee
                    logVerbose("Device \(device)")
                    
                    // Now that we have the device interface, we can call the routines in IOUSBLib.h.
                    // In this case, fetch the locationID. The locationID uniquely identifies the device
                    // and will remain the same, even across reboots, so long as the bus topology doesn't change.
                    
                    let thisProductId = getProductIdforDevice(devicePtr)
                    let thisLocationId = getLocationForDevice(devicePtr)
                    
                    if let thisProductId = thisProductId, let thisLocationId = thisLocationId {
                        if let _ = deviceName {
                            if locationId != thisLocationId {
                                rValue = USBDeviceBlock(devicePtr, deviceName, Int(thisProductId), thisLocationId)
                                return rValue
                            }
                        }
                        
                        rValue = USBDeviceBlock(devicePtr, deviceName, Int(thisProductId), thisLocationId)
                        return rValue
                    }
                }
            }
        } while usbService != 0
        return nil
    }
    
    // MARK: Functions to get interfaces from UUIDs
    fileprivate func getDeviceForService(_ usbService: io_service_t, interface: CFUUID) -> USBDeviceType? {
        return getInterfaceForService(usbService,
                                      clientId: kIOUSBDeviceUserClientTypeID!,
                                      interface: interface,
                                      mustStart: true)
    }
    
    fileprivate func getInterfaceForInterface(_ usbInterface: io_object_t) -> USBInterfaceType? {
        return getInterfaceForService(usbInterface,
                                      clientId: kIOUSBInterfaceUserClientTypeID!,
                                      interface: USBInterfaceUUID!,
                                      mustStart: true)
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
            res = (plugIn?.Start(plugInPtr, dict as CFDictionary, usbService))!
            logError("Start(2) returned", hr: res)
        }

        // Use the plugin interface to retrieve the interface
        let interfacePtr = UnsafeMutablePointer<T>.allocate(capacity: 1)
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
    
    fileprivate func getProductIdforDevice(_ devicePtr: USBDeviceType) -> UInt16? {
        var kr: kern_return_t = 0
        let device = devicePtr.pointee.pointee
        var productId: UInt16 = 0
        kr = device.GetDeviceProduct(devicePtr, &productId)
        if kr != KERN_SUCCESS {
            logError("GetDeviceProduct returned", kr: kr)
            return nil
        } else {
            logDebug("Product Id: 0x\(String(format: "%08x", productId))\n")
        }
        return productId
    }
    
    fileprivate func getProducNameforDevice(_ devicePtr: USBDeviceType) -> String? {
        let SmallAmpsProductId: Int = 0x0004
        let BigAmpsProductId: Int = 0x0005
        let MiniAmpProductId: Int = 0x0010
        let FloorAmpProductId: Int = 0x0012
        let SmallAmpsV2ProductId: Int = 0x0014
        let BigAmpsV2ProductId: Int = 0x0016
        let Blink1ProductId: Int = 0x01ed
        var kr: kern_return_t = 0
        let device = devicePtr.pointee.pointee
        var productId: UInt16 = 0
        kr = device.GetDeviceProduct(devicePtr, &productId)
        if kr != KERN_SUCCESS {
            logError("GetDeviceProduct returned", kr: kr)
            return nil
        } else {
            switch Int(productId) {
            case SmallAmpsProductId:
                return "Mustang I or II"
            case BigAmpsProductId:
                return "Mustang III, IV or V"
            case MiniAmpProductId:
                return "Mustang Mini"
            case FloorAmpProductId:
                return "Mustang Floor"
            case SmallAmpsV2ProductId:
                return "Mustang I or II V2"
            case BigAmpsV2ProductId:
                return "Mustang III, IV or V V2"
            case Blink1ProductId:
                return "Blink(1)" // It's noit a fender product, but I use it for USB dev when my amp isn't to hand
            default:
                return "Fender Product"
            }
        }
    }
    
    fileprivate func getLocationForDevice(_ devicePtr: USBDeviceType) -> UInt32? {
        var kr: kern_return_t = 0
        let device = devicePtr.pointee.pointee
        var locationId: UInt32 = 0
        kr = device.GetLocationID(devicePtr, &locationId)
        if kr != KERN_SUCCESS {
            logError("GetLocationID returned", kr: kr)
            return nil
        } else {
            logVerbose("Location ID: 0x\(String(format: "%08x", locationId))\n")
        }
        return locationId
    }
    
    // MARK: Functions for opening and closing interfaces
    fileprivate func openInterface(_ interfacePtr: USBInterfaceType,
                               onCompletion: @escaping (_ opened: Bool) -> ()) {

        lastCompletion = onCompletion
        DispatchQueue.global().async {
            // Try 5 times to open the interface
            var rValue = false
            for _ in 1...5 {
                if let opened = self.openInterface(interfacePtr) {
                    rValue = opened
                    break
                }
                sleep(1)
            }
            onCompletion(rValue)
        }
    }
    
    fileprivate func openInterface(_ interfacePtr: USBInterfaceType) -> Bool? {
        var kr: kern_return_t = 0
        let interface = interfacePtr.pointee.pointee
        lastInterface = nil

        // Open the interface. This will instantiate the pipes associated with the endpoints
        kr = interface.USBInterfaceOpen(interfacePtr)
        if kr == kIOReturnSuccess
        {
            logDebug("Opened interface")
            return true
        } else if kr == kIOReturnExclusiveAccess {
            logDebug("  USBInterfaceOpen failed. Exclusive access")
            lastInterface = interfacePtr
            return nil
        } else {
            logError("USBInterfaceOpen returned", kr: kr)
        }
        return false
    }
    
    // MARK: Functions for opening and closing devices
    fileprivate func closeDevice(_ devicePtr: USBDeviceType) {
        var kr: kern_return_t = 0
        let device = devicePtr.pointee.pointee
        
        kr = device.USBDeviceClose(devicePtr)
        logError("USBDeviceClose returned", kr: kr)
    }
    
    // MARK: Logging and debugging
    fileprivate func debugPrint(_ name: String?,
                            USBDevice: USBDeviceType?,
                            interface: USBInterfaceType?,
                            audio: AnyObject?) {
        logDebug(" ")
        logDebug("Device name is \(name ?? "Unknown")")
        if let USBDevice = USBDevice {
            self.debugPrint(USBDevice)
        }
        if let audio = audio {
            self.debugPrint(audio)
        }
        if let interface = interface {
            self.debugPrint(interface)
        }
    }

    fileprivate func debugPrint(_ audioPtr: AnyObject) {
        //printAudio(audioPtr)
    }
    
    func debugPrint(_ devicePtr: USBDeviceType) {
        let device = devicePtr.pointee.pointee
        var kr: kern_return_t = 0
        
        var deviceVendor: UInt16 = 0
        var deviceProduct: UInt16 = 0
        var releaseNumber: UInt16 = 0
        var deviceClass: UInt8 = 0
        var deviceSubClass: UInt8 = 0
        var deviceProtocol: UInt8 = 0
//        var deviceName: String?
        var thisLocationId: UInt32 = 0
        var configCount: UInt8 = 0
        var configNum: UInt8 = 0
        var config: UnsafeMutablePointer<IOUSBConfigurationDescriptor>? = nil
        var speed: UInt8 = 0
        var address: USBDeviceAddress = 0
        var busPower: UInt32 = 0
//        var busFrame: UInt64 = 0
//        var time: AbsoluteTime
        

        kr = device.GetDeviceVendor(devicePtr, &deviceVendor)
        logError("GetDeviceVendor returned", kr: kr)
        kr = device.GetDeviceProduct(devicePtr, &deviceProduct)
        logError("GetDeviceProduct returned", kr: kr)
        kr = device.GetDeviceReleaseNumber(devicePtr, &releaseNumber)
        logError("GetDeviceReleaseNumber returned", kr: kr)
        kr = device.GetDeviceClass(devicePtr, &deviceClass)
        logError("GetDeviceClass returned", kr: kr)
        kr = device.GetDeviceSubClass(devicePtr, &deviceSubClass)
        logError("GetDeviceSubClass returned", kr: kr)
        kr = device.GetDeviceProtocol(devicePtr, &deviceProtocol)
        logError("GetDeviceProtocol returned", kr: kr)
        kr = device.GetLocationID(devicePtr, &thisLocationId)
        logError("GetLocationID returned", kr: kr)
        kr = device.GetNumberOfConfigurations(devicePtr, &configCount)
        logError("GetNumberOfConfigurations returned", kr: kr)
        kr = device.GetConfiguration(devicePtr, &configNum)
        logError("GetConfiguration returned", kr: kr)
        if configNum > 0 {
            let index0Config = configNum - 1
            kr = device.GetConfigurationDescriptorPtr(devicePtr, index0Config, &config)
            logError("GetConfigurationDescriptorPtr returned", kr: kr)
        }
        kr = device.GetDeviceSpeed(devicePtr, &speed)
        logError("GetDeviceSpeed returned ", kr: kr)
        kr = device.GetDeviceAddress(devicePtr, &address)
        logError("GetDeviceAddress returned", kr: kr)
        kr = device.GetDeviceBusPowerAvailable(devicePtr, &busPower)
        logError("GetDeviceBusPowerAvailable returned", kr: kr)
//        kr = device.GetBusFrameNumber(devicePtr, &busFrame, &time)
//        logError("GetBusFrameNumber returned", kr: kr)
        
        logDebug("Vendor is 0x\(String(format: "%04x", deviceVendor))")
        logDebug("Product is 0x\(String(format: "%04x", deviceProduct)) - \(getProducNameforDevice(devicePtr) ?? "Unknown")")
        logDebug("Release number is 0x\(String(format: "%04x", releaseNumber))")
        logDebug("Class is \(deviceClass)")
        logDebug("SubClass is \(deviceSubClass)")
        logDebug("Protocol is \(deviceProtocol)")
        logDebug("Location is 0x\(String(format: "%08x", thisLocationId))")
        logDebug("Address is \(String(format: "%04x", address))")
        logDebug("Configs is \(configCount)")
        logDebug("Config is \(configNum)")
        if config != nil {
            logDebug(" Config descriptor is \(String(describing: config?.pointee.bDescriptorType))")
            logDebug(" Config interfaces is \(String(describing: config?.pointee.bNumInterfaces))")
            logDebug(" Config value is \(String(describing: config?.pointee.bConfigurationValue))")
            logDebug(" Configuration is \(String(describing: config?.pointee.iConfiguration))")
            logDebug(" Config attributes is \(String(describing: config?.pointee.bmAttributes))")
            logDebug(" Config power is \(String(describing: config?.pointee.MaxPower))")
        }
        logDebug("Speed is \(speed)")
        logDebug("Power is \(busPower)")
    }
    
    func debugPrint(_ intInterfacePtr: USBInterfaceType) {
        let intInterface = intInterfacePtr.pointee.pointee
        var kr: kern_return_t = 0
        
        var interfaceDeviceVendor: UInt16 = 0
        var interfaceDeviceProduct: UInt16 = 0
        var interfaceReleaseNumber: UInt16 = 0
        var interfaceNumber: UInt8 = 0
        var interfaceClass: UInt8 = 0
        var interfaceSubClass: UInt8 = 0
        var interfaceProtocol: UInt8 = 0
        var configValue: UInt8 = 0
        var alternateSetting: UInt8 = 0
        var endpointCount: UInt8 = 0
        var aPort: mach_port_t = 0
        var eSource: Unmanaged<CFRunLoopSource>!
        
        kr = intInterface.GetDeviceVendor(intInterfacePtr, &interfaceDeviceVendor)
        logError("GetDeviceVendor returned", kr: kr)
        kr = intInterface.GetDeviceProduct(intInterfacePtr, &interfaceDeviceProduct)
        logError("GetDeviceProduct returned", kr: kr)
        kr = intInterface.GetDeviceReleaseNumber(intInterfacePtr, &interfaceReleaseNumber)
        logError("GetDeviceReleaseNumber returned", kr: kr)
        kr = intInterface.GetInterfaceNumber(intInterfacePtr, &interfaceNumber)
        logError("GetInterfaceNumber returned", kr: kr)
        kr = intInterface.GetInterfaceClass(intInterfacePtr, &interfaceClass)
        logError("GetInterfaceClass returned", kr: kr)
        kr = intInterface.GetInterfaceSubClass(intInterfacePtr, &interfaceSubClass)
        logError("GetInterfaceSubClass returned", kr: kr)
        kr = intInterface.GetInterfaceProtocol(intInterfacePtr, &interfaceProtocol)
        logError("GetInterfaceProtocol returned", kr: kr)
        kr = intInterface.GetConfigurationValue(intInterfacePtr, &configValue)
        logError("GetConfigurationValue returned", kr: kr)
        kr = intInterface.GetAlternateSetting(intInterfacePtr, &alternateSetting)
        logError("GetAlternateSetting returned ", kr: kr)
        kr = intInterface.GetNumEndpoints(intInterfacePtr, &endpointCount)
        logError("GetNumEndpoints returned", kr: kr)
        aPort = intInterface.GetInterfaceAsyncPort(intInterfacePtr)
        eSource = intInterface.GetInterfaceAsyncEventSource(intInterfacePtr)
        
        var text = "  Vendor is 0x\(String(format: "%04x", interfaceDeviceVendor))\n"
        text += "  Product is 0x\(String(format: "%04x", interfaceDeviceProduct))\n"
        text += "  Release number is 0x\(String(format: "%04x", interfaceReleaseNumber))\n"
        text += "  Interface number is \(interfaceNumber)\n"
        text += "  Class is \(interfaceClass) (\(descriptionForInterfaceClass(interfaceClass)))\n"
        text += "  SubClass is \(interfaceSubClass) (\(descriptionForInterfaceClass(interfaceClass, subClass: interfaceSubClass)))\n"
        text += "  Protocol is \(interfaceProtocol)\n"
        text += "  Config value is \(configValue)\n"
        text += "  Alternate is \(alternateSetting)\n"
        text += "  Async port is 0x\(String(format: "%08x", aPort))\n"
        text += "  Async event source is \(eSource)\n"
        text += "  Endpoints is \(endpointCount)\n"
        
        if endpointCount > 0 {
            for endpointNumber: UInt8 in 1...endpointCount {
                text += "   Endpoint: \(endpointNumber)\n"
//                for direction: UInt8 in 0...1 {
//                    var transferType: UInt8 = 0
//                    var packetSize: UInt16 = 0
//                    var interval: UInt8 = 0
//                    kr = intInterface.GetEndpointProperties(intInterfacePtr, alternateSetting, endpointNumber, direction, &transferType, &packetSize, &interval)
//                    if kr == kIOReturnSuccess {
//                        text += "    Direction: \(direction) (\(descriptionForDirection(direction)))\n"
//                        text += "     Transfer type is \(transferType) (\(descriptionForTransferType(transferType)))\n"
//                        text += "     Packet size is \(packetSize)\n"
//                        text += "     Interval is \(interval)\n"
//                    }
//                }
            }
        }
        logDebug(text)
    }

    fileprivate func descriptionForInterfaceClass(_ interfaceClass: UInt8) -> String {
        switch interfaceClass {
        case 0x01: return "Audio"
        case 0x02: return "Comms and CDC"
        case 0x03: return "HID"
        case 0x05: return "Physical"
        case 0x06: return "Image"
        case 0x07: return "Printer"
        case 0x08: return "Mass Storage"
        case 0x09: return "Hub"
        case 0x0A: return "CDC Data"
        case 0x0B: return "Smart card"
        case 0x0D: return "Content Security"
        case 0x0E: return "Video"
        case 0x0F: return "Healthcare"
        case 0x10: return "AV Device"
        case 0x11: return "Billboard device"
        case 0x12: return "USB-C bridge"
        case 0xDC: return "Diag device"
        case 0xE0: return "Wireless"
        case 0xEF: return "Misc"
        case 0xFE: return "App specific"
        case 0xFF: return "Vendor specific"
        default: return "Unknown"
        }
    }
    fileprivate func descriptionForInterfaceClass(_ interfaceClass: UInt8, subClass: UInt8) -> String {
        switch interfaceClass {
        case 0x01: switch subClass {
        case 0x01: return "Control"
        case 0x02: return "Audio"
        case 0x03: return "Midi"
        default: return "Unknown"
            }
        default: return "Unknown"
        }
    }
    fileprivate func descriptionForDirection(_ direction: UInt8) -> String {
        switch direction {
        case 0: return "Out"
        case 1: return "In"
        case 2: return "None"
        case 3: return "Any"
        default: return "Unknown"
        }
    }
    fileprivate func descriptionForTransferType(_ transferType: UInt8) -> String {
        switch transferType {
        case 0: return "Control"
        case 1: return "Isochronous"
        case 2: return "Bulk"
        case 3: return "Interrupt"
        case 0xff: return "Any"
        default: return "Unknown"
        }
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
        case kIOUSBMessageHubResetPort:
            return "kIOUSBMessageHubResetPort"
        case kIOUSBMessageHubSuspendPort:
            return "kIOUSBMessageHubSuspendPort"
        case kIOUSBMessageHubResumePort:
            return "kIOUSBMessageHubResumePort"
        case kIOUSBMessageHubIsDeviceConnected:
            return "kIOUSBMessageHubIsDeviceConnected"
        case kIOUSBMessageHubIsPortEnabled:
            return "kIOUSBMessageHubIsPortEnabled"
        case kIOUSBMessageHubReEnumeratePort:
            return "kIOUSBMessageHubReEnumeratePort"
        case kIOUSBMessagePortHasBeenReset:
            return "kIOUSBMessagePortHasBeenReset"
        case kIOUSBMessagePortHasBeenResumed:
            return "kIOUSBMessagePortHasBeenResumed"
        case kIOUSBMessageHubPortClearTT:
            return "kIOUSBMessageHubPortClearTT"
        case kIOUSBMessagePortHasBeenSuspended:
            return "kIOUSBMessagePortHasBeenSuspended"
        case kIOUSBMessageFromThirdParty:
            return "kIOUSBMessageFromThirdParty"
        case kIOUSBMessagePortWasNotSuspended:
            return "kIOUSBMessagePortWasNotSuspended"
        case kIOUSBMessageExpressCardCantWake:
            return "kIOUSBMessageExpressCardCantWake"
        case kIOUSBMessageCompositeDriverReconfigured:
            return "kIOUSBMessageCompositeDriverReconfigured"
        case kIOUSBMessageHubSetPortRecoveryTime:
            return "kIOUSBMessageHubSetPortRecoveryTime"
        case kIOUSBMessageOvercurrentCondition:
            return "kIOUSBMessageOvercurrentCondition"
        case kIOUSBMessageNotEnoughPower:
            return "kIOUSBMessageNotEnoughPower"
        case kIOUSBMessageController:
            return "kIOUSBMessageController"
        case kIOUSBMessageRootHubWakeEvent:
            return "kIOUSBMessageRootHubWakeEvent"
        case kIOUSBMessageReleaseExtraCurrent:
            return "kIOUSBMessageReleaseExtraCurrent"
        case kIOUSBMessageReallocateExtraCurrent:
            return "kIOUSBMessageReallocateExtraCurrent"
        case kIOUSBMessageEndpointCountExceeded:
            return "kIOUSBMessageEndpointCountExceeded"
        case kIOUSBMessageDeviceCountExceeded:
            return "kIOUSBMessageDeviceCountExceeded"
        case kIOUSBMessageHubPortDeviceDisconnected:
            return "kIOUSBMessageHubPortDeviceDisconnected"
        case kIOUSBMessageUnsupportedConfiguration:
            return "kIOUSBMessageUnsupportedConfiguration"
        case kIOUSBMessageHubCountExceeded:
            return "kIOUSBMessageHubCountExceeded"
        case kIOUSBMessageTDMLowBattery:
            return "kIOUSBMessageTDMLowBattery"
        case kIOUSBMessageLegacySuspendDevice:
            return "kIOUSBMessageLegacySuspendDevice"
        case kIOUSBMessageLegacyResetDevice:
            return "kIOUSBMessageLegacyResetDevice"
        case kIOUSBMessageLegacyReEnumerateDevice:
            return "kIOUSBMessageLegacyReEnumerateDevice"
        default:
            return "Unknown"
        }
    }
}

//
//  StorageAgent.swift
//  Mustang
//
//  Created by Derek Knight on 6/08/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

private let singleton = StorageAgent()

private struct DeviceStore {
    var device: IOHIDDevice?
    var vendor: Int?
    var product: Int?
    var location: UInt32?
    var initialised: Bool
    var semaphore: DispatchSemaphore
}

class StorageAgent {
    
    class var sharedInstance: StorageAgent {
        return singleton
    }
    
    fileprivate var devices = [String : DeviceStore]()
    internal func addDevice (_ device: IOHIDDevice?, vendor: Int?, product: Int?, location: UInt32?, initialised: Bool) -> String {
        let deviceKey = "\(vendor ?? 666):\(product ?? 666):\(location ?? 666)"
        synchronise(self) {
            if !self.devices.keys.contains(deviceKey) {
                self.devices[deviceKey] = DeviceStore(device: device, vendor: vendor, product: product, location: location, initialised: initialised, semaphore: DispatchSemaphore(value: 0))
            }
        }
        return deviceKey
    }
    
    internal func updateDevice (_ deviceKey: String, device: IOHIDDevice) {
        synchronise(self) {
            self.devices[deviceKey]?.device = device
        }
    }
    
    internal func updateDevice (_ deviceKey: String, initialised: Bool) {
        synchronise(self) {
            self.devices[deviceKey]?.initialised = initialised
        }
    }
    
    internal func deviceForDevice (_ deviceKey: String) -> IOHIDDevice? {
        var rValue: IOHIDDevice?
        synchronise(self) {
            rValue = self.devices[deviceKey]?.device
        }
        return rValue
    }
    
    internal func deviceInitialised (_ deviceKey: String) -> Bool {
        var rValue: Bool!
        synchronise(self) {
            guard let device = self.devices[deviceKey] else {
                fatalError("Cant get initialised state for non-existent device - \(deviceKey)")
            }
            rValue = device.initialised
        }
        return rValue
    }
    
    internal func semaphoreForDevice (_ deviceKey: String) -> DispatchSemaphore {
        var rValue: DispatchSemaphore!
        synchronise(self) {
            guard let device = self.devices[deviceKey] else {
                fatalError("Cant get semaphore for non-existent device - \(deviceKey)")
            }
            rValue = device.semaphore
        }
        return rValue
    }

    fileprivate func synchronise(_ lock: AnyObject, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
}


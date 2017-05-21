//
//  USBMockAgent.swift
//  Mustang
//
//  Created by Derek Knight on 11/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

// Fender constants
private let FenderVendorId: Int = 0x1ed8

// Mustang constants
private let MustangProductId: Int = 0x22
private let MustangName: String = "Mockstang III"

class USBMockAgent : USBServiceAgentProtocol {
 
    func getDevices() -> [DLUSBDevice] {
        return [DLUSBDevice(withVendor: FenderVendorId, product: MustangProductId, name: MustangName, locationId: 12345)]
    }
    
    func getInfoForDeviceWithId(_ locationId: UInt32) -> DLUSBDevice? {
        return DLUSBDevice(withVendor: FenderVendorId, product: MustangProductId, name: MustangName, locationId: 12345)
    }
}

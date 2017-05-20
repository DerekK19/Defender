//
//  BOHIDDevice.swift
//  Mustang
//
//  Created by Derek Knight on 4/08/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

struct BOHIDDevice {
    let vendor: Int
    let product: Int
    let name: String
    let location: UInt32
    
    init(dl: DLHIDDevice) {
        self.vendor = dl.vendor
        self.product = dl.product
        self.name = dl.name
        self.location = dl.locationId
    }
    
    static func convertArray(_ dls: [DLHIDDevice]) -> [BOHIDDevice] {
        return dls.map { BOHIDDevice(dl: $0) }
    }
    
    var dataObject: DLHIDDevice {
        return DLHIDDevice(withVendor: self.vendor,
                           product: self.product,
                           name: self.name,
                           locationId: self.location)
    }
}

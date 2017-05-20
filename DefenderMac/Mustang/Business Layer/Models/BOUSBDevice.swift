//
//  BOUSBDevice.swift
//  Mustang
//
//  Created by Derek Knight on 24/07/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

struct BOUSBDevice {
    let vendor: Int
    let product: Int
    let name: String
    let location: UInt32
    
    init(dl: DLUSBDevice) {
        self.vendor = dl.vendor
        self.product = dl.product
        self.name = dl.name
        self.location = dl.locationId
    }
    
    static func convertArray(_ dls: [DLUSBDevice]) -> [BOUSBDevice] {
        return dls.map { BOUSBDevice(dl: $0) }
    }

    var dataObject: DLUSBDevice {
        return DLUSBDevice(withVendor: self.vendor,
                           product: self.product,
                           name: self.name,
                           locationId: self.location)
    }
}

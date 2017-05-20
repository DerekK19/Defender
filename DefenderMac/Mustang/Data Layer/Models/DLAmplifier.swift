//
//  DLAmplifier.swift
//  Mustang
//
//  Created by Derek Knight on 24/07/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

class DLAmplifier: Mappable {
    
    var vendorId: Int!
    var productId: Int!
    var manufacturer: String!
    var product: String!
    var locationId: UInt32!
    var deviceId: UInt32!

    required init?(map: Map) {
        mapping(map: map)
    }
    
    init(usb: DLUSBDevice, hid: DLHIDDevice?, audio: DLAudioDevice?) {
        self.vendorId = usb.vendor
        self.productId = usb.product
        self.manufacturer = audio?.manufacturer ?? ""
        self.product = usb.name
        self.locationId = usb.locationId
        self.deviceId = audio?.deviceId ?? 0
    }

    init(withVendorId vendorId: Int, productId: Int, manufacturer: String, product: String, locationId: UInt32, deviceId: UInt32) {
        self.vendorId = vendorId
        self.productId = productId
        self.product = product
        self.manufacturer = manufacturer
        self.locationId = locationId
        self.deviceId = deviceId
    }
    
    func mapping(map: Map) {
        vendorId        <- map["vendor"]
        productId       <- map["productId"]
        manufacturer    <- map["manufacturer"]
        product         <- map["product"]
        locationId      <- map["locationId"]
        deviceId        <- map["deviceId"]
    }
    
}

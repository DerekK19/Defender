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
    
    var vendor: UInt16!
    var manufacturer: String!
    var name: String!
    var locationId: UInt32!
    var deviceId: UInt32!

    required init?(map: Map) {
        mapping(map: map)
    }
    
    init(withVendor vendor: UInt16, manufacturer: String, name: String, locationId: UInt32, deviceId: UInt32) {
        self.vendor = vendor
        self.manufacturer = manufacturer
        self.name = name
        self.locationId = locationId
        self.deviceId = deviceId
    }
    
    func mapping(map: Map) {
        vendor          <- map["vendor"]
        manufacturer    <- map["manufacturer"]
        name            <- map["name"]
        locationId      <- map["locationId"]
        deviceId        <- map["deviceId"]
    }
    
}

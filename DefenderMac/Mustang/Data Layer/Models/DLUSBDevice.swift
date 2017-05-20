//
//  DLUSBDevice.swift
//  Mustang
//
//  Created by Derek Knight on 26/06/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

class DLUSBDevice: Mappable {
    
    var vendor: Int!
    var product: Int!
    var name: String!
    var locationId: UInt32!
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init(withVendor vendor: Int, product: Int, name: String, locationId: UInt32) {
        self.vendor = vendor
        self.product = product
        self.name = name
        self.locationId = locationId
    }
    
    func mapping(map: Map) {
        vendor          <- map["vendor"]
        product         <- map["product"]
        name            <- map["name"]
        locationId      <- map["locationId"]
    }
    
}


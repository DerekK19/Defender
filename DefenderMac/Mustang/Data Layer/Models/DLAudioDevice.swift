//
//  DLAudioDevice.swift
//  Mustang
//
//  Created by Derek Knight on 24/07/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

class DLAudioDevice: Mappable {
    
    var manufacturer: String!
    var name: String!
    var deviceId: UInt32!
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init(withManufacturer manufacturer: String, name: String, deviceId: UInt32) {
        self.manufacturer = manufacturer
        self.name = name
        self.deviceId = deviceId
    }
    
    func mapping(map: Map) {
        manufacturer    <- map["manufacturer"]
        name            <- map["name"]
        deviceId        <- map["deviceId"]
    }
    
}

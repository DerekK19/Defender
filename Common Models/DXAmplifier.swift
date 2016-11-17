//
//  DXAmplifier.swift
//  DefenderApp
//
//  Created by Derek Knight on 17/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

internal class DXAmplifier : Mappable, Transferable {
    
    var name: String!
    var manufacturer: String!

    required init?(map: Map) {
        mapping(map: map)
    }
    
    required init(data: Data) throws {
        if let string = String(data: data, encoding: .utf8),
           let temp = Mapper<DXAmplifier>().map(JSONString: string) {
            name = temp.name
            manufacturer = temp.manufacturer
            return
        }
        throw TransferError.serialising
    }
    
    init(name: String, manufacturer: String) {
        self.name = name
        self.manufacturer = manufacturer
    }
    
    var data: Data? {
        get {
            if let string = self.toJSONString() {
                return string.data(using: .utf8)
            }
            return nil
        }
    }
    
    func mapping(map: Map) {
        name            <- map["name"]
        manufacturer    <- map["manufacturer"]
    }
}

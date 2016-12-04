//
//  DXKnob.swift
//  DefenderApp
//
//  Created by Derek Knight on 4/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

internal class DXKnob : Transferable {
    
    var name: String!
    var value: Float!
    
    init(name: String) {
        self.name = name
    }
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    required init(data: Data?) throws {
        if let data = data {
            if let string = String(data: data, encoding: .utf8),
                let temp = Mapper<DXKnob>().map(JSONString: string) {
                name = temp.name
                value = temp.value
                return
            }
        }
        throw TransferError.serialising
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
        value           <- map["value"]
    }
}

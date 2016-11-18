//
//  DXPreset.swift
//  DefenderApp
//
//  Created by Derek Knight on 18/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

internal class DXPreset : Transferable {
    
    var name: String!
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    required init(data: Data?) throws {
        if let data = data {
            if let string = String(data: data, encoding: .utf8),
                let temp = Mapper<DXPreset>().map(JSONString: string) {
                name = temp.name
                return
            }
        }
        throw TransferError.serialising
    }
    
    init(name: String) {
        self.name = name
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
    }
}

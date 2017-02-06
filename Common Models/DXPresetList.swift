//
//  DXPresetList.swift
//  DefenderApp
//
//  Created by Derek Knight on 5/02/17.
//  Copyright © 2017 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

internal class DXPresetList : Transferable {
    
    var names: [String]!
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    required init(data: Data?) throws {
        if let data = data {
            if let string = String(data: data, encoding: .utf8),
                let temp = Mapper<DXPresetList>().map(JSONString: string) {
                names = temp.names
                return
            }
        }
        throw TransferError.serialising
    }
    
    init(names: [String]) {
        self.names = names
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
        names            <- map["names"]
    }
}

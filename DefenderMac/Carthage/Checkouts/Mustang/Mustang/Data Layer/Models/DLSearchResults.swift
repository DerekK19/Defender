//
//  DLSearchResults.swift
//  Mustang
//
//  Created by Derek Knight on 6/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

class DLSearchResults: Mappable {
    
    var total: Int!
    var list: [DLSearchItem]!
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        total          <- map["total"]
        list           <- map["list"]
    }
    
}

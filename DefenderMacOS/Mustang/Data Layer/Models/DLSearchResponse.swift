//
//  DLSearchResponse.swift
//  Mustang
//
//  Created by Derek Knight on 6/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

class DLSearchResponse: Mappable {
    
    var result: DLSearchResult!
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        result         <- map["result"]
    }
    
}

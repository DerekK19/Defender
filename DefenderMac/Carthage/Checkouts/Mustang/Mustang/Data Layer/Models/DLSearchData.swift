//
//  DLSearchData.swift
//  Mustang
//
//  Created by Derek Knight on 6/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

class DLSearchData: Mappable {
    
    var results: DLSearchResults!
    var pagination: DLSearchPagination!
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        pagination     <- map["pagination"]
        results        <- map["results"]
    }
    
}

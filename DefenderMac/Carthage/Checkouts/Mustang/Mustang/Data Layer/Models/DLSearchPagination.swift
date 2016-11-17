//
//  DLSearchPagination.swift
//  Mustang
//
//  Created by Derek Knight on 8/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

class DLSearchPagination: Mappable {
    
    var total: String!
    var limit: UInt!
    var pages: UInt!
    var page: UInt!

    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        total          <- map["total"]
        limit          <- map["limit"]
        pages          <- map["pages"]
        page           <- map["page"]
    }

}

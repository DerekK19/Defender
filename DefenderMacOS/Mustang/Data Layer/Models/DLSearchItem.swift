//
//  DLSearchItem.swift
//  Mustang
//
//  Created by Derek Knight on 6/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

class DLSearchItem: Mappable {
    
    var id: String!
    var title: String!
    var data: DLSearchItemData!
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init(withId id: String, title: String, data: DLSearchItemData) {
        self.id = id
        self.title = title
        self.data = data
    }
    
    func mapping(map: Map) {
        id             <- map["id"]
        title          <- map["title"]
        data           <- map["data"]
    }
    
}

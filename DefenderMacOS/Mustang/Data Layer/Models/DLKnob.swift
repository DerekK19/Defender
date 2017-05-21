//
//  DLKnob.swift
//  Mustang
//
//  Created by Derek Knight on 3/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

class DLKnob: Mappable {

    var value: Int!

    required init?(map: Map) {
        mapping(map: map)
    }

    init(withValue value: Int) {
        self.value = value
    }
    
    func mapping(map: Map) {
        value          <- map["value"]
    }
    
}

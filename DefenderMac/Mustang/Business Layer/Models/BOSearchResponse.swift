//
//  BOSearchResponse.swift
//  Mustang
//
//  Created by Derek Knight on 6/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

struct BOSearchResponse: DTOSearchResponse {
    
    var pagination: DTOSearchPagination
    var items: [DTOSearchItem]
    
    private let _items: [BOSearchItem]
    
    init(dl: DLSearchResponse) {
        
        pagination = BOSearchPagination(dl: dl.result.data.pagination)
        items = BOSearchItem.convertArray(dl.result.data.results.list)
        _items = BOSearchItem.convertArray(dl.result.data.results.list)
    }
}

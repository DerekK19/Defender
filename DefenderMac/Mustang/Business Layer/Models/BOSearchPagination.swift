//
//  BOSearchPagination.swift
//  Mustang
//
//  Created by Derek Knight on 8/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

struct BOSearchPagination: DTOSearchPagination {
    
    var total: UInt
    var limit: UInt
    var pages: UInt
    var page: UInt
    
    init (dl: DLSearchPagination) {
        total = UInt(dl.total ?? "0") ?? 0
        limit = dl.limit
        pages = dl.pages
        page = dl.page
    }
}

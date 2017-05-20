//
//  DTOSearchPagination.swift
//  Mustang
//
//  Created by Derek Knight on 8/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

public protocol DTOSearchPagination {
    var total: UInt { get set }
    var limit: UInt { get set }
    var pages: UInt { get set }
    var page: UInt { get set }

}

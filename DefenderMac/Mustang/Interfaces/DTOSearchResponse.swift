//
//  DTOSearchResponse.swift
//  Mustang
//
//  Created by Derek Knight on 6/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

public protocol DTOSearchResponse {
    var pagination: DTOSearchPagination { get set }
    var items: [DTOSearchItem] { get set }
}

//
//  DTOSearchItem.swift
//  Mustang
//
//  Created by Derek Knight on 6/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

public protocol DTOSearchItem {
    var id: String { get set }
    var title: String { get set }
    var data: DTOSearchItemData? { get set }

}

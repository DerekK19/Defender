//
//  Transferable.swift
//  DefenderApp
//
//  Created by Derek Knight on 17/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

internal protocol Transferable {
    init(data: Data)
    var data: Data { get }
}

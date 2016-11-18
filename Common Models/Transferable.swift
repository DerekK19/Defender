//
//  Transferable.swift
//  DefenderApp
//
//  Created by Derek Knight on 17/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

internal enum TransferError: Error {
    case serialising
}

internal protocol Transferable : Mappable {
    init(data: Data?) throws
    var data: Data? { get }
}

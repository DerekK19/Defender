//
//  Transferable.swift
//  DefenderApp
//
//  Created by Derek Knight on 17/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

internal enum TransferError: Error {
    case serialising
}

internal protocol Transferable {
    init(data: Data) throws
    var data: Data? { get }
}

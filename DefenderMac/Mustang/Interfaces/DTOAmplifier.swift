//
//  DTOAmplifier.swift
//  Mustang
//
//  Created by Derek Knight on 27/07/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

public protocol DTOAmplifier {
    var vendor: Int { get }
    var product: Int { get }
    var name: String { get }
    var location: UInt32 { get }
    var manufacturer: String { get }
    var device: UInt32 { get }
}
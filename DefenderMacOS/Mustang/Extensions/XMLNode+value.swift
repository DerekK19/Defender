//
//  XMLNode+value.swift
//  Mustang
//
//  Created by Derek Knight on 27/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

extension XMLNode {
    var intValue: Int? {
        get {
            if let str = stringValue {
                return Int(str)
            }
            return nil
        }
    }
}

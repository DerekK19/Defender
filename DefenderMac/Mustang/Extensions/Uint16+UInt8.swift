//
//  Uint16+UInt8.swift
//  Mustang
//
//  Created by Derek Knight on 10/08/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

extension UInt16 {
    
    init(byte1: UInt8, byte2: UInt8) {
        let int=Int(byte1)*256 + Int(byte2)
        self.init(int)
    }
    
}
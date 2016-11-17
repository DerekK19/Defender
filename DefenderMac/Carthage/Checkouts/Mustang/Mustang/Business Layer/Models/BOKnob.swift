//
//  BOKnob.swift
//  Mustang
//
//  Created by Derek Knight on 3/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

struct BOKnob: DTOKnob {

    var value: Float
    
    init (dl: DLKnob) {
        value = BOKnob.float(dl.value) ?? -1.0
    }

    var dataObject: DLKnob {
        return DLKnob(withValue: BOKnob.int(value) ?? 0)
    }
    
    static func convertArray(_ dls: [DLKnob]) -> [BOKnob] {
        return dls.map { BOKnob(dl: $0) }
    }
    
    fileprivate static func float(_ int: Int?) -> Float? {
        return int == nil ? nil : (Float(int!) / 256.0)
    }
    
    fileprivate static func int(_ float: Float?) -> Int? {
        return float == nil ? nil : Int(float! * 256.0)
    }
    
}

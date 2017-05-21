//
//  DXKnob+BO.swift
//  Defender
//
//  Created by Derek Knight on 4/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

extension DXKnob {
    
    convenience init(dto: BOKnob) {
        self.init(name: dto.name)
        value = dto.value
    }
    
    func copyInto(knob: inout BOKnob) {
       knob.value = value
    }
}

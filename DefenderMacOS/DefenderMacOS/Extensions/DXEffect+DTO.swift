//
//  DXEffect+BO.swift
//  Defender
//
//  Created by Derek Knight on 19/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

extension DXEffect {
    
    convenience init(dto: BOEffect) {
        var convertedType: DXEffectType = .Unknown
        switch dto.type {
        case .Stomp:
            convertedType = .Stomp
        case .Modulation:
            convertedType = .Modulation
        case .Delay:
            convertedType = .Delay
        case .Reverb:
            convertedType = .Reverb
        case .Unknown:
            convertedType = .Unknown
        }
        self.init(type: convertedType)
        module = dto.module
        name = dto.name ?? ""
        slot = dto.slot
        enabled = dto.enabled
        colour = dto.colour
        knobs = Array(dto.knobs.map({ DXKnob(dto: $0) }).dropLast(dto.knobs.count - dto.knobCount))
    }
 
    func copyInto(effect: inout BOEffect) {
//       effect.type = type
//        effect.module = module
        effect.slot = slot
        effect.enabled = enabled
        effect.colour = colour
        for i in 0..<effect.knobCount {
            knobs[i].copyInto(knob: &effect.knobs[i])
        }
    }
}

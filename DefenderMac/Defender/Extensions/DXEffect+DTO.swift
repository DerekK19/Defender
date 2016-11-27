//
//  DXEffect+DTO.swift
//  Defender
//
//  Created by Derek Knight on 19/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import Mustang

extension DXEffect {
    
    convenience init(dto: DTOEffect) {
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
        knobs = Array(dto.knobs.map({ $0.value }).dropLast(dto.knobs.count - dto.knobCount))
    }
    
}

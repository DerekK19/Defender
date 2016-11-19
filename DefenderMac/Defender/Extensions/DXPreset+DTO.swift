//
//  DXPreset+DTO.swift
//  Defender
//
//  Created by Derek Knight on 18/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import Mustang

extension DXPreset {
    
    convenience init(dto: DTOPreset) {
        self.init(name: dto.name)
        number = dto.number
        module = dto.module
        moduleName = dto.moduleName
        volume = dto.volume
        gain1 = dto.gain1
        gain2 = dto.gain2
        masterVolume = dto.masterVolume
        treble = dto.treble
        middle = dto.middle
        bass = dto.bass
        presence = dto.presence
        depth = dto.depth
        bias = dto.bias
        noiseGate = dto.noiseGate
        threshold = dto.threshold
        sag = dto.sag
        brightness = dto.brightness
        cabinet = dto.cabinet
        cabinetName = dto.cabinetName
    }
    
}

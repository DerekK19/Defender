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
        effects = dto.effects.map { DXEffect(dto: $0) }
    }
    
    func copyInto(preset: inout DTOPreset?) {
        if preset != nil {
            preset!.volume = volume
            preset!.number = number
            preset!.module = module
            preset!.volume = volume
            preset!.gain1 = gain1
            preset!.gain2 = gain2
            preset!.masterVolume = masterVolume
            preset!.treble = treble
            preset!.middle = middle
            preset!.bass = bass
            preset!.presence = presence
            preset!.depth = depth
            preset!.bias = bias
            preset!.noiseGate = noiseGate
            preset!.threshold = threshold
            preset!.sag = sag
            preset!.brightness = brightness
            preset!.cabinet = cabinet
            preset!.cabinetName = cabinetName
            effects.forEach {
                let newEffect = $0
                for i in 0..<(preset?.effects.count ?? 0) {
                    if preset!.effects[i].slot == newEffect.slot {
                        newEffect.copyInto(effect: &preset!.effects[i])
                    }
                }
            }
        }
    }
}

//
//  AmpController.swift
//  Defender
//
//  Created by Derek Knight on 11/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa
import Mustang

class AmpController {
    
    private let mustang = Mustang(mockMode: true)
    
    private var amplifiers = [DTOAmplifier]()
    private var currentAmplifier: DTOAmplifier?
    private var presets = [UInt8 : DTOPreset] ()

    var hasAnAmplifier : Bool {
        get {
            return currentAmplifier != nil
        }
    }
    
    init() {
        presets = [UInt8 : DTOPreset] ()
        currentAmplifier = nil
        amplifiers = mustang.getConnectedAmplifiers()
        currentAmplifier = amplifiers.first
    }

    func getPresets(_ onCompletion: @escaping () -> ()) {
        if let amplifier = currentAmplifier {
            mustang.getPresets(amplifier) { (presets) in
                for preset in presets {
                    self.presets[preset.number] = preset
                }
                onCompletion()
            }
        }
    }
    
    open func getCachedPreset(_ preset: Int, onCompletion: @escaping (_ preset: DTOPreset?) ->()) {
        if let _ = currentAmplifier {
            if preset >= 0 && preset < presets.count {
                onCompletion(presets[UInt8(preset)])
            }
        }
    }

    open func getPreset(_ preset: Int, onCompletion: @escaping (_ preset: DTOPreset?) ->()) {
        if let amplifier = currentAmplifier {
            if preset >= 0 && preset < presets.count && presets[UInt8(preset)]?.gain1 != nil {
                onCompletion(presets[UInt8(preset)])
            } else {
                mustang.getPreset(
                    amplifier,
                    preset: UInt8(preset)) { (preset) in
                        DispatchQueue.main.async {
                            if let preset = preset {
                                self.presets[preset.number] = preset
                                if let _ = preset.gain1 {
                                    onCompletion(preset)
                                }
                            }
                        }
                }
            }
        }
    }

}

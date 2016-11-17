//
//  BOEffect.swift
//  Mustang
//
//  Created by Derek Knight on 3/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

struct BOEffect: DTOEffect {

    let type : DTOEffectType
    let module: Int
    var slot: Int
    var enabled: Bool
    var colour: Int
    var knobs: [DTOKnob]
    let name: String?
    var knobCount: Int
    let aValue1: Int
    let aValue2: Int
    let aValue3: Int

    private let _knobs: [BOKnob]

    init (dl: DLEffect) {
        module = Int(dl.module)
        slot = Int(dl.slot)
        enabled = Int(dl.enabled) == 0
        colour = Int(dl.colour)
        aValue1 = Int(dl.aValue1)
        aValue2 = Int(dl.aValue2)
        aValue3 = Int(dl.aValue3)
        knobs = BOKnob.convertArray(dl.knobs)
        _knobs = BOKnob.convertArray(dl.knobs)
        var nameTmp: String?
        var knobsTmp: Int = 0
        type = dl.type == ._Stomp ? .Stomp : (dl.type == ._Modulation ? .Modulation: (dl.type == ._Delay ? .Delay : .Reverb))
        if dl.type == ._Stomp { (nameTmp, knobsTmp) = BOEffect.stompName(module) }
        if dl.type == ._Modulation { (nameTmp, knobsTmp) = BOEffect.modulationName(module) }
        if dl.type == ._Delay { (nameTmp, knobsTmp) = BOEffect.delayName(module) }
        if dl.type == ._Reverb { (nameTmp, knobsTmp) = BOEffect.reverbName(module) }
        name = nameTmp
        knobCount = knobsTmp
    }

    static func convertArray(_ dls: [DLEffect]) -> [BOEffect] {
        return dls.map { BOEffect(dl: $0) }
    }

    var dataObject: DLEffect? {
        return DLEffect(withType: type == .Stomp ? ._Stomp : (type == .Modulation ? ._Modulation: (type == .Delay ? ._Delay : ._Reverb)),
                        andModule: module,
                        andSlot: UInt8(slot),
                        andEnabled: UInt8(enabled ? 0 : 1),
                        andKnobs: _knobs.map { $0.dataObject },
                        aValue1: UInt8(aValue1),
                        aValue2: UInt8(aValue2),
                        aValue3: UInt8(aValue3))
    }
    
    fileprivate static func stompName(_ module: Int?) -> (String?, Int) {
        if let module = module {
            switch module {
            case 0x3c00: return ("Overdrive", 5)
            case 0x4900: return ("Wah", 5)
            case 0x4a00: return ("Touch Wah", 5)
            case 0x1a00: return ("Fuzz", 5)
            case 0x1c00: return ("Fuzz Wah", 5)
            case 0x8800: return ("Simple Comp", 1)
            case 0x0700: return ("Compressor", 5)
            case 0x0301: return ("Ranger", 4)
            case 0xba00: return ("Greenbox", 4)
            case 0x1001: return ("Orangebox", 3)
            case 0x1101: return ("Blackbox", 3)
            case 0x0f01: return ("Big Fuzz", 3)
            default: break
            }
        }
        return (nil, 0)
    }
    
    fileprivate static func modulationName(_ module: Int?) -> (String?, Int) {
        if let module = module {
            switch module {
            case 0x1200: return ("Sine Chorus", 5)
            case 0x1300: return ("Tri Chorus", 5)
            case 0x1800: return ("Sine Flange", 5)
            case 0x1900: return ("Tri Flange", 5)
            case 0x2d00: return ("Vibratone", 5)
            case 0x4000: return ("VintageTrem", 5)
            case 0x4100: return ("Sine Trem", 5)
            case 0x2200: return ("Ring Mod", 5)
            case 0x2900: return ("Step Filt", 5)
            case 0x4f00: return ("Phaser", 5)
            case 0x1f00: return ("Pitch Shift", 5)
            case 0xf400: return ("Wah", 5)
            case 0xf500: return ("Touch Wah", 5)
            case 0x1f10: return ("Dia Pitch", 5)
            default: break
            }
        }
        return (nil, 0)
    }
    
    fileprivate static func delayName(_ module: Int?) -> (String?, Int) {
        if let module = module {
            switch module {
            case 0x1600: return ("Mono", 5)
            case 0x4300: return ("Mono Echo", 6)
            case 0x4800: return ("Stereo Echo", 6)
            case 0x4400: return ("Multi Tap", 5)
            case 0x4500: return ("Ping Pong", 5)
            case 0x1500: return ("Ducking", 5)
            case 0x4600: return ("Reverse", 5)
            case 0x2b00: return ("Tape", 6)
            case 0x2a00: return ("Stereo Tape", 6)
            default: break
            }
        }
        return (nil, 0)
    }
    
    fileprivate static func reverbName(_ module: Int?) -> (String?, Int) {
        if let module = module {
            switch module {
            case 0x2400: return ("Small Hall", 5)
            case 0x3a00: return ("Large Hall", 5)
            case 0x2600: return ("Small Room", 5)
            case 0x3b00: return ("Large Room", 5)
            case 0x4e00: return ("Small Plate", 5)
            case 0x4b00: return ("Large Plate", 5)
            case 0x4c00: return ("Ambient", 5)
            case 0x4d00: return ("Arena", 5)
            case 0x2100: return ("'63 Spring", 5)
            case 0x0b00: return ("'65 Spring", 5)
            default: break
            }
        }
        return (nil, 0)
    }
}

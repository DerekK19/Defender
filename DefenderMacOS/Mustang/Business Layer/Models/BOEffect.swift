//
//  BOEffect.swift
//  Mustang
//
//  Created by Derek Knight on 3/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

public enum EffectType : String {
    case Unknown = ""
    case Stomp = "Stomp Box"
    case Modulation = "Modulation"
    case Delay = "Delay"
    case Reverb = "Reverb"
}

struct BOEffect {

    let type : EffectType
    let module: Int
    var slot: Int
    var enabled: Bool
    var colour: Int
    var knobs: [BOKnob]
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
        type = dl.type == ._Stomp ? .Stomp : (dl.type == ._Modulation ? .Modulation: (dl.type == ._Delay ? .Delay : .Reverb))
        var nameTmp: String?
        var knobNamesTmp = [String]()
        if dl.type == ._Stomp { (nameTmp, knobNamesTmp) = BOEffect.stompName(module) }
        if dl.type == ._Modulation { (nameTmp, knobNamesTmp) = BOEffect.modulationName(module) }
        if dl.type == ._Delay { (nameTmp, knobNamesTmp) = BOEffect.delayName(module) }
        if dl.type == ._Reverb { (nameTmp, knobNamesTmp) = BOEffect.reverbName(module) }
        knobs = BOKnob.convertArray(dl.knobs, names: knobNamesTmp)
        _knobs = BOKnob.convertArray(dl.knobs)
        name = nameTmp
        knobCount = knobNamesTmp.count
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
    
    fileprivate static func stompName(_ module: Int?) -> (String?, [String]) {
        if let module = module {
            switch module {
            case 0x3c00: return ("Overdrive", ["Level", "Gain", "Low", "Mid", "High"])
            case 0x4900: return ("Wah", ["Mix", "Freq", "Heel Freq", "Toe Freq", "High Q"])
            case 0x4a00: return ("Touch Wah", ["Mix", "Sensitivity", "Min Freq", "Max Freq", "High Q"])
            case 0x1a00: return ("Fuzz", ["Level", "Gain", "Octave", "Low", "High"])
            case 0x1c00: return ("Fuzz Wah", ["Level", "Gain", "Sensitivity", "Octave", "Peak"])
            case 0x8800: return ("Simple Comp", ["Type"])
            case 0x0700: return ("Compressor", ["Level", "Threshold", "Ratio", "Attack", "Release"])
            case 0x0301: return ("Ranger", ["Level", "Gain", "Locut", "Bright"])
            case 0xba00: return ("Greenbox", ["Level", "Gain", "Tone", "Blend"])
            case 0x1001: return ("Orangebox", ["Level", "Dist", "Tone"])
            case 0x1101: return ("Blackbox", ["Level", "Distortion", "Filter"])
            case 0x0f01: return ("Big Fuzz", ["Level", "Tone", "Sustain"])
            default: break
            }
        }
        return (nil, [])
    }
    
    fileprivate static func modulationName(_ module: Int?) -> (String?, [String]) {
        if let module = module {
            switch module {
            case 0x1200: return ("Sine Chorus", ["Level", "Rate", "Depth", "Avg Delay", "LT Phase"])
            case 0x1300: return ("Tri Chorus", ["Level", "Rate", "Depth", "Avg Delay", "LT Phase"])
            case 0x1800: return ("Sine Flanger", ["Level", "Rate", "Depth", "Feedbacky", "LT Phase"])
            case 0x1900: return ("Tri Flanger", ["Level", "Rate", "Depth", "Feedbacky", "LT Phase"])
            case 0x2d00: return ("Vibratone", ["Level", "Rate", "Depth", "Feedbacky", "Rotor"])
            case 0x4000: return ("Vintage Trem", ["Level", "Rate", "Dut Cycle", "Attach", "Release"])
            case 0x4100: return ("Sine Trem", ["Level", "Rate", "Dut Cycle", "LFO Clip", "Shape"])
            case 0x2200: return ("Ring Mod", ["Level", "Frequency", "Depth", "Shape", "Phase"])
            case 0x2900: return ("Step Filt", ["Level", "Rate", "Resonance", "Min Freq", "Max Freq"])
            case 0x4f00: return ("Phaser", ["Level", "Rate", "Depth", "Feedback", "Shape"])
            case 0x1f00: return ("Pitch Shift", ["Mix", "Pitch", "Pre Delay", "Feedback", "Tone"])
            case 0xf400: return ("Wah", ["Mix", "Freq", "Heel Freq", "Toe Freq", "High Q"])
            case 0xf500: return ("Touch Wah", ["Mix", "Sensitivity", "Min Freq", "Max Freq", "High Q"])
            case 0x1f10: return ("Dia Pitch", ["Mix", "Pitch", "Key", "Scale", "Tone"])
            default: break
            }
        }
        return (nil, [])
    }
    
    fileprivate static func delayName(_ module: Int?) -> (String?, [String]) {
        if let module = module {
            switch module {
            case 0x1600: return ("Mono", ["Level", "Delay", "Feedback", "Bright", "Attenuation"])
            case 0x4300: return ("Mono Echo", ["Level", "Delay", "Feedback", "Frequency", "Level", "In Level"])
            case 0x4800: return ("Stereo Echo", ["Level", "Delay", "Feedback", "Frequency", "Level", "In Level"])
            case 0x4400: return ("Multi Tap", ["Level", "Delay", "Bright", "Mode", ""])
            case 0x4500: return ("Ping Pong", ["Level", "Delay", "Feedback", "Bright", ""])
            case 0x1500: return ("Ducking", ["Level", "Delay", "Feedback", "Release", "Threshold"])
            case 0x4600: return ("Reverse", ["Level", "Delay", "Feedback", "Tone", "Rev Feedback"])
            case 0x2b00: return ("Tape", ["Level", "Delay", "Feedback", "Bright", "Flutter", "Stereo"])
            case 0x2a00: return ("Stereo Tape", ["Level", "Delay", "Feedback", "Bright", "Flutter", "Stereo"])
            default: break
            }
        }
        return (nil, [])
    }
    
    fileprivate static func reverbName(_ module: Int?) -> (String?, [String]) {
        if let module = module {
            switch module {
            case 0x2400: return ("Small Hall", ["Level", "Decay", "Dwell", "Diffusion", "Tone"])
            case 0x3a00: return ("Large Hall", ["Level", "Decay", "Dwell", "Diffusion", "Tone"])
            case 0x2600: return ("Small Room", ["Level", "Decay", "Dwell", "Diffusion", "Tone"])
            case 0x3b00: return ("Large Room", ["Level", "Decay", "Dwell", "Diffusion", "Tone"])
            case 0x4e00: return ("Small Plate", ["Level", "Decay", "Dwell", "Diffusion", "Tone"])
            case 0x4b00: return ("Large Plate", ["Level", "Decay", "Dwell", "Diffusion", "Tone"])
            case 0x4c00: return ("Ambient", ["Level", "Decay", "Dwell", "Diffusion", "Tone"])
            case 0x4d00: return ("Arena", ["Level", "Decay", "Dwell", "Diffusion", "Tone"])
            case 0x2100: return ("'63 Spring", ["Level", "Decay", "Dwell", "Diffusion", "Tone"])
            case 0x0b00: return ("'65 Spring", ["Level", "Decay", "Dwell", "Diffusion", "Tone"])
            default: break
            }
        }
        return (nil, [])
    }
}

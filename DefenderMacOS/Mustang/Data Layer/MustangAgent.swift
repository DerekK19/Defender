//
//  MustangAgent.swift
//  Mustang
//
//  Created by Derek Knight on 11/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

internal class MustangAgent {
    
    /*
     See the file fender_mustang_protocol.txt for details of the amplifier interface
     */
    
    // MARK: Serialization functions
    internal class func serialize(_ data: [[UInt8]], forAmplifier amplifier: DLAmplifier, intoPresets presets: inout [DLPreset]) {
        for setting in data {
            if setting[0] == 0x1c && (setting[1] == 0x01 || setting[1] == 0x03) {
                switch setting[2] {
                case 0x04:
                    // Preset name
                    let number = setting[4]
                    if presets.filter({ $0.number == number }).count == 0 {
                        let current = setting[6] == 0x01
                        if let name = String(bytes: Array(setting[16...48]), encoding: String.Encoding.utf8)?.trimmingCharacters(in: CharacterSet.init(charactersIn: "\0")) {
                            let preset = DLPreset(withAmplifier: amplifier, number: number, name: name, current: current)
                            preset.fuse = DLFuse(withInfo: DLInfo(withName: name, author: "Defender", rating: 0, genre1: -1, genre2: -1, genre3: -1, tags: "", fenderid: 0))
                            presets.append(preset)
                        }
                    }
                case 0x05:
                    // AMP Settings
                    let number = setting[4]
                    if presets.filter({ $0.number == number }).count == 0 {
                        let preset = DLPreset(withAmplifier: amplifier, number: number, name: nil, current: true)
                        preset.fuse = DLFuse(withInfo: DLInfo(withName: "No Name", author: "Defender", rating: 0, genre1: -1, genre2: -1, genre3: -1, tags: "", fenderid: 0))
                        presets.append(preset)
                    }
                    if let preset = presets.filter({ $0.number == number }).first {
                        preset.module = Int(setting[16])
                        preset.volume = Int(setting[32])
                        preset.gain1 = Int(setting[33])
                        preset.gain2 = Int(setting[34])
                        preset.masterVolume = Int(setting[35])
                        preset.treble = Int(setting[36])
                        preset.middle = Int(setting[37])
                        preset.bass = Int(setting[38])
                        preset.presence = Int(setting[39])
                        preset.unknown1 = UInt8(setting[40])
                        preset.depth = Int(setting[41])
                        preset.bias = Int(setting[42])
                        preset.unknown2 = UInt8(setting[43])
                        preset.unknown3 = UInt8(setting[44])
                        preset.unknown4 = UInt8(setting[45])
                        preset.unknown5 = UInt8(setting[46])
                        preset.noiseGate = Int(setting[47])
                        preset.threshold = Int(setting[48])
                        preset.cabinet = Int(setting[49])
                        preset.unknown6 = UInt8(setting[50])
                        preset.sag = Int(setting[51])
                        preset.brightness = Int(setting[52])
                        preset.unknown7 = UInt8(setting[53])
                        preset.unknown8 = UInt8(setting[54])
                        preset.effects = [DLEffect]()
                        preset.band = DLBand(withType: 0, iRepeat: 0, audioMix: 0, balance: 29127, speed: 100, pitch: 0, songFile: DLSongFile(withLocation: 6, name: "No Band"))
                    }
                case 0x06:
                    // Stomp settings
                    let number = setting[4]
                    if let preset = presets.filter({ $0.number == number }).first {
                        let module = Int(UInt16(byte1: setting[16], byte2: setting[17]))
                        if module != 0 {
                            let enabled = setting[22]
                            let slot = setting[18]
                            var knobs = [DLKnob]()
                            for index in 32...37 {
                                knobs.append(DLKnob(withValue: Int(setting[index])))
                            }
                            preset.effects.append(DLEffect(withType: ._Stomp, andModule: module, andSlot: slot, andEnabled: enabled, andKnobs: knobs, aValue1: setting[19], aValue2: setting[20], aValue3: setting[21]))
                        }
                    }
                    continue
                case 0x07:
                    // Mod settings
                    let number = setting[4]
                    if let preset = presets.filter({ $0.number == number }).first {
                        let module = Int(UInt16(byte1: setting[16], byte2: setting[17]))
                        if module != 0 {
                            let enabled = setting[22]
                            let slot = setting[18]
                            var knobs = [DLKnob]()
                            for index in 32...37 {
                                knobs.append(DLKnob(withValue: Int(setting[index])))
                            }
                            preset.effects.append(DLEffect(withType: ._Modulation, andModule: module, andSlot: slot, andEnabled: enabled, andKnobs: knobs, aValue1: setting[19], aValue2: setting[20], aValue3: setting[21]))
                        }
                    }
                    continue
                case 0x08:
                    // Delay settings
                    let number = setting[4]
                    if let preset = presets.filter({ $0.number == number }).first {
                        let module = Int(UInt16(byte1: setting[16], byte2: setting[17]))
                        if module != 0 {
                            let enabled = setting[22]
                            let slot = setting[18]
                            var knobs = [DLKnob]()
                            for index in 32...37 {
                                knobs.append(DLKnob(withValue: Int(setting[index])))
                            }
                            preset.effects.append(DLEffect(withType: ._Delay, andModule: module, andSlot: slot, andEnabled: enabled, andKnobs: knobs, aValue1: setting[19], aValue2: setting[20], aValue3: setting[21]))
                        }
                    }
                    continue
                case 0x09:
                    // Reverb settings
                    let number = setting[4]
                    if let preset = presets.filter({ $0.number == number }).first {
                        let module = Int(UInt16(byte1: setting[16], byte2: setting[17]))
                        if module != 0 {
                            let enabled = setting[22]
                            let slot = setting[18]
                            var knobs = [DLKnob]()
                            for index in 32...37 {
                                knobs.append(DLKnob(withValue: Int(setting[index])))
                            }
                            preset.effects.append(DLEffect(withType: ._Reverb, andModule: module, andSlot: slot, andEnabled: enabled, andKnobs: knobs, aValue1: setting[19], aValue2: setting[20], aValue3: setting[21]))
                        }
                    }
                    continue
                case 0x0a:
                    // Exp pedal settings
                    continue
                default: continue
                }
            }
        }
    }
    
    internal class func serialize(_ data: [[UInt8]], intoMessage message: inout String) {
        for setting in data {
            if setting[0] == 0x00 && setting[1] == 0x00 && setting[2] == 0x1c && setting[3] == 0x00 {
                message = String(bytes: Array(setting[4...15]), encoding: String.Encoding.utf8)?.trimmingCharacters(in: CharacterSet.init(charactersIn: "\0")) ?? ""
            }
        }
    }
    
    internal class func deserialize(_ preset: DLPreset, update: Bool) -> [[UInt8]] {
        let header:[UInt8] = [0x1c, update ? 0x03 : 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01]
        var record04:[UInt8] = header + [UInt8](repeating: 0, count: 56)
        record04[2] = 0x04
        let name = preset.name ?? ""
        let data = name.data(using: String.Encoding.utf8)
        (data as NSData?)?.getBytes(&record04[16], length: min(33, data?.count ?? 0))
        var record05:[UInt8] = header + [UInt8](repeating: 0, count: 56)
        record05[2] = 0x05
        record05[16] = UInt8(preset.module)
        record05[32] = UInt8(preset.volume)
        record05[33] = UInt8(preset.gain1)
        record05[34] = UInt8(preset.gain2)
        record05[35] = UInt8(preset.masterVolume)
        record05[36] = UInt8(preset.treble)
        record05[37] = UInt8(preset.middle)
        record05[38] = UInt8(preset.bass)
        record05[39] = UInt8(preset.presence)
        record05[40] = UInt8(preset.unknown1)
        record05[41] = UInt8(preset.depth)
        record05[42] = UInt8(preset.bias)
        record05[43] = UInt8(preset.unknown2)
        record05[44] = UInt8(preset.unknown3)
        record05[45] = UInt8(preset.unknown4)
        record05[46] = UInt8(preset.unknown5)
        record05[47] = UInt8(preset.noiseGate)
        record05[48] = UInt8(preset.threshold)
        record05[49] = UInt8(preset.cabinet)
        record05[50] = UInt8(preset.unknown6)
        record05[51] = UInt8(preset.sag)
        record05[52] = UInt8(preset.brightness)
        record05[53] = UInt8(preset.unknown7)
        record05[54] = UInt8(preset.unknown8)
        var record06:[UInt8] = header + [UInt8](repeating: 0, count: 56)
        record06[2] = 0x06
        if let effect = preset.effects.filter({ $0.type == ._Stomp }).first {
            record06[16] = UInt8((effect.module ?? 0) >> 8 & 0x00ff)
            record06[17] = UInt8((effect.module ?? 0) & 0x00ff)
            record06[18] = effect.slot
            record06[19] = effect.aValue1
            record06[20] = effect.aValue2
            record06[21] = effect.aValue3
            record06[22] = effect.enabled
            if effect.knobs.count > 0 { record06[32] = UInt8(effect.knobs[0].value) }
            if effect.knobs.count > 1 { record06[33] = UInt8(effect.knobs[1].value) }
            if effect.knobs.count > 2 { record06[34] = UInt8(effect.knobs[2].value) }
            if effect.knobs.count > 3 { record06[35] = UInt8(effect.knobs[3].value) }
            if effect.knobs.count > 4 { record06[36] = UInt8(effect.knobs[4].value) }
            if effect.knobs.count > 5 { record06[37] = UInt8(effect.knobs[5].value) }
        }
        var record07:[UInt8] = header + [UInt8](repeating: 0, count: 56)
        record07[2] = 0x07
        if let effect = preset.effects.filter({ $0.type == ._Modulation }).first {
            record07[16] = UInt8((effect.module ?? 0) >> 8 & 0x00ff)
            record07[17] = UInt8((effect.module ?? 0) & 0x00ff)
            record07[18] = effect.slot
            record07[19] = effect.aValue1
            record07[20] = effect.aValue2
            record07[21] = effect.aValue3
            record07[22] = effect.enabled
            if effect.knobs.count > 0 { record07[32] = UInt8(effect.knobs[0].value) }
            if effect.knobs.count > 1 { record07[33] = UInt8(effect.knobs[1].value) }
            if effect.knobs.count > 2 { record07[34] = UInt8(effect.knobs[2].value) }
            if effect.knobs.count > 3 { record07[35] = UInt8(effect.knobs[3].value) }
            if effect.knobs.count > 4 { record07[36] = UInt8(effect.knobs[4].value) }
            if effect.knobs.count > 5 { record07[37] = UInt8(effect.knobs[5].value) }
        }
        var record08:[UInt8] = header + [UInt8](repeating: 0, count: 56)
        record08[2] = 0x08
        if let effect = preset.effects.filter({ $0.type == ._Delay }).first {
            record08[16] = UInt8((effect.module ?? 0) >> 8 & 0x00ff)
            record08[17] = UInt8((effect.module ?? 0) & 0x00ff)
            record08[18] = effect.slot
            record08[19] = effect.aValue1
            record08[20] = effect.aValue2
            record08[21] = effect.aValue3
            record08[22] = effect.enabled
            if effect.knobs.count > 0 { record08[32] = UInt8(effect.knobs[0].value) }
            if effect.knobs.count > 1 { record08[33] = UInt8(effect.knobs[1].value) }
            if effect.knobs.count > 2 { record08[34] = UInt8(effect.knobs[2].value) }
            if effect.knobs.count > 3 { record08[35] = UInt8(effect.knobs[3].value) }
            if effect.knobs.count > 4 { record08[36] = UInt8(effect.knobs[4].value) }
            if effect.knobs.count > 5 { record08[37] = UInt8(effect.knobs[5].value) }
        }
        var record09:[UInt8] = header + [UInt8](repeating: 0, count: 56)
        record09[2] = 0x09
        if let effect = preset.effects.filter({ $0.type == ._Reverb }).first {
            record09[16] = UInt8((effect.module ?? 0) >> 8 & 0x00ff)
            record09[17] = UInt8((effect.module ?? 0) & 0x00ff)
            record09[18] = effect.slot
            record09[19] = effect.aValue1
            record09[20] = effect.aValue2
            record09[21] = effect.aValue3
            record09[22] = effect.enabled
            if effect.knobs.count > 0 { record09[32] = UInt8(effect.knobs[0].value) }
            if effect.knobs.count > 1 { record09[33] = UInt8(effect.knobs[1].value) }
            if effect.knobs.count > 2 { record09[34] = UInt8(effect.knobs[2].value) }
            if effect.knobs.count > 3 { record09[35] = UInt8(effect.knobs[3].value) }
            if effect.knobs.count > 4 { record09[36] = UInt8(effect.knobs[4].value) }
            if effect.knobs.count > 5 { record09[37] = UInt8(effect.knobs[5].value) }
        }
        var record0a:[UInt8] = header + [UInt8](repeating: 0, count: 56)
        record0a[2] = 0x0a
        return [record04, record05, record06, record07, record08, record09, record0a]
    }
    
    internal class func deserialize(_ preset: UInt8, update: Bool) -> [UInt8]  {
        let header:[UInt8] = [0x1c, 0x01, update ? 0x03 : 0x01, 0x00, preset, 0x00, 0x01]
        let record:[UInt8] = header + [UInt8](repeating: 0, count: 57)
        return record
    }
    
    internal class func deserialize(_ preset: UInt8, andName name: String, update: Bool) -> [UInt8]  {
        let header:[UInt8] = [0x1c, 0x01, update ? 0x03 : 0x01, 0x00, preset, 0x00, 0x01, 0x01]
        var record:[UInt8] = header + [UInt8](repeating: 0, count: 56)
        let data = name.data(using: String.Encoding.utf8)
        (data as NSData?)?.getBytes(&record[16], length: min(33, data?.count ?? 0))
        return record
    }
}

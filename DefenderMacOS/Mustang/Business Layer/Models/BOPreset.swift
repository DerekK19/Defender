//
//  BOPreset.swift
//  Mustang
//
//  Created by Derek Knight on 6/08/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

struct BOPreset {
    var amplifier: BOAmplifier?
    var _amplifier: BOAmplifier?
    var number: UInt8?
    var name: String?
    let current: Bool
    var module: Int?
    var moduleName: String?
    var volume: Float?
    var gain1: Float?
    var gain2: Float?
    var masterVolume: Float?
    var treble: Float?
    var middle: Float?
    var bass: Float?
    var presence: Float?
    var depth: Int?
    var bias: Int?
    var noiseGate: Int?
    var threshold: Int?
    var cabinet: Int?
    var cabinetName: String?
    var sag: Int?
    var brightness: Int?
    var unknown1: UInt8?
    var unknown2: UInt8?
    var unknown3: UInt8?
    var unknown4: UInt8?
    var unknown5: UInt8?
    var unknown6: UInt8?
    var unknown7: UInt8?
    var unknown8: UInt8?
    var effects: [BOEffect]
    var band: BOBand?
    var fuse: BOFuse?

    private var _effects: [BOEffect]
    private var _band: BOBand?
    private var _fuse: BOFuse?

    var debugDescription: String {
        var text = "\n"
        if let number = number {
            text += String(format:"  Preset %d - %@\n", number, name ?? "-unknown-")
        } else {
            text += String(format:"  Preset -unknown- - %@\n", name ?? "-unknown-")
        }
        if let gain = gain1 {
            text += String(format: "   Gain: %0.2f\n", gain)
        } else {
            text += "   Gain: -unset-\n"
        }
        if let volume = volume {
            text += String(format: "   Volume: %0.2f\n", volume)
        } else {
            text += "   Volume: -unset-\n"
        }
        if let treble = treble {
            text += String(format: "   Treble: %0.2f\n", treble)
        } else {
            text += "   Treble: -unset-\n"
        }
        if let middle = middle {
            text += String(format: "   Middle: %0.2f\n", middle)
        } else {
            text += "   Middle: -unset-\n"
        }
        if let bass = bass {
            text += String(format: "   Bass: %0.2f\n", bass)
        } else {
            text += "   Bass: -unset-\n"
        }
        if let presence = presence {
            text += String(format: "   Reverb/Presence: %0.2f\n", presence)
        } else {
            text += "   Reverb/Presence: -unset-\n"
        }
        text += String(format: "   Model: %@\n", moduleName ?? "-unknown-")
        text += String(format: "   Cabinet: %@\n", cabinetName ?? "-unknown-")
        for effect in effects {
            text += String(format: "   %@: %@ - %@ (colour %d)\n", effect.type.rawValue, effect.name ?? "-empty-", effect.enabled ? "ON" : "OFF", effect.colour)
            text += String(format: "    Knobs: %d - ", effect.knobs.count)
            effect.knobs.forEach { text += String(format: "%0.2f ", $0.value) }
            text += String(format: "slot %d (%d %d %d)\n", effect.slot, effect.aValue1, effect.aValue2, effect.aValue3)
        }
        return text
    }
    
    init(dl: DLPreset) {
        if let dlAmplifier  = dl.amplifier {
            self.amplifier = BOAmplifier(dl: dlAmplifier)
            self._amplifier = BOAmplifier(dl: dlAmplifier)
        }
        self.number = dl.number
        self.name = dl.name
        self.current = dl.current
        self.module = dl.module
        self.effects = BOEffect.convertArray(dl.effects)
        self._effects = BOEffect.convertArray(dl.effects)
        self.moduleName = moduleName(dl.module)
        self.volume = float(dl.volume)
        self.gain1 = float(dl.gain1)
        self.gain2 = float(dl.gain2)
        self.masterVolume = float(dl.masterVolume)
        self.treble = float(dl.treble)
        self.middle = float(dl.middle)
        self.bass = float(dl.bass)
        self.presence = float(dl.presence)
        self.depth = dl.depth
        self.bias = dl.bias
        self.noiseGate = dl.noiseGate
        self.threshold = dl.threshold
        self.cabinet = dl.cabinet
        self.cabinetName = cabinetName(dl.cabinet)
        self.sag = dl.sag
        self.brightness = dl.brightness
        self.unknown1 = dl.unknown1
        self.unknown2 = dl.unknown2
        self.unknown3 = dl.unknown3
        self.unknown4 = dl.unknown4
        self.unknown5 = dl.unknown5
        self.unknown6 = dl.unknown6
        self.unknown7 = dl.unknown7
        self.unknown8 = dl.unknown8
        if let dlBand = dl.band {
            self.band = BOBand(dl: dlBand)
            self._band = BOBand(dl: dlBand)
        }
        if let dlFuse = dl.fuse {
            self.fuse = BOFuse(dl: dlFuse)
            self._fuse = BOFuse(dl: dlFuse)
        }
    }
    
    static func convertArray(_ dls: [DLPreset]) -> [BOPreset] {
        return dls.map { BOPreset(dl: $0) }
    }
    
    var dataObject: DLPreset {
        return DLPreset(withAmplifier: _amplifier?.dataObject,
                        number: number,
                        name: name,
                        current: current,
                        module: module ?? 0,
                        volume: int(volume) ?? 0,
                        gain1: int(gain1) ?? 0,
                        gain2: int(gain2) ?? 0,
                        masterVolume: int(masterVolume) ?? 0,
                        treble: int(treble) ?? 0,
                        middle: int(middle) ?? 0,
                        bass: int(bass) ?? 0,
                        presence: int(presence) ?? 0,
                        depth: depth ?? 0,
                        bias: bias ?? 0,
                        noiseGate: noiseGate ?? 0,
                        threshold: threshold ?? 0,
                        cabinet: cabinet ?? 0,
                        sag: sag ?? 0,
                        brightness: brightness ?? 0,
                        unknown1: unknown1 ?? 0,
                        unknown2: unknown2 ?? 0,
                        unknown3: unknown3 ?? 0,
                        unknown4: unknown4 ?? 0,
                        unknown5: unknown5 ?? 0,
                        unknown6: unknown6 ?? 0,
                        unknown7: unknown7 ?? 0,
                        unknown8: unknown8 ?? 0,
                        effects: _effects.map { $0.dataObject! },
                        band: _band?.dataObject,
                        fuse: _fuse?.dataObject)
    }

    fileprivate func float(_ int: Int?) -> Float? {
        return int == nil ? nil : ((Float(int!) / 256.0 * 9.0) + 1.0)
    }
    
    fileprivate func int(_ float: Float?) -> Int? {
        return float == nil ? nil : Int((float! - 1.0) * 256.0 / 9.0)
    }
    
    fileprivate func moduleName(_ module: Int?) -> String? {
        if let module = module {
            switch module {
            case 0x67: return "'57 Deluxe"
            case 0x64: return "'59 Bassman"
            case 0x7c: return "'57 Champ"
            case 0x53: return "'65 Deluxe"
            case 0x6a: return "'65 Princeton"
            case 0x75: return "'65 Twin"
            case 0x72: return "Super-Sonic"
            case 0x61: return "British '60s"
            case 0x79: return "British '70s"
            case 0x5e: return "British '80s"
            case 0x5d: return "American '90s"
            case 0x6d: return "Metal 2000"
            case 0xf1: return "Studio Pre"
            case 0xf6: return "'57 Twin"
            case 0xf9: return "'60s Thrift"
            case 0xfc: return "Brit Colour"
            case 0xff: return "Brit Watts"
            default: return nil
            }
        }
        return nil
    }
    
    fileprivate func cabinetName(_ cabinet: Int?) -> String? {
        if let cabinet = cabinet {
            switch cabinet {
            case 0x00: return "off"
            case 0x01: return "1x10 Modern"
            case 0x02: return "2x10 Modern"
            case 0x03: return "4x10 Modern"
            case 0x04: return "4x10 Hi-Fi"
            case 0x05: return "8x10 Modern"
            case 0x06: return "8x10 Vintage"
            case 0x07: return "1x12 Modern"
            case 0x08: return "2x15 Vintage"
            case 0x09: return "4x12 Modern"
            case 0x0a: return "1x15 Vintage"
            case 0x0b: return "1x15 Modern"
            case 0x0c: return "1x18 Vintage"
            case 0x0d: return "4x10 Vintage"
            default: return nil
            }
        }
        return nil
    }
}

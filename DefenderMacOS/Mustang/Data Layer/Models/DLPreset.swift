//
//  DLPreset.swift
//  Mustang
//
//  Created by Derek Knight on 6/08/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

enum DataLayerError: Error {
    case invalidXML
}

class DLPreset: Mappable {
    
    var amplifier: DLAmplifier?
    var number: UInt8?
    var name: String!
    var current: Bool!
    var module: Int!
    var volume: Int!
    var gain1: Int!
    var gain2: Int!
    var masterVolume: Int!
    var treble: Int!
    var middle: Int!
    var bass: Int!
    var presence: Int!
    var depth: Int!
    var bias: Int!
    var noiseGate: Int!
    var threshold: Int!
    var cabinet: Int!
    var sag: Int!
    var brightness: Int!
    var unknown1: UInt8!
    var unknown2: UInt8!
    var unknown3: UInt8!
    var unknown4: UInt8!
    var unknown5: UInt8!
    var unknown6: UInt8!
    var unknown7: UInt8!
    var unknown8: UInt8!
    var effects: [DLEffect]!
    var band: DLBand?
    var fuse: DLFuse?
    var usbGain: Int!
    var expressionPedal: DLExpressionPedal?

    required init?(map: Map) {
        mapping(map: map)
    }
    
    init(withAmplifier amplifier: DLAmplifier?, number: UInt8?, name: String, current: Bool) {
        self.amplifier = amplifier
        self.number = number
        self.name = name
        self.current = current
        self.effects = [DLEffect]()
        self.usbGain = 0
    }
    
    convenience init(withAmplifier amplifier: DLAmplifier?, number: UInt8?, name: String, current: Bool, module: Int, volume: Int, gain1: Int, gain2: Int, masterVolume: Int, treble: Int, middle: Int, bass: Int, presence: Int, depth: Int, bias: Int, noiseGate: Int, threshold: Int, cabinet: Int, sag: Int, brightness: Int, unknown1: UInt8, unknown2: UInt8, unknown3: UInt8, unknown4: UInt8, unknown5: UInt8, unknown6: UInt8, unknown7: UInt8, unknown8: UInt8, effects: [DLEffect], band: DLBand?, fuse: DLFuse?) {
        self.init(withAmplifier: amplifier, number: number, name: name, current: current)
        self.module = module
        self.volume = volume
        self.gain1 = gain1
        self.gain2 = gain2
        self.masterVolume = masterVolume
        self.treble = treble
        self.middle = middle
        self.bass = bass
        self.presence = presence
        self.depth = depth
        self.bias = bias
        self.noiseGate = noiseGate
        self.threshold = threshold
        self.cabinet = cabinet
        self.sag = sag
        self.brightness = brightness
        self.unknown1 = unknown1
        self.unknown2 = unknown2
        self.unknown3 = unknown3
        self.unknown4 = unknown4
        self.unknown5 = unknown5
        self.unknown6 = unknown6
        self.unknown7 = unknown7
        self.unknown8 = unknown8
        self.effects = effects
        self.band = band
        self.fuse = fuse
    }

    init(xml document: XMLDocument) throws {
        if let root = document.rootElement() {
            self.number = nil
            self.current = false
            self.effects = [DLEffect]()
            self.usbGain = root.elements(forName: "UsbGain").first?.intValue
            if let bandElement = root.elements(forName: "Band").first {
                self.band = DLBand(withElement: bandElement)
            }
            if let fuseElement = root.elements(forName: "FUSE").first {
                self.fuse = DLFuse(withElement: fuseElement)
            }
            if let expressionPedalElement = root.elements(forName: "FirstExpressionPedal").first {
                self.expressionPedal = DLExpressionPedal(withElement: expressionPedalElement)
            }
            self.name = self.fuse?.info?.name ?? "Preset"
            if let amp = root.elements(forName: "Amplifier").first {
                if let module = amp.elements(forName: "Module").first {
                    if let id = module.attribute(forName: "ID")?.intValue {
                        self.module = id
                    }
                    for param in module.elements(forName: "Param") {
                        if let index = param.attribute(forName: "ControlIndex")?.intValue {
                            if let value = param.intValue {
                                let uValue = UInt8(value & 0xff)
                                let shiftRightValue = value >> 8
                                let uShiftRightValue = UInt8(shiftRightValue)
                                switch index {
                                case 0: self.volume = shiftRightValue
                                case 1: self.gain1 = shiftRightValue
                                case 2: self.gain2 = shiftRightValue
                                case 3: self.masterVolume = shiftRightValue
                                case 4: self.treble = shiftRightValue
                                case 5: self.middle = shiftRightValue
                                case 6: self.bass = shiftRightValue
                                case 7: self.presence = shiftRightValue
                                case 8: self.unknown1 = uShiftRightValue
                                case 9: self.depth = shiftRightValue
                                case 10: self.bias = shiftRightValue
                                case 11: self.unknown2 = uShiftRightValue
                                case 12: self.unknown3 = uValue
                                case 13: self.unknown4 = uValue
                                case 14: self.unknown5 = uValue
                                case 15: self.noiseGate = value
                                case 16: self.threshold = value
                                case 17: self.cabinet = value
                                case 18: self.unknown6 = uValue
                                case 19: self.sag = value
                                case 20: self.brightness = value
                                case 21: self.unknown7 = uValue
                                case 22: self.unknown8 = uValue
                                default:
                                    NSLog("Param: \(param)")
                                    NSLog("Can't process preset control index \(index) - value '\(String(describing: param.stringValue))'")
                                }
                            }
                        }
                    }
                }
            }
            if let fx = root.elements(forName: "FX").first {
                if let stomp = fx.elements(forName: "Stompbox").first {
                    let effect = DLEffect(withType: ._Stomp, element: stomp)
                    if effect.knobs.count > 0 {
                        self.effects.append(effect)
                    }
                }
                if let mod = fx.elements(forName: "Modulation").first {
                    let effect = DLEffect(withType: ._Modulation, element: mod)
                    if effect.knobs.count > 0 {
                        self.effects.append(effect)
                    }
                }
                if let delay = fx.elements(forName: "Delay").first {
                    let effect = DLEffect(withType: ._Delay, element: delay)
                    if effect.knobs.count > 0 {
                        self.effects.append(effect)
                    }
                }
                if let reverb = fx.elements(forName: "Reverb").first {
                    let effect = DLEffect(withType: ._Reverb, element: reverb)
                    if effect.knobs.count > 0 {
                        self.effects.append(effect)
                    }
                }
            }
            return
        }
        throw DataLayerError.invalidXML

    }
    
    func xml() -> XMLDocument {
        let doc = XMLDocument()
        let preset = XMLElement(name: "Preset")
        preset.addAttribute(XMLNode.attribute(withName: "amplifier", stringValue: amplifier?.product ?? "Unknown Mustang") as! XMLNode)
        preset.addAttribute(XMLNode.attribute(withName: "ProductID", stringValue: "\(amplifier?.productId ?? 0)") as! XMLNode)
        let amp = XMLElement(name: "Amplifier")
        let module = XMLElement(name: "Module")
        module.addAttribute(XMLNode.attribute(withName: "ID", stringValue: "\(self.module!)") as! XMLNode)
        module.addAttribute(XMLNode.attribute(withName: "POS", stringValue: "0") as! XMLNode)
        module.addAttribute(XMLNode.attribute(withName: "BypassState", stringValue: "1") as! XMLNode)
        module.addChild(name: "Param", value: self.volume << 8, attributes: ["ControlIndex" : "0"])
        module.addChild(name: "Param", value: self.gain1 << 8, attributes: ["ControlIndex" : "1"])
        module.addChild(name: "Param", value: self.gain2 << 8, attributes: ["ControlIndex" : "2"])
        module.addChild(name: "Param", value: self.masterVolume << 8, attributes: ["ControlIndex" : "3"])
        module.addChild(name: "Param", value: self.treble << 8, attributes: ["ControlIndex" : "4"])
        module.addChild(name: "Param", value: self.middle << 8, attributes: ["ControlIndex" : "5"])
        module.addChild(name: "Param", value: self.bass << 8, attributes: ["ControlIndex" : "6"])
        module.addChild(name: "Param", value: self.presence << 8, attributes: ["ControlIndex" : "7"])
        module.addChild(name: "Param", value: Int(self.unknown1) << 8, attributes: ["ControlIndex" : "8"])
        module.addChild(name: "Param", value: self.depth << 8, attributes: ["ControlIndex" : "9"])
        module.addChild(name: "Param", value: self.bias << 8, attributes: ["ControlIndex" : "10"])
        module.addChild(name: "Param", value: Int(self.unknown2) << 8, attributes: ["ControlIndex" : "11"])
        module.addChild(name: "Param", value: Int(self.unknown3), attributes: ["ControlIndex" : "12"])
        module.addChild(name: "Param", value: Int(self.unknown4), attributes: ["ControlIndex" : "13"])
        module.addChild(name: "Param", value: Int(self.unknown5), attributes: ["ControlIndex" : "14"])
        module.addChild(name: "Param", value: self.noiseGate as Any, attributes: ["ControlIndex" : "15"])
        module.addChild(name: "Param", value: self.threshold as Any, attributes: ["ControlIndex" : "16"])
        module.addChild(name: "Param", value: self.cabinet as Any, attributes: ["ControlIndex" : "17"])
        module.addChild(name: "Param", value: Int(self.unknown6), attributes: ["ControlIndex" : "18"])
        module.addChild(name: "Param", value: self.sag as Any, attributes: ["ControlIndex" : "19"])
        module.addChild(name: "Param", value: self.brightness as Any, attributes: ["ControlIndex" : "20"])
        module.addChild(name: "Param", value: Int(self.unknown7), attributes: ["ControlIndex" : "21"])
        module.addChild(name: "Param", value: Int(self.unknown8), attributes: ["ControlIndex" : "22"])
        amp.addChild(module)
        preset.addChild(amp)
        let effects = XMLElement(name: "FX")
        effects.addChild(xmlForEffect(ofType: ._Stomp))
        effects.addChild(xmlForEffect(ofType: ._Modulation))
        effects.addChild(xmlForEffect(ofType: ._Delay))
        effects.addChild(xmlForEffect(ofType: ._Reverb))
        preset.addChild(effects)
        if let band = band { preset.addChild(band.xml()) }
        if let fuse = fuse { preset.addChild(fuse.xml()) }
        if let expressionPedal = expressionPedal { preset.addChild(expressionPedal.xml()) }
        preset.addChild(name: "UsbGain", value: usbGain as Any, attributes: [:])
        doc.addChild(preset)
        
        return doc
    }
    
    private func xmlForEffect(ofType type: DLEffectType) -> XMLElement {
        let module = XMLElement(name: "Module")
        var id: String = "0"
        var pos: String? = nil
        for oneEffect in self.effects {
            if oneEffect.type != type { continue }
            id = "\(oneEffect.module! >> 8)"
            pos = "\(oneEffect.slot!)"
            var index = 0
            for knob in oneEffect.knobs {
                module.addChild(name: "Param", value: knob.value << 8, attributes: ["ControlIndex" : "\(index)"])
                index += 1
            }
            break
        }
        var effect: XMLElement!
        switch type as DLEffectType {
        case ._Stomp:
            effect = XMLElement(name: "Stompbox")
            pos = pos ?? "5"
        case ._Modulation:
            effect = XMLElement(name: "Modulation")
            pos = pos ?? "5"
        case ._Delay:
            effect = XMLElement(name: "Delay")
            pos = pos ?? "6"
        case ._Reverb:
            effect = XMLElement(name: "Reverb")
            pos = pos ?? "7"
        }
        effect.addAttribute(XMLNode.attribute(withName: "ID", stringValue: "\(type.rawValue)") as! XMLNode)
        module.addAttribute(XMLNode.attribute(withName: "ID", stringValue: id) as! XMLNode)
        module.addAttribute(XMLNode.attribute(withName: "POS", stringValue: pos!) as! XMLNode)
        module.addAttribute(XMLNode.attribute(withName: "BypassState", stringValue: "1") as! XMLNode)
        effect.addChild(module)

        return effect
    }
    
    func mapping(map: Map) {
        amplifier        <- map["amplifier"]
        number           <- map["number"]
        name             <- map["name"]
        current          <- map["current"]
        module           <- map["module"]
        volume           <- map["volume"]
        gain1            <- map["gain1"]
        gain2            <- map["gain2"]
        masterVolume     <- map["masterVolume"]
        treble           <- map["treble"]
        middle           <- map["middle"]
        bass             <- map["bass"]
        presence         <- map["presence"]
        depth            <- map["depth"]
        bias             <- map["bias"]
        noiseGate        <- map["noiseGate"]
        threshold        <- map["threshold"]
        sag              <- map["sag"]
        brightness       <- map["brightness"]
        unknown1         <- map["unknown1"]
        unknown2         <- map["unknown2"]
        unknown3         <- map["unknown3"]
        unknown4         <- map["unknown4"]
        unknown5         <- map["unknown5"]
        unknown6         <- map["unknown6"]
        unknown7         <- map["unknown7"]
        unknown8         <- map["unknown8"]
        effects          <- map["effects"]
        band             <- map["band"]
        fuse             <- map["fuse"]
        usbGain          <- map["usbGain"]
        expressionPedal  <- map["expressionPedal"]
    }
    
}

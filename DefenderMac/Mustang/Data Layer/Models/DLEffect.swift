//
//  DLEffect.swift
//  Mustang
//
//  Created by Derek Knight on 3/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

enum DLEffectType : Int {
    case _Stomp = 1
    case _Modulation = 2
    case _Delay = 3
    case _Reverb = 4
}

class DLEffect: Mappable {
    
    var type: DLEffectType!
    var module: Int!
    var slot: UInt8!
    var enabled: UInt8!
    var colour: UInt8!
    var knobs: [DLKnob]!
    var aValue1: UInt8!
    var aValue2: UInt8!
    var aValue3: UInt8!
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    init(withType type: DLEffectType, element: XMLElement) {
        self.type = type
        if let module = element.elements(forName: "Module").first {
            if let id = module.attribute(forName: "ID")?.intValue {
                if let pos = module.attribute(forName: "POS")?.intValue {
                    self.module = Int(UInt16(id).byteSwapped)
                    self.slot = UInt8(pos)
                    self.enabled = pos > 0 ? 1 : 0
                    self.colour = type == ._Stomp ? 14 : type == ._Modulation ? 1 : type == ._Delay ? 2 : type == ._Reverb ? 10 : 0
                    self.aValue1 = 0
                    self.aValue2 = 0
                    self.aValue3 = 0
                    self.knobs = [DLKnob]()
                    for param in module.elements(forName: "Param") {
                        if let index = param.attribute(forName: "ControlIndex")?.intValue {
                            if let value = param.intValue {
                                let shiftRightValue = value >> 8
                                switch index {
                                case 0...5:
                                    let knob = DLKnob(withValue: shiftRightValue)
                                    self.knobs.append(knob)
                                default:
                                    NSLog("Param: \(param)")
                                    NSLog("Can't process effect control index \(index) - value '\(value) - \(shiftRightValue)'")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    init(withType type: DLEffectType, andModule module: Int, andSlot slot: UInt8, andEnabled enabled: UInt8, andKnobs knobs: [DLKnob], aValue1: UInt8, aValue2: UInt8, aValue3: UInt8) {
        self.type = type
        self.module = module
        self.slot = slot
        self.enabled = enabled
        self.colour = type == ._Stomp ? 14 : type == ._Modulation ? 1 : type == ._Delay ? 2 : type == ._Reverb ? 10 : 0
        self.knobs = knobs
        self.aValue1 = aValue1
        self.aValue2 = aValue2
        self.aValue3 = aValue3
    }
    
    func mapping(map: Map) {
        type           <- map["type"]
        module         <- map["module"]
        slot           <- map["slot"]
        enabled        <- map["enabled"]
        colour         <- map["colour"]
        knobs          <- map["knobs"]
        aValue1        <- map["aValue1"]
        aValue2        <- map["aValue2"]
        aValue3        <- map["aValue3"]
    }
    
}

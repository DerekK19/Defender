//
//  DXEffect.swift
//  Defender
//
//  Created by Derek Knight on 19/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

enum DXEffectType : Int {
    case Unknown = 0
    case Stomp = 1
    case Modulation = 2
    case Delay = 3
    case Reverb = 4
}

internal class DXEffect : Transferable {

    var type: DXEffectType!
    var name: String!
    var module: Int!
    var slot: Int!
    var enabled: Bool!
    var colour: Int!
    var knobs: [Float]!

    required init?(map: Map) {
        mapping(map: map)
    }
    
    init(type: DXEffectType) {
        self.type = type
    }
    
    required init(data: Data?) throws {
        if let data = data {
            if let string = String(data: data, encoding: .utf8),
                let temp = Mapper<DXEffect>().map(JSONString: string) {
                type = temp.type
                module = temp.module
                name = temp.name
                slot = temp.slot
                enabled = temp.enabled
                colour = temp.colour
                knobs = temp.knobs
                return
            }
        }
        throw TransferError.serialising
    }

    var data: Data? {
        get {
            if let string = self.toJSONString() {
                return string.data(using: .utf8)
            }
            return nil
        }
    }
    
    func mapping(map: Map) {
        type           <- map["type"]
        module         <- map["module"]
        name           <- map["name"]
        slot           <- map["slot"]
        enabled        <- map["enabled"]
        colour         <- map["colour"]
        knobs          <- map["knobs"]
    }
}

//
//  DXPreset.swift
//  DefenderApp
//
//  Created by Derek Knight on 18/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import ObjectMapper

internal class DXPreset : Transferable {
    
    var number: UInt8?
    var name: String!
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
    var sag: Int?
    var brightness: Int?
    var cabinet: Int?
    var cabinetName: String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    required init(data: Data?) throws {
        if let data = data {
            if let string = String(data: data, encoding: .utf8),
                let temp = Mapper<DXPreset>().map(JSONString: string) {
                number = temp.number
                name = temp.name
                module = temp.module
                moduleName = temp.moduleName
                volume = temp.volume
                gain1 = temp.gain1
                gain2 = temp.gain2
                masterVolume = temp.masterVolume
                treble = temp.treble
                middle = temp.middle
                bass = temp.bass
                presence = temp.presence
                depth = temp.depth
                bias = temp.bias
                noiseGate = temp.noiseGate
                threshold = temp.threshold
                sag = temp.sag
                brightness = temp.brightness
                cabinet = temp.cabinet
                cabinetName = temp.cabinetName
                return
            }
        }
        throw TransferError.serialising
    }
    
    init(name: String) {
        self.name = name
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
        number           <- map["number"]
        name             <- map["name"]
        module           <- map["module"]
        moduleName       <- map["moduleName"]
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
        cabinet          <- map["cabinet"]
        cabinetName      <- map["cabinetName"]
    }
}

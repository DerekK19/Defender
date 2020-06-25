//
//  AmpMockAgent.swift
//  Mustang
//
//  Created by Derek Knight on 11/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

// Fender constants
private let FenderVendorId: Int = 0x1ed8

// Mustang constants
private let MustangProductId: Int = 0x22
private let MustangName: String = "Mockstang III"

class AmpMockAgent : AmpServiceAgentProtocol {
    
    let dataDebug = false
    
    let reportSize = 64 //Device specific

    func getDevices() -> [DLHIDDevice] {
        return [DLHIDDevice(withVendor: FenderVendorId, product: MustangProductId, name: MustangName, locationId: 12345)]
    }
    
    func getPresetsForAmplifier(_ amplifier: DLAmplifier, onSuccess: @escaping ([DLPreset]) -> (), onFail: @escaping () -> ()) {
        var presets = [DLPreset]()
        MustangAgent.serialize(MustangMockData().initialisationResponse, forAmplifier: amplifier, intoPresets: &presets)
        onSuccess(presets)
    }
    
    func getPresetForAmplifier(_ amplifier: DLAmplifier, preset: UInt8, onSuccess: @escaping (DLPreset) -> (), onFail: @escaping () -> ()) {
        var presets = [DLPreset]()
        switch preset {
        case 0:
            MustangAgent.serialize(MustangMockData().preset0Response, forAmplifier: amplifier, intoPresets: &presets)
        case 1:
            MustangAgent.serialize(MustangMockData().preset1Response, forAmplifier: amplifier, intoPresets: &presets)
        case 97:
            MustangAgent.serialize(MustangMockData().preset97Response, forAmplifier: amplifier, intoPresets: &presets)
        default: break
        }
        if let preset = presets.first {
            onSuccess(preset)
        } else {
            onFail()
        }
    }
    
    func setPresetForAmplifier(_ amplifier: DLAmplifier, preset: DLPreset, onSuccess: @escaping (DLPreset) -> (), onFail: @escaping () -> ()) {
        let dataArray = MustangAgent.deserialize(preset, update: true)
        let dataEffects = dataArray.filter { $0[2] >= 0x05 && $0[2] <= 0x09 }
        for data in dataEffects {
            var bytes = [UInt8](repeating: 0x00, count: self.reportSize)
            for i in 0..<data.count {
                bytes[i] = data[i]
            }
            debugPrint("send", bytes: bytes)
        }
        var presets = [DLPreset]()
        MustangAgent.serialize(dataArray, forAmplifier: amplifier, intoPresets: &presets)
        if presets.count > 0 {
            onSuccess(presets[0])
        } else {
            onFail()
        }
    }
    
    func savePresetForAmplifier(_ amplifier: DLAmplifier, preset: UInt8, name: String, onSuccess: @escaping (Bool) -> (), onFail: @escaping () -> ()) {
        onSuccess(true)
    }
    
    func confirmChangeForAmplifier(_ amplifier: DLAmplifier, onSuccess: @escaping (Bool) -> (), onFail: @escaping () -> ()) {
        onSuccess(true)
    }

    // MARK: Logging and debugging
    fileprivate func debugPrint(_ reason: String, bytes: [UInt8]) {
        if (dataDebug) {
            var text = ""
            text += "\(reason): <"
            var i = 0
            bytes.forEach { if i > 0 && i % 4 == 0 { text += " " }; text += "\(String(format: "%02x", $0))"; i += 1 }
            text += ">"
            ULog.debug("%@", text)
        }
    }
    
}

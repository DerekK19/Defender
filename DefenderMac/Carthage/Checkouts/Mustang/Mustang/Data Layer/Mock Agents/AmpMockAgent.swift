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
    
    let reportSize = 64 //Device specific

    func getDevices() -> [DLHIDDevice] {
        return [DLHIDDevice(withVendor: FenderVendorId, product: MustangProductId, name: MustangName, locationId: 12345)]
    }
    
    func getPresetsForDeviceWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, onSuccess: @escaping ([DLPreset]) -> (), onFail: @escaping () -> ()) {
        var presets = [DLPreset]()
        MustangAgent.serialize(MustangMockData().initialisationResponse, intoPresets: &presets)
        onSuccess(presets)
    }
    
    func getPresetForDeviceWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, preset: UInt8, onSuccess: @escaping (DLPreset) -> (), onFail: @escaping () -> ()) {
        var presets = [DLPreset]()
        switch preset {
        case 0:
            MustangAgent.serialize(MustangMockData().preset0Response, intoPresets: &presets)
        case 1:
            MustangAgent.serialize(MustangMockData().preset1Response, intoPresets: &presets)
        case 97:
            MustangAgent.serialize(MustangMockData().preset97Response, intoPresets: &presets)
        default: break
        }
        if let preset = presets.first {
            onSuccess(preset)
        } else {
            onFail()
        }
    }
    
    func setPresetForDeviceWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, preset: DLPreset, onSuccess: @escaping (DLPreset) -> (), onFail: @escaping () -> ()) {
        let dataArray = MustangAgent.deserialize(preset, update: true)
        let dataEffects = dataArray.filter { $0[2] >= 0x05 && $0[2] <= 0x09 }
        for data in dataEffects {
            var bytes = [UInt8](repeating: 0x00, count: self.reportSize)
            for i in 0..<data.count {
                bytes[i] = data[i]
            }
            DebugPrint("send", bytes: bytes)
        }
        var presets = [DLPreset]()
        MustangAgent.serialize(dataArray, intoPresets: &presets)
        if presets.count > 0 {
            onSuccess(presets[0])
        } else {
            onFail()
        }
    }
    
    func savePresetForDeviceWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, preset: UInt8, name: String, onSuccess: @escaping (Bool) -> (), onFail: @escaping () -> ()) {
        onSuccess(true)
    }
    
    func confirmChangeForDeviceWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, onSuccess: @escaping (Bool) -> (), onFail: @escaping () -> ()) {
        onSuccess(true)
    }

    // MARK: Logging and debugging
    fileprivate func DebugPrint(_ reason: String, bytes: [UInt8]) {
        print("\(reason): <", terminator: "")
        var i = 0
        bytes.forEach { if i > 0 && i % 4 == 0 { print(" ", terminator: "") }; print("\(String(format: "%02x", $0))", terminator:""); i += 1 }
        print(">")
    }
    
}

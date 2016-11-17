//
//  AmpServiceAgent.swift
//  Mustang
//
//  Created by Derek Knight on 14/08/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

class AmpServiceAgent : BaseServiceAgent, AmpServiceAgentProtocol {
    
    fileprivate let hidAgent: HIDServiceAgent!
    
    override init() {
        hidAgent = HIDServiceAgent()
        super.init()
    }

    func getDevices() -> [DLHIDDevice] {
        return hidAgent.getDevices()
    }

    func getPresetsForDeviceWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, onSuccess: @escaping (_ presets: [DLPreset]) -> (), onFail: @escaping () -> ()) {
        var presets = [DLPreset]()
        hidAgent.getPresetsForDeviceWithVendorId (
            vendorId,
            productId: productId,
            locationId: locationId,
            onSuccess: { (data: [[UInt8]]?) in
                if let data = data {
                    MustangAgent.serialize(data, intoPresets: &presets)
                    onSuccess(presets)
                } else {
                    onFail()
                }
            }, onFail: onFail)
    }
    
    func getPresetForDeviceWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, preset: UInt8, onSuccess: @escaping (_ preset: DLPreset) -> (), onFail: @escaping () -> ()) {
        var presets = [DLPreset]()
        hidAgent.getPresetForDeviceWithVendorId(
            vendorId,
            productId: productId,
            locationId: locationId,
            data: MustangAgent.deserialize(preset, update: false),
            onSuccess: { (data: [[UInt8]]?) in
                if let data = data {
                    MustangAgent.serialize(data, intoPresets: &presets)
                    if let preset = presets.first {
                        onSuccess(preset)
                    } else {
                        onFail()
                    }
                } else {
                    onFail()
                }
            }, onFail: onFail)
    }

    func setPresetForDeviceWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, preset: DLPreset, onSuccess: @escaping (_ preset: DLPreset) -> (), onFail: @escaping () -> ()) {
        let data = MustangAgent.deserialize(preset, update: true)
        let dataEffects = data.filter { $0[2] >= 0x05 && $0[2] <= 0x09 }
        hidAgent.setPresetForDeviceWithVendorId(
            vendorId,
            productId: productId,
            locationId: locationId,
            data: dataEffects,
            onSuccess: { (response: [[UInt8]]?) in
                if let data = response {
                    var message = String()
                    MustangAgent.serialize(data, intoMessage: &message)
                    //NSLog("Message: \(message)")
                    onSuccess(preset)
                } else {
                    onFail()
                }
            }, onFail: onFail)
    }
    
    func savePresetForDeviceWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, preset: UInt8, name: String, onSuccess: @escaping (Bool) -> (), onFail: @escaping () -> ()) {
        hidAgent.savePresetForDeviceWithVendorId(
            vendorId,
            productId: productId,
            locationId: locationId,
            data: MustangAgent.deserialize(preset, andName: name, update: true),
            onSuccess: { () in
                onSuccess(true)
            }, onFail: onFail)
    }
    
    func confirmChangeForDeviceWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, onSuccess: @escaping (Bool) -> (), onFail: @escaping () -> ()) {
        self.hidAgent.confirmChangeWithVendorId(
            vendorId,
            productId: productId,
            locationId: locationId,
            onSuccess: { (data: [[UInt8]]?) in
                if let data = data {
                    var message = String()
                    MustangAgent.serialize(data, intoMessage: &message)
                    //NSLog("Message: \(message)")
                    onSuccess(true)
                } else {
                    onFail()
                }
            }, onFail: onFail)
    }
}

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
    
    fileprivate var amplifier : DLAmplifier?
    
    override init() {
        hidAgent = HIDServiceAgent()
        super.init()
        hidAgent.delegate = self
    }

    func getDevices() -> [DLHIDDevice] {
        return hidAgent.getDevices()
    }

    func setCurrentAmplifier(_ amplifier: DLAmplifier) {
        self.amplifier = amplifier
    }

    func getPresetsForAmplifier(_ amplifier: DLAmplifier, onSuccess: @escaping (_ presets: [DLPreset]) -> (), onFail: @escaping () -> ()) {
        var presets = [DLPreset]()
        hidAgent.getPresetsForDeviceWithVendorId (
            amplifier.vendorId,
            productId: amplifier.productId,
            locationId: amplifier.locationId,
            onSuccess: { (data: [[UInt8]]?) in
                if let data = data {
                    MustangAgent.serialize(data, forAmplifier: amplifier, intoPresets: &presets)
                    onSuccess(presets)
                } else {
                    onFail()
                }
            }, onFail: onFail)
    }
    
    func getPresetForAmplifier(_ amplifier: DLAmplifier, preset: UInt8, onSuccess: @escaping (_ preset: DLPreset) -> (), onFail: @escaping () -> ()) {
        var presets = [DLPreset]()
        hidAgent.getPresetForDeviceWithVendorId(
            amplifier.vendorId,
            productId: amplifier.productId,
            locationId: amplifier.locationId,
            data: MustangAgent.deserialize(preset, update: false),
            onSuccess: { (data: [[UInt8]]?) in
                if let data = data {
                    MustangAgent.serialize(data, forAmplifier: amplifier, intoPresets: &presets)
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

    func setPresetForAmplifier(_ amplifier: DLAmplifier, preset: DLPreset, onSuccess: @escaping (_ preset: DLPreset) -> (), onFail: @escaping () -> ()) {
        let data = MustangAgent.deserialize(preset, update: true)
        let dataEffects = data.filter { $0[2] >= 0x05 && $0[2] <= 0x09 }
        hidAgent.setPresetForDeviceWithVendorId(
            amplifier.vendorId,
            productId: amplifier.productId,
            locationId: amplifier.locationId,
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
    
    func savePresetForAmplifier(_ amplifier: DLAmplifier, preset: UInt8, name: String, onSuccess: @escaping (Bool) -> (), onFail: @escaping () -> ()) {
        hidAgent.savePresetForDeviceWithVendorId(
            amplifier.vendorId,
            productId: amplifier.productId,
            locationId: amplifier.locationId,
            data: MustangAgent.deserialize(preset, andName: name, update: true),
            onSuccess: { () in
                onSuccess(true)
            }, onFail: onFail)
    }
    
    func confirmChangeForAmplifier(_ amplifier: DLAmplifier, onSuccess: @escaping (Bool) -> (), onFail: @escaping () -> ()) {
        self.hidAgent.confirmChangeWithVendorId(
            amplifier.vendorId,
            productId: amplifier.productId,
            locationId: amplifier.locationId,
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

extension AmpServiceAgent: HIDServiceAgentDelegate {
    
    func HIDAgent(agent: HIDServiceAgent, didChangeSetting array: [UInt8], length: Int) {
        if array[0] == 0x05 && array[1] == 0x01 && length > 10 {
            let floatValue = (Float(array[10]) / 256.0)
            let userInfo = ["value": floatValue] as [String: Any]
            switch array[5] {
            case 0x00:
                switch array[7] {
                case 0x0c:
                    ULog.verbose("Volume %.2f", floatValue)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Mustang.volumeDidChange), object: nil, userInfo: userInfo)
                case 0x01:
                    ULog.verbose("Reverb %.2f", floatValue)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Mustang.presenceDidChange), object: nil, userInfo: userInfo)
                default: break
                }
            case 0x01:
                ULog.verbose("Gain %.2f", floatValue)
                NotificationCenter.default.post(name: Notification.Name(rawValue: Mustang.gainDidChange), object: nil, userInfo: userInfo)
            case 0x04:
                ULog.verbose("Treble %.2f", floatValue)
                NotificationCenter.default.post(name: Notification.Name(rawValue: Mustang.trebleDidChange), object: nil, userInfo: userInfo)
            case 0x05:
                ULog.verbose("Middle %.2f", floatValue)
                NotificationCenter.default.post(name: Notification.Name(rawValue: Mustang.middleDidChange), object: nil, userInfo: userInfo)
            case 0x06:
                ULog.verbose("Bass %.2f", floatValue)
                NotificationCenter.default.post(name: Notification.Name(rawValue: Mustang.bassDidChange), object: nil, userInfo: userInfo)
            default: break
            }
            return
        }
    }
    
    func HIDAgent(agent: HIDServiceAgent, didSelectPreset data: [[UInt8]]) {
        guard let amplifier = amplifier else { return }
        var presets = [DLPreset]()
        MustangAgent.serialize(data, forAmplifier: amplifier, intoPresets: &presets)
        guard let preset = presets.first else { return }
        let boObject = BOPreset(dl: preset)
        let userInfo = ["value": boObject] as [String : Any]
        NotificationCenter.default.post(name: Notification.Name(rawValue: Mustang.didSelectPreset), object: nil, userInfo: userInfo)
    }
}

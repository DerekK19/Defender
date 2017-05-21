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
        hidAgent.delegate = self
    }

    func getDevices() -> [DLHIDDevice] {
        return hidAgent.getDevices()
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
                    logDebug("Volume \(floatValue)")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Mustang.volumeChangedNotificationName), object: nil, userInfo: userInfo)
                case 0x01:
                    logDebug("Reverb \(floatValue)")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Mustang.presenceChangedNotificationName), object: nil, userInfo: userInfo)
                default: break
                }
            case 0x01:
                logDebug("Gain \(floatValue)")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Mustang.gainChangedNotificationName), object: nil, userInfo: userInfo)
            case 0x04:
                logDebug("Treble \(floatValue)")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Mustang.trebleChangedNotificationName), object: nil, userInfo: userInfo)
            case 0x05:
                logDebug("Middle \(floatValue)")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Mustang.middleChangedNotificationName), object: nil, userInfo: userInfo)
            case 0x06:
                logDebug("Bass \(floatValue)")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Mustang.bassChangedNotificationName), object: nil, userInfo: userInfo)
            default: break
            }
            return
        }
        if array[0] == 0x1c && array[1] == 01 {
            let userInfo = ["value": array] as [String: Any]
            switch array[2] {
            case 0x04:
                logDebug("Preset")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Mustang.presetChangedNotificationName), object: nil, userInfo: userInfo)
            case 0x05:
                logDebug("Amplifier")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Mustang.amplifierChangedNotificationName), object: nil, userInfo: userInfo)
            case 0x06:
                logDebug("Stompbox")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Mustang.stompboxChangedNotificationName), object: nil, userInfo: userInfo)
            case 0x07:
                logDebug("Modulation")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Mustang.modulationChangedNotificationName), object: nil, userInfo: userInfo)
            case 0x08:
                logDebug("Delay")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Mustang.delayChangedNotificationName), object: nil, userInfo: userInfo)
            case 0x09:
                logDebug("Reverb")
                NotificationCenter.default.post(name: Notification.Name(rawValue: Mustang.reverbChangedNotificationName), object: nil, userInfo: userInfo)
            default: break
            }
            return
        }
    }
}

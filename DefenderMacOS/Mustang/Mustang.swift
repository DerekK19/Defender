//
//  Mustang.swift
//  Mustang
//
//  Created by Derek Knight on 26/06/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

open class Mustang {
    
    var controller : MustangController
    
    public init(mockMode: Bool = false) {
        if mockMode {
            controller = MustangController.mockInstance
        } else {
            controller = MustangController.realInstance
        }
    }
    
    public static let deviceOpenedNotificationName = "deviceOpened"
    public static let deviceConnectedNotificationName = "deviceConnected"
    public static let deviceDisconnectedNotificationName = "deviceDisconnected"
    public static let deviceClosedNotificationName = "deviceClosed"
    public static let gainChangedNotificationName = "gainChanged"
    public static let volumeChangedNotificationName = "volumeChanged"
    public static let trebleChangedNotificationName = "trebleChanged"
    public static let middleChangedNotificationName = "middleChanged"
    public static let bassChangedNotificationName = "bassChanged"
    public static let presenceChangedNotificationName = "presenceChanged"
    public static let presetChangedNotificationName = "presetChanged"
    public static let amplifierChangedNotificationName = "amplifierChanged"
    public static let stompboxChangedNotificationName = "stompboxChanged"
    public static let modulationChangedNotificationName = "modulationChanged"
    public static let delayChangedNotificationName = "delayChanged"
    public static let reverbChangedNotificationName = "reverbChanged"
    
    func getUSBDevices() -> [UInt32] {
        let info = controller.getUSBDevices()
        return info.map { $0.location }
    }
    
    func getHIDDevices() -> [UInt32] {
        let info = controller.getHIDDevices()
        return info.map { $0.location }
    }
    
    func getAudioDevices() -> [UInt32] {
        let info = controller.getAudioDevices()
        return info.map { $0.deviceId }
        
    }

    func getConnectedAmplifiers() -> [BOAmplifier] {
        let info = controller.getConnectedAmplifiers()
        return info.map { $0 }
    }
    
    func getAmplifierType(_ amplifier: BOAmplifier) -> String {
        if let info = controller.getInfoForDeviceWithId(amplifier.location) {
            return info.name
        }
        return "Unknown"
    }
    
    func getPresets(_ amplifier: BOAmplifier, onCompletion: @escaping (_ presets: [BOPreset]) ->()) {
        controller.getPresetsForAmplifier(
            amplifier,
            onSuccess: { (presets) in
                onCompletion(presets.map { $0 } )
        }
        )
    }
    
    func getPreset(_ amplifier: BOAmplifier, preset: UInt8, onCompletion: @escaping (_ preset: BOPreset?) ->()) {
        controller.getPresetForAmplifier(
            amplifier,
            preset: preset,
            onSuccess: { (preset) in
                onCompletion(preset.map { $0 } )
        }
        )
    }

    func setPreset(_ amplifier: BOAmplifier, preset: BOPreset, onCompletion: @escaping (_ preset: BOPreset?) ->()) {
        controller.setPresetForAmplifier(
            amplifier,
            preset: preset,
            onSuccess: { (preset) in
                onCompletion(preset.map { $0 } )
        }
        )
    }
    
    func savePreset(_ amplifier: BOAmplifier, preset: UInt8, name: String, onCompletion: @escaping (_ saved: Bool) ->()) {
        controller.savePresetForAmplifier(
            amplifier,
            preset: preset,
            name: name,
            onSuccess: { (saved) in
                onCompletion(saved ?? false)
        }
        )
    }

    func login(username: String, password: String, onSuccess: @escaping () -> (), onFail: @escaping () -> ()) {
        controller.login(username: username, password: password, onSuccess: onSuccess, onFail: onFail)
    }
    
    func logout(onSuccess: @escaping () -> (), onFail: @escaping () -> ()) {
        controller.logout(onSuccess: onSuccess, onFail: onFail)
    }
    
    func search(forTitle title: String, pageNumber: UInt, maxReturn: UInt, onSuccess: @escaping (_ response: BOSearchResponse) -> (), onFail: @escaping () -> ()) {
        controller.search(forTitle: title, pageNumber: pageNumber, maxReturn: maxReturn, onSuccess: onSuccess, onFail: onFail)
    }
    
    func importPreset(_ xml: XMLDocument) -> BOPreset? {
        return controller.importPresetWithXml(xml)
    }

    func exportPresetAsXml(preset: BOPreset) -> XMLDocument? {
        return controller.exportPresetAsXml(preset: preset)
    }
}

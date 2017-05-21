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
    
    open static let deviceOpenedNotificationName = "deviceOpened"
    open static let deviceConnectedNotificationName = "deviceConnected"
    open static let deviceDisconnectedNotificationName = "deviceDisconnected"
    open static let deviceClosedNotificationName = "deviceClosed"
    open static let gainChangedNotificationName = "gainChanged"
    open static let volumeChangedNotificationName = "volumeChanged"
    open static let trebleChangedNotificationName = "trebleChanged"
    open static let middleChangedNotificationName = "middleChanged"
    open static let bassChangedNotificationName = "bassChanged"
    open static let presenceChangedNotificationName = "presenceChanged"
    open static let presetChangedNotificationName = "presetChanged"
    open static let amplifierChangedNotificationName = "amplifierChanged"
    open static let stompboxChangedNotificationName = "stompboxChanged"
    open static let modulationChangedNotificationName = "modulationChanged"
    open static let delayChangedNotificationName = "delayChanged"
    open static let reverbChangedNotificationName = "reverbChanged"
    
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

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
    
    open func getUSBDevices() -> [UInt32] {
        let info = controller.getUSBDevices()
        return info.map { $0.location }
    }
    
    open func getHIDDevices() -> [UInt32] {
        let info = controller.getHIDDevices()
        return info.map { $0.location }
    }
    
    open func getAudioDevices() -> [UInt32] {
        let info = controller.getAudioDevices()
        return info.map { $0.deviceId }
        
    }

    open func getConnectedAmplifiers() -> [DTOAmplifier] {
        let info = controller.getConnectedAmplifiers()
        return info.map { $0 }
    }
    
    open func getAmplifierType(_ amplifier: DTOAmplifier) -> String {
        if let info = controller.getInfoForDeviceWithId(amplifier.location) {
            return info.name
        }
        return "Unknown"
    }
    
    open func getPresets(_ amplifier: DTOAmplifier, onCompletion: @escaping (_ presets: [DTOPreset]) ->()) {
        if let amplifier = amplifier as? BOAmplifier {
            controller.getPresetsForAmplifier(
                amplifier,
                onSuccess: { (presets) in
                    onCompletion(presets.map { $0 } )
            }
            )
        }
    }
    
    open func getPreset(_ amplifier: DTOAmplifier, preset: UInt8, onCompletion: @escaping (_ preset: DTOPreset?) ->()) {
        if let amplifier = amplifier as? BOAmplifier {
            controller.getPresetForAmplifier(
                amplifier,
                preset: preset,
                onSuccess: { (preset) in
                    onCompletion(preset.map { $0 } )
            }
            )
        }
    }
    
    open func setPreset(_ amplifier: DTOAmplifier, preset: DTOPreset, onCompletion: @escaping (_ preset: DTOPreset?) ->()) {
        if let amplifier = amplifier as? BOAmplifier,
            let preset = preset as? BOPreset {
            controller.setPresetForAmplifier(
                amplifier,
                preset: preset,
                onSuccess: { (preset) in
                    onCompletion(preset.map { $0 } )
                }
            )
        } else {
            onCompletion(nil)
        }
    }
    
    open func savePreset(_ amplifier: DTOAmplifier, preset: UInt8, name: String, onCompletion: @escaping (_ saved: Bool) ->()) {
        if let amplifier = amplifier as? BOAmplifier {
            controller.savePresetForAmplifier(
                amplifier,
                preset: preset,
                name: name,
                onSuccess: { (saved) in
                    onCompletion(saved ?? false)
            }
        )
    }
    }
    
    open func login(username: String, password: String, onSuccess: @escaping () -> (), onFail: @escaping () -> ()) {
        controller.login(username: username, password: password, onSuccess: onSuccess, onFail: onFail)
    }
    
    open func logout(onSuccess: @escaping () -> (), onFail: @escaping () -> ()) {
        controller.logout(onSuccess: onSuccess, onFail: onFail)
    }
    
    open func search(forTitle title: String, pageNumber: UInt, maxReturn: UInt, onSuccess: @escaping (_ response: DTOSearchResponse) -> (), onFail: @escaping () -> ()) {
        controller.search(forTitle: title, pageNumber: pageNumber, maxReturn: maxReturn, onSuccess: onSuccess, onFail: onFail)
    }
    
    open func importPreset(_ xml: XMLDocument) -> DTOPreset? {
        return controller.importPresetWithXml(xml)
    }

    open func exportPresetAsXml(preset: DTOPreset) -> XMLDocument? {
        if let preset = preset as? BOPreset {
            return controller.exportPresetAsXml(preset: preset)
        }
        return nil
    }
}

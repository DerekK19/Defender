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
        controller.getPresetsForDeviceWithVendorId(
            amplifier.vendor,
            productId: amplifier.product,
            locationId: amplifier.location,
            onSuccess: { (presets) in
                onCompletion(presets.map { $0 } )
            }
        )
    }
    
    open func getPreset(_ amplifier: DTOAmplifier, preset: UInt8, onCompletion: @escaping (_ preset: DTOPreset?) ->()) {
        controller.getPresetForDeviceWithVendorId(
            amplifier.vendor,
            productId: amplifier.product,
            locationId: amplifier.location,
            preset: preset,
            onSuccess: { (preset) in
                onCompletion(preset.map { $0 } )
            }
        )
    }
    
    open func setPreset(_ amplifier: DTOAmplifier, preset: DTOPreset, onCompletion: @escaping (_ preset: DTOPreset?) ->()) {
        if let preset = preset as? BOPreset {
            controller.setPresetForDeviceWithVendorId(
                amplifier.vendor,
                productId: amplifier.product,
                locationId: amplifier.location,
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
        controller.savePresetForDeviceWithVendorId(
            amplifier.vendor,
            productId: amplifier.product,
            locationId: amplifier.location,
            preset: preset,
            name: name,
            onSuccess: { (saved) in
                onCompletion(saved ?? false)
            }
        )
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
    
    open func exportPreset(preset: DTOPreset, onCompletion: @escaping (_ xml: XMLDocument?) ->()) {
        if let preset = preset as? BOPreset {
            controller.exportPresetAsXml(
                preset: preset,
                onSuccess: { (xml) in
                    onCompletion(xml)
                }
            )
        }
    }
    
    open func importPreset(_ xml: XMLDocument, onCompletion: @escaping (_ preset: DTOPreset?) ->()) {
        controller.importPresetWithXml(
            xml,
            onSuccess: { (preset) in
                onCompletion(preset.map { $0 } )
        }
        )
        
    }
    
}

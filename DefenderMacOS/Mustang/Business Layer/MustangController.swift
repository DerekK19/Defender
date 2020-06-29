//
//  MustangController.swift
//  Mustang
//
//  Created by Derek Knight on 26/06/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

private let singleton = MustangController(mockMode: false)
private let mockSingleton = MustangController(mockMode: true)

class MustangController {
    
    class var realInstance: MustangController {
        return singleton
    }
    
    class var mockInstance: MustangController {
        return mockSingleton
    }
    
    fileprivate let ampAgent: AmpServiceAgentProtocol
    fileprivate let usbAgent: USBServiceAgentProtocol
    fileprivate let audioAgent: AudioServiceAgentProtocol
    fileprivate let fileAgent: FileServiceAgentProtocol
    fileprivate let webAgent: WebServiceAgentProtocol
    
    fileprivate init(mockMode: Bool) {
        if mockMode {
            ampAgent = AmpMockAgent()
            usbAgent = USBMockAgent()
            audioAgent = AudioMockAgent()
            fileAgent = FileMockAgent()
            webAgent = WebMockAgent()
        } else {
            ampAgent = AmpServiceAgent()
            usbAgent = USBServiceAgent()
            audioAgent = AudioServiceAgent()
            fileAgent = FileMockAgent()
            webAgent = WebServiceAgent()
        }
    }
    
    func getUSBDevices() -> [BOUSBDevice] {
        let dlObjects = usbAgent.getDevices()
        return BOUSBDevice.convertArray(dlObjects)
    }
    
    func getAudioDevices() -> [BOAudioDevice] {
        let dlObjects = audioAgent.getDevices()
        return BOAudioDevice.convertArray(dlObjects)
    }
    
    func getHIDDevices() -> [BOHIDDevice] {
        let dlObjects = ampAgent.getDevices()
        return BOHIDDevice.convertArray(dlObjects)
    }
    
    func getConnectedAmplifiers() -> [BOAmplifier] {
        let dlUSBObjects = usbAgent.getDevices()
        let dlHIDObjects = ampAgent.getDevices()
        let dlAudioObjects = audioAgent.getDevices()
        return BOAmplifier.convertArray(usb: dlUSBObjects, hid: dlHIDObjects, audio: dlAudioObjects)
    }
    
    func getInfoForDeviceWithId(_ id: UInt32) -> BOAmplifier? {
        if let dlObject = usbAgent.getInfoForDeviceWithId(id) {
            let dlHIDObjects = ampAgent.getDevices()
            let dlAudioObjects = audioAgent.getDevices()
            if dlHIDObjects.count == 1 && dlAudioObjects.count == 1 {
                return BOAmplifier(dl: DLAmplifier(usb: dlObject, hid: dlHIDObjects[0], audio: dlAudioObjects[0]))
            } else {
                return BOAmplifier(dl: DLAmplifier(usb: dlObject, hid: nil, audio: nil))
            }
        }
        return nil
    }
    
    func getPresetsForAmplifier(_ amplifier: BOAmplifier, onSuccess: @escaping (_ presets: [BOPreset]) -> ()) {
        ampAgent.getPresetsForAmplifier(
            amplifier.dataObject,
            onSuccess: {
                (dlObjects) in onSuccess(BOPreset.convertArray(dlObjects))
            },
            onFail: {
                onSuccess([BOPreset]())
            }
        )
    }
    
    func getPresetForAmplifier(_ amplifier: BOAmplifier, preset: UInt8, onSuccess: @escaping (_ preset: BOPreset?) -> ()) {
        ampAgent.getPresetForAmplifier(
            amplifier.dataObject,
            preset: preset,
            onSuccess: {
                (dlObject) in onSuccess(BOPreset(dl: dlObject))
            },
            onFail: {
                onSuccess(nil)
            }
        )
    }
    
    func setPresetForAmplifier(_ amplifier: BOAmplifier, preset: BOPreset, onSuccess: @escaping (_ preset: BOPreset?) -> ()) {
        ampAgent.setPresetForAmplifier(
            amplifier.dataObject,
            preset: preset.dataObject,
            onSuccess: {
                (dlObject) in
                self.ampAgent.confirmChangeForAmplifier(
                    amplifier.dataObject,
                    onSuccess: {
                        (saved) in onSuccess(BOPreset(dl: dlObject))
                    },
                    onFail: {
                        onSuccess(nil)
                    }
                )
            },
            onFail: {
                onSuccess(nil)
            }
        )
    }
    
    func savePresetForAmplifier(_ amplifier: BOAmplifier, preset: UInt8, name: String, onSuccess: @escaping (_ saved: Bool?) -> ()) {
        ampAgent.savePresetForAmplifier(
            amplifier.dataObject,
            preset: preset,
            name: name,
            onSuccess: {
                (saved) in
                if saved {
                    self.ampAgent.confirmChangeForAmplifier(
                        amplifier.dataObject,
                        onSuccess: {
                            (saved) in onSuccess(saved)
                        },
                        onFail: {
                            onSuccess(nil)
                        }
                    )
                } else {
                    onSuccess(saved)
                }
            },
            onFail: {
                onSuccess(nil)
            }
        )
    }

    func confirmChangeForAmplifier(_ amplifier: BOAmplifier, onSuccess: @escaping (_ saved: Bool?) -> ()) {
    }
    
    func verifyWeb(onCompletion: @escaping (_ available: Bool) -> ()) {
        webAgent.verify(onCompletion: onCompletion)
    }
    
    func login(username: String, password: String, onSuccess: @escaping () -> (), onFail: @escaping () -> ()) {
        webAgent.login(username: username, password: password, onSuccess: onSuccess, onFail: onFail)
    }
    
    func search(forTitle title: String, pageNumber: UInt, maxReturn: UInt, onSuccess: @escaping (BOSearchResponse) -> (), onFail: @escaping () -> ()) {
        webAgent.search(forTitle: title,
                        pageNumber: pageNumber,
                        maxReturn: maxReturn,
                        onSuccess: { (response) in
                            onSuccess(BOSearchResponse(dl: response))
                        },
                        onFail: onFail)
    }
    
    func logout(onSuccess: @escaping () -> (), onFail: @escaping () -> ()) {
        webAgent.logout(onSuccess: onSuccess, onFail: onFail)
    }
    
    func exportPresetAsXml(preset: BOPreset) -> XMLDocument? {
        return fileAgent.exportPresetAsXml(preset.dataObject)
    }
    
    func importPresetWithXml(_ xml: XMLDocument) -> BOPreset? {
        if let dlObject = fileAgent.importPresetWithXml(xml) {
            return BOPreset(dl: dlObject)
        }
        return nil
    }

}

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
                return BOAmplifier(usb: dlObject, hid: dlHIDObjects[0], audio: dlAudioObjects[0])
            } else {
                return BOAmplifier(usb: dlObject, hid: nil, audio: nil)
            }
        }
        return nil
    }
    
    func getPresetsForDeviceWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, onSuccess: @escaping (_ presets: [BOPreset]) -> ()) {
        ampAgent.getPresetsForDeviceWithVendorId(
            vendorId,
            productId: productId,
            locationId: locationId,
            onSuccess: {
                (dlObjects) in onSuccess(BOPreset.convertArray(dlObjects))
            },
            onFail: {
                onSuccess([BOPreset]())
            }
        )
    }
    
    func getPresetForDeviceWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, preset: UInt8, onSuccess: @escaping (_ preset: BOPreset?) -> ()) {
        ampAgent.getPresetForDeviceWithVendorId(
            vendorId,
            productId: productId,
            locationId: locationId,
            preset: preset,
            onSuccess: {
                (dlObject) in onSuccess(BOPreset(dl: dlObject))
            },
            onFail: {
                onSuccess(nil)
            }
        )
    }
    
    func setPresetForDeviceWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, preset: BOPreset, onSuccess: @escaping (_ preset: BOPreset?) -> ()) {
        ampAgent.setPresetForDeviceWithVendorId(
            vendorId,
            productId: productId,
            locationId: locationId,
            preset: preset.dataObject,
            onSuccess: {
                (dlObject) in
                self.ampAgent.confirmChangeForDeviceWithVendorId(
                    vendorId,
                    productId: productId,
                    locationId: locationId,
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
    
    func savePresetForDeviceWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, preset: UInt8, name: String, onSuccess: @escaping (_ saved: Bool?) -> ()) {
        ampAgent.savePresetForDeviceWithVendorId(
            vendorId,
            productId: productId,
            locationId: locationId,
            preset: preset,
            name: name,
            onSuccess: {
                (saved) in
                if saved {
                    self.ampAgent.confirmChangeForDeviceWithVendorId(
                        vendorId,
                        productId: productId,
                        locationId: locationId,
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

    func confirmChangeForDeviceWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, onSuccess: @escaping (_ saved: Bool?) -> ()) {
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
    
    func exportPresetAsXml(preset: BOPreset, onSuccess: @escaping (_ xml: XMLDocument?) ->()) {
        fileAgent.exportPresetAsXml(preset.dataObject,
                                       onSuccess: { (xml) in
                                          onSuccess(xml)
                                        },
                                       onFail: {
                                          onSuccess(nil)
                                        }
                                       )
    }
    
    func importPresetWithXml(_ xml: XMLDocument, onSuccess: @escaping (_ preset: BOPreset?) ->()) {
        fileAgent.importPresetWithXml(xml,
                                      onSuccess: {
                                        (dlObject) in
                                        onSuccess(BOPreset(dl: dlObject))
                                      },
                                      onFail: {
                                        onSuccess(nil)
                                      }
                                     )
    }

}

//
//  AgentProtocols.swift
//  Mustang
//
//  Created by Derek Knight on 11/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

internal protocol AmpServiceAgentProtocol {
    func getDevices() -> [DLHIDDevice]
    func getPresetsForAmplifier(_ amplifier: DLAmplifier, onSuccess: @escaping (_ presets: [DLPreset]) -> (), onFail: @escaping () -> ())
    func getPresetForAmplifier(_ amplifier: DLAmplifier, preset: UInt8, onSuccess: @escaping (_ preset: DLPreset) -> (), onFail: @escaping () -> ())
    func setPresetForAmplifier(_ amplifier: DLAmplifier, preset: DLPreset, onSuccess: @escaping (_ preset: DLPreset) -> (), onFail: @escaping () -> ())
    func savePresetForAmplifier(_ amplifier: DLAmplifier, preset: UInt8, name: String, onSuccess: @escaping (_ saved: Bool) -> (), onFail: @escaping () -> ())
    func confirmChangeForAmplifier(_ amplifier: DLAmplifier, onSuccess: @escaping (_ saved: Bool) -> (), onFail: @escaping () -> ())
}

internal protocol AudioServiceAgentProtocol {
    func getDevices() -> [DLAudioDevice]
}

internal protocol HIDServiceAgentProtocol {
    func getDevices() -> [DLHIDDevice]
    func getPresetsForDeviceWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, onSuccess: @escaping (_ data: [[UInt8]]?) -> (), onFail: () -> ())
    func getPresetForDeviceWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, data: [UInt8], onSuccess: @escaping (_ data: [[UInt8]]?) -> (), onFail: () -> ())
    func setPresetForDeviceWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, data: [[UInt8]], onSuccess: @escaping (_ data: [[UInt8]]?) -> (), onFail: () -> ())
    func savePresetForDeviceWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, data: [UInt8], onSuccess: @escaping () -> (), onFail: () -> ())
    func confirmChangeWithVendorId(_ vendorId: Int, productId: Int, locationId: UInt32, onSuccess: @escaping (_ data: [[UInt8]]?) -> (), onFail: () -> ())
}

internal protocol USBServiceAgentProtocol {
    func getDevices() -> [DLUSBDevice]
    func getInfoForDeviceWithId(_ locationId: UInt32) -> DLUSBDevice?
}

internal protocol FileServiceAgentProtocol {
    func importPresetWithXml(_ xml: XMLDocument) -> DLPreset?
    func exportPresetAsXml(_ preset: DLPreset) -> XMLDocument
}

internal protocol WebServiceAgentProtocol {
    func verify(onCompletion: @escaping (_ available: Bool) -> ())
    func login(username: String, password: String, onSuccess: @escaping () -> (), onFail: @escaping () -> ())
    func logout(onSuccess: @escaping () -> (), onFail: @escaping () -> ())
    func search(forTitle title: String, pageNumber: UInt, maxReturn: UInt, onSuccess: @escaping (_ response: DLSearchResponse) -> (), onFail: @escaping () -> ())

}

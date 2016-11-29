//
//  AmpManager.swift
//  Defender
//
//  Created by Derek Knight on 11/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa
import Mustang

protocol AmpManagerDelegate {
    func deviceConnected(ampManager: AmpManager)
    func deviceDisconnected(ampManager: AmpManager)
    func deviceOpened(ampManager: AmpManager)
    func deviceClosed(ampManager: AmpManager)
}

class AmpManager {
    
    var delegate: AmpManagerDelegate?
    
    private let mustang: Mustang
    
    let mocking = false
    
    private var amplifiers = [DTOAmplifier]()
    internal private(set) var currentAmplifier: DTOAmplifier?
    
    private var presets = [UInt8 : DTOPreset] ()

    var hasAnAmplifier : Bool {
        get {
            return currentAmplifier != nil
        }
    }
    
    var currentAmplifierName : String {
        get {
            return currentAmplifier?.name ?? "No amplifier"
        }
    }

    init() {
        mustang = Mustang(mockMode: mocking)
        presets = [UInt8 : DTOPreset] ()
        currentAmplifier = nil
        configureNotifications()
        amplifiers = mustang.getConnectedAmplifiers()
        currentAmplifier = amplifiers.first
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func configureNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(deviceConnected), name: NSNotification.Name(rawValue: Mustang.deviceConnectedNotificationName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOpened), name: NSNotification.Name(rawValue: Mustang.deviceOpenedNotificationName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceClosed), name: NSNotification.Name(rawValue: Mustang.deviceClosedNotificationName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDisconnected), name: NSNotification.Name(rawValue: Mustang.deviceDisconnectedNotificationName), object: nil)
    }

    @objc fileprivate func deviceConnected() {
        presets = [UInt8 : DTOPreset] ()
        currentAmplifier = nil
        amplifiers = mustang.getConnectedAmplifiers()
        currentAmplifier = amplifiers.first
        delegate?.deviceConnected(ampManager: self)
    }
    
    @objc fileprivate func deviceOpened() {
        delegate?.deviceOpened(ampManager: self)
    }
    
    @objc fileprivate func deviceClosed() {
        delegate?.deviceClosed(ampManager: self)
    }
    
    @objc fileprivate func deviceDisconnected() {
        presets = [UInt8 : DTOPreset] ()
        currentAmplifier = nil
        amplifiers = [DTOAmplifier]()
        currentAmplifier = nil
        delegate?.deviceDisconnected(ampManager: self)
    }
    
    func getPresets(_ onCompletion: @escaping () -> ()) {
        if let amplifier = currentAmplifier {
            mustang.getPresets(amplifier) { (presets) in
                for preset in presets {
                    if let number = preset.number {
                        self.presets[number] = preset
                    } else {
                        NSLog("Got a preset with no number, cannot use it")
                    }
                }
                onCompletion()
            }
        }
    }
    
    open func getCachedPreset(_ preset: Int, onCompletion: @escaping (_ preset: DTOPreset?) ->()) {
        if let _ = currentAmplifier {
            if preset >= 0 && preset < presets.count {
                onCompletion(presets[UInt8(preset)])
            }
        }
    }
    
    open func getPreset(_ preset: Int, onCompletion: @escaping (_ preset: DTOPreset?) ->()) {
        if let amplifier = currentAmplifier {
            if preset >= 0 && preset < presets.count && presets[UInt8(preset)]?.gain1 != nil {
                onCompletion(presets[UInt8(preset)])
            } else {
                mustang.getPreset(
                    amplifier,
                    preset: UInt8(preset)) { (preset) in
                        DispatchQueue.main.async {
                            if let preset = preset {
                                if let number = preset.number {
                                    self.presets[number] = preset
                                    onCompletion(preset)
                                }
                            }
                        }
                }
            }
        }
    }
    
    open func resetPreset(_ preset: Int, onCompletion: @escaping (_ preset: DTOPreset?) ->()) {
        if let amplifier = currentAmplifier {
            mustang.getPreset(
                amplifier,
                preset: UInt8(preset)) { (preset) in
                    DispatchQueue.main.async {
                        if let preset = preset {
                            if let number = preset.number {
                                self.presets[number] = preset
                                onCompletion(preset)
                            }
                        }
                    }
            }
        }
    }

    open func setPreset(_ preset: DTOPreset, onCompletion: @escaping (_ preset: DTOPreset?) ->()) {
        if let amplifier = currentAmplifier {
            if preset.gain1 == nil {
                onCompletion(nil)
            } else {
                mustang.setPreset(
                    amplifier,
                    preset: preset) { (preset) in
                        DispatchQueue.main.async {
                            if let preset = preset {
                                if let number = preset.number {
                                    self.presets[number] = preset
                                    onCompletion(preset)
                                }
                            }
                        }
                }
            }
        }
    }
    
    open func savePreset(_ preset: DTOPreset, onCompletion: @escaping (_ saved: Bool?) ->()) {
        if let amplifier = currentAmplifier {
            if let number = preset.number {
                mustang.savePreset(
                    amplifier,
                    preset: number,
                    name: preset.name) { (saved) in
                        DispatchQueue.main.async {
                            onCompletion(saved)
                        }
                }
            } else {
                onCompletion(nil)
            }
        }
    }

    open func login(username: String,
                    password: String,
                    onCompletion: @escaping (_ loggedIn: Bool) ->()) {
        mustang.login(username: username,
                      password: password,
                      onSuccess: {
                        DispatchQueue.main.async {
                            NSLog("Logged in")
                            onCompletion(true)
                        }},
                      onFail: {
                        DispatchQueue.main.async {
                            NSLog("Login failure")
                            onCompletion(false)
                        }}
        )
    }
    
    open func search(forTitle title: String,
                     pageNumber: UInt,
                     maxReturn: UInt,
                     onCompletion: @escaping (_ response: DTOSearchResponse?) ->()) {
        mustang.search(forTitle: title,
                       pageNumber: pageNumber,
                       maxReturn: maxReturn,
                       onSuccess: { (response) in
                        DispatchQueue.main.async {
                            NSLog("Searched")
                            onCompletion(response)
                        }},
                       onFail: {
                        DispatchQueue.main.async {
                            NSLog("Search failure")
                            onCompletion(nil)
                        }}
        )
    }
    
    open func logout(onCompletion: @escaping (_ loggedOut: Bool) ->()) {
        mustang.logout(onSuccess: {
                        DispatchQueue.main.async {
                            NSLog("Logged out")
                            onCompletion(true)
                        }},
                      onFail: {
                        DispatchQueue.main.async {
                            NSLog("Logout failure")
                            onCompletion(false)
                        }}
        )
    }
    
    open func importPreset(_ xml: XMLDocument) -> DTOPreset? {
        return mustang.importPreset(xml)
    }
    
    open func exportPresetAsXml(_ preset: DTOPreset) -> XMLDocument? {
        return mustang.exportPresetAsXml(preset: preset)
    }
}

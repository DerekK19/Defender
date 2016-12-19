//
//  AmpManager.swift
//  Defender
//
//  Created by Derek Knight on 11/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa
import Flogger
import Mustang

protocol AmpManagerDelegate {
    func deviceConnected(ampManager: AmpManager)
    func deviceDisconnected(ampManager: AmpManager)
    func deviceOpened(ampManager: AmpManager)
    func presetCountChanged(ampManager: AmpManager, to: UInt)
    func deviceClosed(ampManager: AmpManager)
    func gainChanged(ampManager: AmpManager, by: Float)
    func volumeChanged(ampManager: AmpManager, by: Float)
    func trebleChanged(ampManager: AmpManager, by: Float)
    func middleChanged(ampManager: AmpManager, by: Float)
    func bassChanged(ampManager: AmpManager, by: Float)
    func presenceChanged(ampManager: AmpManager, by: Float)
}

class AmpManager {
    
    var delegate: AmpManagerDelegate?
    
    private let mustang: Mustang
    
    let mocking = false
    
    private var amplifiers = [DTOAmplifier]()
    internal private(set) var currentAmplifier: DTOAmplifier?
    
    private var presets = [UInt8 : DTOPreset] ()
    private var latestGain: Float?
    private var latestVolume: Float?
    private var latestTreble: Float?
    private var latestMiddle: Float?
    private var latestBass: Float?
    private var latestPresence: Float?

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
        NotificationCenter.default.addObserver(self, selector: #selector(gainChanged), name: NSNotification.Name(rawValue: Mustang.gainChangedNotificationName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(volumeChanged), name: NSNotification.Name(rawValue: Mustang.volumeChangedNotificationName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(trebleChanged), name: NSNotification.Name(rawValue: Mustang.trebleChangedNotificationName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(middleChanged), name: NSNotification.Name(rawValue: Mustang.middleChangedNotificationName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bassChanged), name: NSNotification.Name(rawValue: Mustang.bassChangedNotificationName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presenceChanged), name: NSNotification.Name(rawValue: Mustang.presenceChangedNotificationName), object: nil)
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
    
    @objc fileprivate func gainChanged(notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            if let value = userInfo["value"] as? Float {
                if let latestGain = latestGain {
                    
                    delegate?.gainChanged(ampManager: self, by: (value - latestGain) * 10.0)
                }
                latestGain = value
            }
        }
    }
    
    @objc fileprivate func volumeChanged(notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            if let value = userInfo["value"] as? Float {
                if let latestVolume = latestVolume {
                    delegate?.volumeChanged(ampManager: self, by: (value - latestVolume) * 10.0)
                }
                latestVolume = value
            }
        }
    }
    
    @objc fileprivate func trebleChanged(notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            if let value = userInfo["value"] as? Float {
                if let latestTreble = latestTreble {
                    delegate?.trebleChanged(ampManager: self, by: (value - latestTreble) * 10.0)
                }
                latestTreble = value
            }
        }
    }
    
    @objc fileprivate func middleChanged(notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            if let value = userInfo["value"] as? Float {
                if let latestMiddle = latestMiddle {
                    delegate?.middleChanged(ampManager: self, by: (value - latestMiddle) * 10.0)
                }
                latestMiddle = value
            }
        }
    }
    
    @objc fileprivate func bassChanged(notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            if let value = userInfo["value"] as? Float {
                if let latestBass = latestBass {
                    delegate?.bassChanged(ampManager: self, by: (value - latestBass) * 10.0)
                }
                latestBass = value
            }
        }
    }
    
    @objc fileprivate func presenceChanged(notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            if let value = userInfo["value"] as? Float {
                if let latestPresence = latestPresence {
                    delegate?.presenceChanged(ampManager: self, by: (value - latestPresence) * 10.0)
                }
                latestPresence = value
            }
        }
    }
    
    func getPresets(_ onCompletion: @escaping () -> ()) {
        if let amplifier = currentAmplifier {
            mustang.getPresets(amplifier) { (presets) in
                for preset in presets {
                    if let number = preset.number {
                        self.presets[number] = preset
                    } else {
                        Flogger.log.error("Got a preset with no number, cannot use it")
                    }
                }
                onCompletion()
            }
        }
    }
    
    open func loadAllPresets(_ onCompletion: @escaping (_ allLoaded: Bool) ->()) {
        if !mocking {
            DispatchQueue.global().async {
                let serialQueue = DispatchQueue(label: "presetqueue")
                if let amplifier = self.currentAmplifier {
                    let semaphore = DispatchSemaphore(value: 0)
                    semaphore.signal()
                    for i in 0..<self.presets.count {
                        if self.presets[UInt8(i)]?.gain1 != nil { continue }
                        semaphore.wait()
                        serialQueue.async {
                            self.mustang.getPreset(
                                amplifier,
                                preset: UInt8(i)) { (preset) in
                                    if let preset = preset {
                                        if let number = preset.number {
                                            self.presets[number] = preset
                                        }
                                    }
                                    self.delegate?.presetCountChanged(ampManager: self, to: UInt(self.presets.filter({$0.value.gain1 != nil}).count))
                                    semaphore.signal()
                            }
                        }
                    }
                    onCompletion(self.presets.filter({$0.value.gain1 != nil}).count == 100)
                }
            }
        } else {
            onCompletion(self.presets.filter({$0.value.gain1 != nil}).count == 100)
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
                            self.delegate?.presetCountChanged(ampManager: self, to: UInt(self.presets.filter({$0.value.gain1 != nil}).count))
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
                        self.addPreset(preset, onCompletion: onCompletion)
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
                            self.addPreset(preset, onCompletion: onCompletion)
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
                            Flogger.log.verbose("Logged in")
                            onCompletion(true)
                        }},
                      onFail: {
                        DispatchQueue.main.async {
                            Flogger.log.error("Login failure")
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
                            Flogger.log.verbose("Searched")
                            onCompletion(response)
                        }},
                       onFail: {
                        DispatchQueue.main.async {
                            Flogger.log.error("Search failure")
                            onCompletion(nil)
                        }}
        )
    }
    
    open func logout(onCompletion: @escaping (_ loggedOut: Bool) ->()) {
        mustang.logout(onSuccess: {
                        DispatchQueue.main.async {
                            Flogger.log.verbose("Logged out")
                            onCompletion(true)
                        }},
                      onFail: {
                        DispatchQueue.main.async {
                            Flogger.log.error("Logout failure")
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
    
    open func saveBackup() {
        
    }
    
    open func restoreFromBackup(name: String) {
        
        let backupRoot = "\(NSHomeDirectory())/Documents/Fender/FUSE/Backups"
        let fileManager = FileManager()
        fileManager.changeCurrentDirectoryPath(backupRoot)
        if fileManager.currentDirectoryPath != backupRoot {
            Flogger.log.error("There is no backup root folder - \(backupRoot)")
            return
        }
        do {
            let backupFolder = "\(backupRoot)/\(name)"
            fileManager.changeCurrentDirectoryPath(backupFolder)
            if fileManager.currentDirectoryPath != backupFolder {
                Flogger.log.error("There is no backup folder - \(backupFolder)")
                return
            }
            let fuseFilesNames = try fileManager.contentsOfDirectory(atPath: "FUSE")
            let presetFilesNames = try fileManager.contentsOfDirectory(atPath: "Presets")
            if fuseFilesNames.count != presetFilesNames.count {
                Flogger.log.error("The number of preset files should be the same as the number of fuse files")
                return
            }
            for file in fuseFilesNames {
                let fusePath = "FUSE/\(file)"
                let presetNumber = file.replacingOccurrences(of: ".fuse", with: "")
                do {
                    let document = try XMLDocument(contentsOf: URL(fileURLWithPath: fusePath), options: 0)
                    if let info = document.rootElement()?.elements(forName: "Info").first {
                        if let name = info.attribute(forName: "name")?.stringValue {
                            let presetPath = "Presets/\(presetNumber)_\(name).fuse"
                            do {
                                let document = try XMLDocument(contentsOf: URL(fileURLWithPath:  presetPath), options: 0)
                                var preset = Mustang().importPreset(document)
                                if preset != nil {
                                    preset?.number = UInt8(presetNumber)
                                    self.addPreset(preset, onCompletion: { preset in })
                                }
                            }
                            catch {
                                Flogger.log.error("Couldn't read Preset XML file \(presetPath)")
                            }
                        }
                    }
                    self.delegate?.presetCountChanged(ampManager: self, to: UInt(self.presets.filter({$0.value.gain1 != nil}).count))
                }
                catch {
                    Flogger.log.error("Couldn't read FUSE XML file \(fusePath)")
                }
            }
        } catch {
            Flogger.log.error("Failed to find backups")
        }
    }

    fileprivate func addPreset(_ preset: DTOPreset?,  onCompletion: @escaping (_ preset: DTOPreset?) ->()) {
        if let preset = preset {
            if let number = preset.number {
                self.presets[number] = preset
                onCompletion(preset)
            }
        }
    }
}

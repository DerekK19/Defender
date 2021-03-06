//
//  AmpManager.swift
//  Defender
//
//  Created by Derek Knight on 11/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

protocol AmpManagerDelegate {
    func deviceConnected(ampManager: AmpManager)
    func deviceDisconnected(ampManager: AmpManager)
    func deviceOpened(ampManager: AmpManager)
    func presetCountChanged(ampManager: AmpManager, to: UInt)
    func deviceClosed(ampManager: AmpManager)
    func presetChanged(ampManager: AmpManager, to preset: BOPreset)
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
    
    private var amplifiers = [BOAmplifier]()
    internal private(set) var currentAmplifier: BOAmplifier?
    
    private var presets = [UInt8 : BOPreset] ()
    private var latestPreset: BOPreset?
    private var latestGain: Float?
    private var latestVolume: Float?
    private var latestTreble: Float?
    private var latestMiddle: Float?
    private var latestBass: Float?
    private var latestPresence: Float?

    private let backupNameDateFormat = "yyyy_MM_dd_HH_mm_ss"
    private let backupNameRegex = "\\d{4}_\\d{2}_\\d{2}_\\d{2}_\\d{2}_\\d{2}"
    
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

    var presetNames : [String] {
        get {
            return presets.sorted(by: { $0.key < $1.key }).map { $0.value.name ?? "Unnamed" }
        }
    }
    
    init() {
        mustang = Mustang(mockMode: mocking)
        presets = [UInt8 : BOPreset] ()
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
        NotificationCenter.default.addObserver(self, selector: #selector(didSelectPreset), name: NSNotification.Name(rawValue: Mustang.didSelectPreset), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(gainChanged), name: NSNotification.Name(rawValue: Mustang.gainDidChange), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(volumeChanged), name: NSNotification.Name(rawValue: Mustang.volumeDidChange), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(trebleChanged), name: NSNotification.Name(rawValue: Mustang.trebleDidChange), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(middleChanged), name: NSNotification.Name(rawValue: Mustang.middleDidChange), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bassChanged), name: NSNotification.Name(rawValue: Mustang.bassDidChange), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presenceChanged), name: NSNotification.Name(rawValue: Mustang.presenceDidChange), object: nil)
    }

    @objc fileprivate func deviceConnected() {
        presets = [UInt8 : BOPreset] ()
        currentAmplifier = nil
        amplifiers = mustang.getConnectedAmplifiers()
        currentAmplifier = amplifiers.first
        mustang.setCurrentAmplifier(currentAmplifier)
        DispatchQueue.main.async {
            self.delegate?.deviceConnected(ampManager: self)
        }
    }
    
    @objc fileprivate func deviceOpened() {
        DispatchQueue.main.async {
            self.delegate?.deviceOpened(ampManager: self)
        }
    }
    
    @objc fileprivate func deviceClosed() {
        DispatchQueue.main.async {
            self.delegate?.deviceClosed(ampManager: self)
        }
    }
    
    @objc fileprivate func deviceDisconnected() {
        presets = [UInt8 : BOPreset] ()
        currentAmplifier = nil
        amplifiers = [BOAmplifier]()
        currentAmplifier = nil
        DispatchQueue.main.async {
            self.delegate?.deviceDisconnected(ampManager: self)
        }
    }
    
    @objc fileprivate func didSelectPreset(notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            if let preset = userInfo["value"] as? BOPreset {
                if let _ = latestPreset {
                    DispatchQueue.main.async {
                        self.delegate?.presetChanged(ampManager: self, to: preset)
                    }
                }
                latestPreset = preset
            }
        }
    }
    
    @objc fileprivate func gainChanged(notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            if let value = userInfo["value"] as? Float {
                if let latestGain = latestGain {
                    DispatchQueue.main.async {
                        self.delegate?.gainChanged(ampManager: self, by: (value - latestGain) * 10.0)
                    }
                }
                latestGain = value
            }
        }
    }
    
    @objc fileprivate func volumeChanged(notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            if let value = userInfo["value"] as? Float {
                if let latestVolume = latestVolume {
                    DispatchQueue.main.async {
                        self.delegate?.volumeChanged(ampManager: self, by: (value - latestVolume) * 10.0)
                    }
                }
                latestVolume = value
            }
        }
    }
    
    @objc fileprivate func trebleChanged(notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            if let value = userInfo["value"] as? Float {
                if let latestTreble = latestTreble {
                    DispatchQueue.main.async {
                        self.delegate?.trebleChanged(ampManager: self, by: (value - latestTreble) * 10.0)
                    }
                }
                latestTreble = value
            }
        }
    }
    
    @objc fileprivate func middleChanged(notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            if let value = userInfo["value"] as? Float {
                if let latestMiddle = latestMiddle {
                    DispatchQueue.main.async {
                        self.delegate?.middleChanged(ampManager: self, by: (value - latestMiddle) * 10.0)
                    }
                }
                latestMiddle = value
            }
        }
    }
    
    @objc fileprivate func bassChanged(notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            if let value = userInfo["value"] as? Float {
                if let latestBass = latestBass {
                    DispatchQueue.main.async {
                        self.delegate?.bassChanged(ampManager: self, by: (value - latestBass) * 10.0)
                    }
                }
                latestBass = value
            }
        }
    }
    
    @objc fileprivate func presenceChanged(notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            if let value = userInfo["value"] as? Float {
                if let latestPresence = latestPresence {
                    DispatchQueue.main.async {
                        self.delegate?.presenceChanged(ampManager: self, by: (value - latestPresence) * 10.0)
                    }
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
                        ULog.error("Got a preset with no number, cannot use it")
                    }
                }
                DispatchQueue.main.async {
                    onCompletion()
                }
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
                                    if var preset = preset {
                                        if let number = preset.number {
                                            if preset.name == nil { preset.name = self.presetNames[Int(number)] }
                                            self.presets[number] = preset
                                        }
                                    }
                                    DispatchQueue.main.async {
                                        self.delegate?.presetCountChanged(ampManager: self, to: UInt(self.presets.filter({$0.value.gain1 != nil}).count))
                                    }
                                    semaphore.signal()
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        onCompletion(self.presets.filter({$0.value.gain1 != nil}).count == 100)
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                onCompletion(self.presets.filter({$0.value.gain1 != nil}).count == 100)
            }
        }
    }

    open func getCachedPreset(_ preset: Int, onCompletion: @escaping (_ preset: BOPreset?) ->()) {
        if let _ = currentAmplifier {
            if preset >= 0 && preset < presets.count {
                DispatchQueue.main.async {
                    onCompletion(self.presets[UInt8(preset)])
                }
            }
        }
    }
    
    open func getPreset(_ preset: Int, fromAmplifier: Bool, onCompletion: @escaping (_ preset: BOPreset?) ->()) {
        if let amplifier = currentAmplifier {
            if !fromAmplifier && preset >= 0 && preset < presets.count && presets[UInt8(preset)]?.gain1 != nil {
                DispatchQueue.main.async {
                    onCompletion(self.presets[UInt8(preset)])
                }
            } else {
                mustang.getPreset(
                    amplifier,
                    preset: UInt8(preset)) { (preset) in
                        if var preset = preset {
                            if let number = preset.number {
                                if preset.name == nil { preset.name = self.presetNames[Int(number)]}
                                self.latestPreset = preset
                                self.presets[number] = preset
                                DispatchQueue.main.async {
                                    onCompletion(preset)
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            self.delegate?.presetCountChanged(ampManager: self, to: UInt(self.presets.filter({$0.value.gain1 != nil}).count))
                        }
                }
            }
        }
    }
    
    open func resetPreset(_ preset: Int, onCompletion: @escaping (_ preset: BOPreset?) ->()) {
        if let amplifier = currentAmplifier {
            mustang.getPreset(
                amplifier,
                preset: UInt8(preset)) { (preset) in
                    self.addPreset(preset, onCompletion: onCompletion)
            }
        }
    }

    open func setPreset(_ preset: BOPreset, onCompletion: @escaping (_ preset: BOPreset?) ->()) {
        if let amplifier = currentAmplifier {
            if preset.gain1 == nil {
                onCompletion(nil)
            } else {
                mustang.setPreset(
                    amplifier,
                    preset: preset) { (preset) in
                        self.addPreset(preset, onCompletion: onCompletion)
                }
            }
        }
    }
    
    open func savePreset(_ preset: BOPreset, onCompletion: @escaping (_ saved: Bool?) ->()) {
        if let amplifier = currentAmplifier {
            if let number = preset.number {
                mustang.savePreset(
                    amplifier,
                    preset: number,
                    name: preset.name ?? "Unnamed") { (saved) in
                        DispatchQueue.main.async {
                            onCompletion(saved)
                        }
                }
            } else {
                onCompletion(nil)
            }
        }
    }

    open func verifyWeb(onCompletion: @escaping (_ available: Bool) ->()) {
        mustang.verifyWeb(onCompletion: onCompletion)
    }
    
    open func login(username: String,
                    password: String,
                    onCompletion: @escaping (_ loggedIn: Bool) ->()) {
        mustang.login(username: username,
                      password: password,
                      onSuccess: {
                        ULog.verbose("Logged in")
                        DispatchQueue.main.async {
                            onCompletion(true)
                        }},
                      onFail: {
                        ULog.error("Login failure")
                        DispatchQueue.main.async {
                            onCompletion(false)
                        }}
        )
    }
    
    open func search(forTitle title: String,
                     pageNumber: UInt,
                     maxReturn: UInt,
                     onCompletion: @escaping (_ response: BOSearchResponse?) ->()) {
        mustang.search(forTitle: title,
                       pageNumber: pageNumber,
                       maxReturn: maxReturn,
                       onSuccess: { (response) in
                        ULog.verbose("Searched")
                        DispatchQueue.main.async {
                            onCompletion(response)
                        }},
                       onFail: {
                        ULog.error("Search failure")
                        DispatchQueue.main.async {
                            onCompletion(nil)
                        }}
        )
    }
    
    open func logout(onCompletion: @escaping (_ loggedOut: Bool) ->()) {
        mustang.logout(onSuccess: {
                        ULog.verbose("Logged out")
                        DispatchQueue.main.async {
                            onCompletion(true)
                        }},
                      onFail: {
                        ULog.error("Logout failure")
                        DispatchQueue.main.async {
                            onCompletion(false)
                        }}
        )
    }
    
    open func importPreset(_ xml: XMLDocument) -> BOPreset? {
        return mustang.importPreset(xml)
    }
    
    open func exportPresetAsXml(_ preset: BOPreset) -> XMLDocument? {
        return mustang.exportPresetAsXml(preset: preset)
    }
    
    open func saveBackup() {
        let fileManager = FileManager()
        let backupRoot = "\(NSHomeDirectory())/Documents/Fender/FUSE/Backups"
        fileManager.changeCurrentDirectoryPath(backupRoot)
        if fileManager.currentDirectoryPath != backupRoot {
            ULog.error("There is no Backups folder - %@. Creating", backupRoot)
            do {
                try fileManager.createDirectory(atPath: backupRoot, withIntermediateDirectories: true)
            } catch {
                ULog.error("Unable to create Backups folder. Cannot create backup")
                return
            }
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = backupNameDateFormat
        let backupFolder = "\(backupRoot)/\(dateFormatter.string(from: Date()))"
        do {
            try fileManager.createDirectory(atPath: backupFolder, withIntermediateDirectories: true)
            fileManager.changeCurrentDirectoryPath(backupFolder)
            if fileManager.currentDirectoryPath != backupFolder {
                ULog.error("Unable to setup backup folder. Giving up")
                return
            }
            try fileManager.createDirectory(atPath: "FUSE", withIntermediateDirectories: true)
            try fileManager.createDirectory(atPath: "Presets", withIntermediateDirectories: true)
            let backupName = "Defender Backup".data(using: .utf8)
            let xmlOptions: XMLNode.Options = [.nodePrettyPrint, .nodeCompactEmptyElement]
            fileManager.createFile(atPath: "M2_BackupName.fuse", contents: backupName)
            for (_, preset) in presets.enumerated() {
                let index = String(format: "%02d", preset.key)
                let presetDoc = mustang.exportPresetAsXml(preset: preset.value)
                presetDoc?.characterEncoding = "utf-8"
                presetDoc?.version = "1.0"
                let presetXml = presetDoc?.xmlData(options: XMLNode.Options(rawValue: XMLNode.Options.RawValue(Int(xmlOptions.rawValue))))
                fileManager.createFile(atPath: "Presets/\(index)_\(preset.value.name ?? "Unknown").fuse", contents: presetXml)
                let fuseDoc = XMLDocument()
                let fuseElement = presetDoc?.rootElement()?.elements(forName: "FUSE").first
                let bandElement = presetDoc?.rootElement()?.elements(forName: "Band").first
                if let fuseNode = fuseElement?.copy() as? XMLElement {
                    if let bandNode = bandElement?.copy() as? XMLElement {
                        fuseNode.addChild(bandNode)
                    }
                    fuseDoc.addChild(fuseNode)
                }
                fuseDoc.characterEncoding = "utf-8"
                fuseDoc.version = "1.0"
                let fuseXml = fuseDoc.xmlData(options: XMLNode.Options(rawValue: XMLNode.Options.RawValue(Int(xmlOptions.rawValue))))
                fileManager.createFile(atPath: "FUSE/\(index).fuse", contents: fuseXml)
            }
        } catch {
            ULog.error("Unable to create backup folder. Giving up")
            return
        }
    }
    
    open func backups() -> [Date : String]? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = backupNameDateFormat
        let backupRoot = "\(NSHomeDirectory())/Documents/Fender/FUSE/Backups"
        let fileManager = FileManager()
        fileManager.changeCurrentDirectoryPath(backupRoot)
        if fileManager.currentDirectoryPath != backupRoot {
            ULog.error("There is no backup root folder - %@", backupRoot)
            return nil
        }
        var backups = [Date : String]()
        do {
            let folderNames = try fileManager.contentsOfDirectory(atPath: ".")
            for folder in folderNames {
                if folder.range(of: backupNameRegex, options: .regularExpression) != nil {
                    if let date = dateFormatter.date(from: folder) {
                        let namePath = "\(folder)/M2_BackupName.fuse"
                        if let data = fileManager.contents(atPath: namePath) {
                            let backupName = String(bytes: data, encoding: .utf8)
                            backups[date] = backupName
                        } else {
                            ULog.error("Failed to get backup name for %@", folder)
                        }
                    } else {
                        ULog.error("Couldn't convert %@ to a date. Ignoring", folder)
                    }
                } else {
                    ULog.info("Folder %@ doesn't look like a backup. Ignoring", folder)
                }
            }
            return backups
        } catch {
            ULog.error("Failed to find backups")
            return nil
        }
    }

    open func restoreFromBackup(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = backupNameDateFormat
        let name = dateFormatter.string(from: date)
        let backupRoot = "\(NSHomeDirectory())/Documents/Fender/FUSE/Backups"
        let fileManager = FileManager()
        fileManager.changeCurrentDirectoryPath(backupRoot)
        if fileManager.currentDirectoryPath != backupRoot {
            ULog.error("There is no backup root folder %@", backupRoot)
            return
        }
        do {
            let backupFolder = "\(backupRoot)/\(name)"
            fileManager.changeCurrentDirectoryPath(backupFolder)
            if fileManager.currentDirectoryPath != backupFolder {
                ULog.error("There is no backup folder - %@", backupFolder)
                return
            }
            let fuseFilesNames = try fileManager.contentsOfDirectory(atPath: "FUSE")
            let presetFilesNames = try fileManager.contentsOfDirectory(atPath: "Presets")
            if fuseFilesNames.count != presetFilesNames.count {
                ULog.error("The number of preset files should be the same as the number of fuse files")
                return
            }
            for file in fuseFilesNames {
                let fusePath = "FUSE/\(file)"
                let presetNumber = file.replacingOccurrences(of: ".fuse", with: "")
                do {
                    let document = try XMLDocument(contentsOf: URL(fileURLWithPath: fusePath), options: XMLNode.Options(rawValue: 0))
                    if let info = document.rootElement()?.elements(forName: "Info").first {
                        if let name = info.attribute(forName: "name")?.stringValue {
                            let presetPath = "Presets/\(presetNumber)_\(name).fuse"
                            do {
                                let document = try XMLDocument(contentsOf: URL(fileURLWithPath:  presetPath), options: XMLNode.Options(rawValue: 0))
                                var preset = Mustang().importPreset(document)
                                if preset != nil {
                                    preset?.number = UInt8(presetNumber)
                                    self.addPreset(preset, onCompletion: { preset in })
                                }
                            }
                            catch {
                                ULog.error("Couldn't read Preset XML file %@", presetPath)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.delegate?.presetCountChanged(ampManager: self, to: UInt(self.presets.filter({$0.value.gain1 != nil}).count))
                    }
                }
                catch {
                    ULog.error("Couldn't read FUSE XML file %@", fusePath)
                }
            }
        } catch {
            ULog.error("Failed to find backups")
        }
    }

    fileprivate func addPreset(_ preset: BOPreset?,  onCompletion: @escaping (_ preset: BOPreset?) ->()) {
        if let preset = preset {
            if let number = preset.number {
                self.presets[number] = preset
                DispatchQueue.main.async {
                    onCompletion(preset)
                }
            }
        }
    }
}

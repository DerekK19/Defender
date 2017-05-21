//
//  WatchManager.swift
//  DefenderApp
//
//  Created by Derek Knight on 19/01/17.
//  Copyright © 2017 Derek Knight. All rights reserved.
//

import Foundation

protocol WatchManagerDelegate {
    func watchManager(_ manager: WatchManager, didChoosePreset index: UInt8)
}

class WatchManager {
 
    var delegate: WatchManagerDelegate?

    var watchController: WatchSessionController

    init(delegate: WatchManagerDelegate? = nil) {
        self.delegate = delegate
        watchController = WatchSessionController()
        watchController.delegate = self
        watchController.sendMessage(.hello)
    }
    
    func start() {
        watchController.sendMessage(.active)
    }
    
    func stop() {
        watchController.sendMessage(.inactive)
    }
    
    func connect() {
        watchController.sendMessage(.connect, content: "")
    }

    func disconnect() {
        watchController.sendMessage(.disconnect, content: "")
    }
    
    func amplifier(_ name: String) {
        watchController.sendMessage(.amplifier, content: name)
    }
    
    func preset(_ name: String) {
        watchController.sendMessage(.preset, content: name)
    }

    func presets(_ names: [String]) {
        watchController.sendMessage(.presets, content: names)
    }
}

extension WatchManager: WatchSessionControllerDelegate {
    
    func controller(_ controller: WatchSessionController, currentPreset: UInt8) {
        delegate?.watchManager(self, didChoosePreset: currentPreset)
    }
}

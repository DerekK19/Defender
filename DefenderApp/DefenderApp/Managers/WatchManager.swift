//
//  WatchManager.swift
//  DefenderApp
//
//  Created by Derek Knight on 19/01/17.
//  Copyright © 2017 Derek Knight. All rights reserved.
//

import Foundation

class WatchManager {
 
    var watchController: WatchSessionController

    init() {
        watchController = WatchSessionController()
        watchController.sendMessage("Hello world")
    }
    
    func start() {
        watchController.sendMessage("I'm active")
    }
    
    func stop() {
        watchController.sendMessage("I'm inactive")
    }
    
    func connect() {
        watchController.sendMessage("CONNECT", content: "")
    }

    func disconnect() {
        watchController.sendMessage("DISCONNECT", content: "")
    }
}

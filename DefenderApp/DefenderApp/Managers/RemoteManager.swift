//
//  RemoteManager.swift
//  DefenderApp
//
//  Created by Derek Knight on 15/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import RemoteDefender

protocol RemoteManagerDelegate {
    func remoteManagerAvailable(_ manager: RemoteManager)
    func remoteManagerConnected(_ manager: RemoteManager)
    func remoteManagerDisconnected(_ manager: RemoteManager)
    func remoteManagerUnavailable(_ manager: RemoteManager)
}

class RemoteManager {
    
    var delegate: RemoteManagerDelegate?
    
    let central = Central()
    
    init(delegate: RemoteManagerDelegate? = nil) {
        self.delegate = delegate
        CentralNotification.centralBecameAvailable.observe() { manager in
            self.delegate?.remoteManagerAvailable(self)
        }
        CentralNotification.centralDidConnect.observe() { manager in
            self.delegate?.remoteManagerConnected(self)
        }
        CentralNotification.centralDidDisconnect.observe() { manager in
            self.delegate?.remoteManagerDisconnected(self)
        }
        CentralNotification.centralBecameUnavailable.observe() { manager in
            self.delegate?.remoteManagerUnavailable(self)
        }
    }
    
    func start() {
        central.start()
    }
    
    func stop() {
        central.stop()
    }
    
    deinit {
        central.stop()
        NotificationCenter.default.removeObserver(self)
    }
    
}


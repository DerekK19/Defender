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
    func remoteManager(_ manager: RemoteManager, didSend success: Bool)
    func remoteManager(_ manager: RemoteManager, didReceive data: Data)
    func remoteManagerDisconnected(_ manager: RemoteManager)
    func remoteManagerUnavailable(_ manager: RemoteManager)
}

class RemoteManager {
    
    var delegate: RemoteManagerDelegate?
    
    let central = Central()
    
    init(delegate: RemoteManagerDelegate? = nil) {
        self.delegate = delegate
        CentralNotification.centralBecameAvailable.observe() { notification in
            self.delegate?.remoteManagerAvailable(self)
        }
        CentralNotification.centralDidConnect.observe() { notification in
            self.delegate?.remoteManagerConnected(self)
        }
        CentralNotification.centralDidDisconnect.observe() { notification in
            self.delegate?.remoteManagerDisconnected(self)
        }
        CentralNotification.centralBecameUnavailable.observe() { notification in
            self.delegate?.remoteManagerUnavailable(self)
        }
        CentralNotification.centralDidReceive.observe() { notification in
            if let data = notification.object as? Data {
                self.delegate?.remoteManager(self, didReceive: data)
            }
        }
    }
    
    func start() {
        central.start()
    }
    
    func send(_ string: String) -> Bool {
        if let data = string.data(using: .ascii) {
                central.send(data: data) { success in
                    self.delegate?.remoteManager(self, didSend: success)
            }
            return true
        }
        return false
    }
    
    func stop() {
        central.stop()
    }
    
    deinit {
        central.stop()
        NotificationCenter.default.removeObserver(self)
    }
    
}


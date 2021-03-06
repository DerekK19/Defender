//
//  RemoteManager.swift
//  DefenderApp
//
//  Created by Derek Knight on 15/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

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
    
    let central = Central(mockMode: false)
    
    init(delegate: RemoteManagerDelegate? = nil) {
        self.delegate = delegate
        CentralNotification.centralBecameAvailable.observe() { notification in
            DispatchQueue.main.async {
                self.delegate?.remoteManagerAvailable(self)
            }
        }
        CentralNotification.centralDidConnect.observe() { notification in
            DispatchQueue.main.async {
                self.delegate?.remoteManagerConnected(self)
            }
        }
        CentralNotification.centralDidDisconnect.observe() { notification in
            DispatchQueue.main.async {
                self.delegate?.remoteManagerDisconnected(self)
            }
        }
        CentralNotification.centralBecameUnavailable.observe() { notification in
            DispatchQueue.main.async {
                self.delegate?.remoteManagerUnavailable(self)
            }
        }
        CentralNotification.centralDidReceive.observe() { notification in
            if let object = notification.object as? RemoteData {
                DispatchQueue.main.async {
                    self.delegate?.remoteManager(self, didReceive: object.data)
                }
            }
        }
    }
    
    func start() {
        central.start()
    }
    
    func rescan() {
        central.rescan()
    }
    
    func send(_ object: Transferable) -> Bool {
        if let data = object.data {
            central.send(data: data) { success in
                DispatchQueue.main.async {
                    self.delegate?.remoteManager(self, didSend: success)
                }
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


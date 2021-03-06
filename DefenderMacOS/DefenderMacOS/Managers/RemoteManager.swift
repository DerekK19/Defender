//
//  RemoteManager.swift
//  Defender
//
//  Created by Derek Knight on 13/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

protocol RemoteManagerDelegate {
    func remoteManagerDidStart(_ manager: RemoteManager)
    func remoteManagerDidConnect(_ manager: RemoteManager)
    func remoteManager(_ manager: RemoteManager, didSend success: Bool)
    func remoteManager(_ manager: RemoteManager, didReceive data: Data)
    func remoteManagerDidDisconnect(_ manager: RemoteManager)
    func remoteManagerDidStop(_ manager: RemoteManager)
}

class RemoteManager {
    
    var delegate: RemoteManagerDelegate?
    
    let peripheral = Peripheral(mockMode: false)
    
    init(delegate: RemoteManagerDelegate? = nil) {
        self.delegate = delegate
        PeripheralNotification.peripheralStarted.observe() { notification in
            DispatchQueue.main.async {
                self.delegate?.remoteManagerDidStart(self)
            }
        }
        PeripheralNotification.peripheralStopped.observe() { notification in
            DispatchQueue.main.async {
                self.delegate?.remoteManagerDidStop(self)
            }
        }
        PeripheralNotification.peripheralConnected.observe() { notification in
            DispatchQueue.main.async {
                self.delegate?.remoteManagerDidConnect(self)
            }
        }
        PeripheralNotification.peripheralDisconnected.observe() { notification in
            DispatchQueue.main.async {
                self.delegate?.remoteManagerDidDisconnect(self)
            }
        }
        PeripheralNotification.peripheralDidReceive.observe() { notification in
            if let object = notification.object as? RemoteData {
                DispatchQueue.main.async {
                    self.delegate?.remoteManager(self, didReceive: object.data)
                }
            }
        }
    }
    
    func start() {
        peripheral.start()
    }
    
    func send(_ object: Transferable) -> Bool {
        if let data = object.data {
            peripheral.send(data: data) { success in
                DispatchQueue.main.async {
                    self.delegate?.remoteManager(self, didSend: success)
                }
            }
            return true
        }
        return false
    }
    
    func stop() {
        peripheral.stop()
    }
    
    deinit {
        peripheral.stop()
        NotificationCenter.default.removeObserver(self)
    }
    
}


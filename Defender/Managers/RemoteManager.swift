//
//  RemoteManager.swift
//  Defender
//
//  Created by Derek Knight on 13/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import RemoteDefender

protocol RemoteManagerDelegate {
    func remoteManagerDidStart(_ manager: RemoteManager)
    func remoteManagerDidStop(_ manager: RemoteManager)
    func remoteManagerDidConnect(_ manager: RemoteManager)
    func remoteManagerDidDisconnect(_ manager: RemoteManager)
}

class RemoteManager {
    
    var delegate: RemoteManagerDelegate?
    
    let peripheral = Peripheral()
    
    init(delegate: RemoteManagerDelegate? = nil) {
        self.delegate = delegate
        PeripheralNotification.peripheralStarted.observe() { manager in
            self.delegate?.remoteManagerDidStart(self)
        }
        PeripheralNotification.peripheralStopped.observe() { manager in
            self.delegate?.remoteManagerDidStop(self)
        }
        PeripheralNotification.peripheralConnected.observe() { manager in
            self.delegate?.remoteManagerDidConnect(self)
        }
        PeripheralNotification.peripheralDisconnected.observe() { manager in
            self.delegate?.remoteManagerDidDisconnect(self)
        }
        peripheral.start()
    }
    
    deinit {
        peripheral.stop()
        NotificationCenter.default.removeObserver(self)
    }
    
}


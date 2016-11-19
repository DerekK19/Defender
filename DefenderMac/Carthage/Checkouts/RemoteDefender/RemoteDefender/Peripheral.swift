//
//  Peripheral.swift
//  RemoteDefender
//
//  Created by Derek Knight on 13/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

public enum PeripheralNotification : String {
    case peripheralStarted = "peripheralStarted"
    case peripheralConnected = "peripheralConnected"
    case peripheralDidReceive = "centralDidReceive"
    case peripheralDisconnected = "peripheralDisconnected"
    case peripheralStopped = "peripheralStopped"
    
    func post(_ peripheral: Peripheral) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: self.rawValue), object: peripheral)
    }
    func post(_ peripheral: Peripheral, data: Data) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: self.rawValue), object: RemoteData(sender: peripheral, data: data))
    }
    
    public func observe(_ block: @escaping (Notification) -> ()) {
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: self.rawValue), object: nil, queue: nil, using: block)
    }    
}

public class Peripheral {
    
    var manager : PeripheralManager

    public init(mockMode: Bool = false, verbose: Bool = false) {
        if mockMode {
            manager = PeripheralManager.mockInstance
            manager.delegate = self
            manager.verbose = verbose
        } else {
            manager = PeripheralManager.realInstance
            manager.delegate = self
            manager.verbose = verbose
        }
    }

    public func start() {
        manager.startPeripheral()
    }
    
    public func send(data: Data, onCompletion: @escaping (_ success: Bool) -> ()) {
        manager.sendData(data) { (success) in
            onCompletion(success)
        }
    }
    
    public func stop() {
        manager.stopPeripheral()
    }
}

extension Peripheral: PeripheralManagerDelegate {
    
    func peripheralManagerDidStart(_ manager: PeripheralManager) {
        PeripheralNotification.peripheralStarted.post(self)
    }
    
    func peripheralManagerDidConnect(_ manager: PeripheralManager, remote: Any?) {
        PeripheralNotification.peripheralConnected.post(self)
    }
    
    func peripheralManagerDidReceiveData(_ manager: PeripheralManager, data: Data) {
        PeripheralNotification.peripheralDidReceive.post(self, data: data)
    }
    func peripheralManagerDidDisconnect(_ manager: PeripheralManager, remote: Any?) {
        PeripheralNotification.peripheralDisconnected.post(self)
    }

    func peripheralManagerDidStop(_ manager: PeripheralManager) {
        PeripheralNotification.peripheralStopped.post(self)
    }
}

//
//  Central.swift
//  RemoteDefender
//
//  Created by Derek Knight on 14/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation

public enum CentralNotification : String {
    case centralBecameAvailable = "centralBecameAvailable"
    case centralDidConnect = "centralDidConnect"
    case centralDidReceive = "centralDidReceive"
    case centralDidDisconnect = "centralDidDisconnect"
    case centralBecameUnavailable = "centralBecameUnavailable"
    
    func post(_ central: Central) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: self.rawValue), object: central)
    }
    func post(_ central: Central, data: Data) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: self.rawValue), object: RemoteData(sender: central, data: data))
    }
    
    public func observe(_ block: @escaping (Notification) -> ()) {
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: self.rawValue), object: nil, queue: nil, using: block)
    }    
}

public class Central {

    var manager: CentralManager
    
    public init(mockMode: Bool = false, verbose: Bool = false) {
        if mockMode {
            manager = CentralManager.mockInstance
            manager.delegate = self
            manager.verbose = verbose
        } else {
            manager = CentralManager.realInstance
            manager.delegate = self
            manager.verbose = verbose
        }
    }
    
    public func start() {
        manager.startCentral()
    }
    
    public func rescan() {
        manager.scan()
    }
    
    public func send(data: Data, onCompletion: @escaping (_ success: Bool) -> ()) {
        manager.sendData(data) { (success) in
            onCompletion(success)
        }
    }

    public func disconnect() {
        manager.disconnect()
    }
    
    public func stop() {
        manager.stopCentral()
    }
}

extension Central: CentralManagerDelegate {
    
    func centralManagerDidBecomeAvailable(_ manager: CentralManager) {
        manager.scan()
        CentralNotification.centralBecameAvailable.post(self)
    }
    
    func centralManagerDidConnect(_ manager: CentralManager, remote: Any?) {
        CentralNotification.centralDidConnect.post(self)
    }
    
    func centralManagerDidReceiveData(_ manager: CentralManager, data: Data) {
        CentralNotification.centralDidReceive.post(self, data: data)
    }

    func centralManagerDidDisconnect(_ manager: CentralManager, remote: Any?) {
        CentralNotification.centralDidDisconnect.post(self)
    }

    func centralManagerDidBecomeUnavailable(_ manager: CentralManager) {
        manager.stopCentral()
        CentralNotification.centralBecameUnavailable.post(self)
    }
}

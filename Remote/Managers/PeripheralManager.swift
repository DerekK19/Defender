//
//  PeripheralManager.swift
//  Defender Remote
//
//  Created by Derek Knight on 13/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import BluetoothKit

private let singleton = PeripheralManager(mockMode: false)
private let mockSingleton = PeripheralManager(mockMode: true)

internal protocol PeripheralManagerDelegate {
    func peripheralManagerDidStart(_ manager: PeripheralManager)
    func peripheralManagerDidConnect(_ manager: PeripheralManager, remote: Any?)
    func peripheralManagerDidReceiveData(_ manager: PeripheralManager, data: Data)
    func peripheralManagerDidDisconnect(_ manager: PeripheralManager, remote: Any?)
    func peripheralManagerDidStop(_ manager: PeripheralManager)
}

internal class PeripheralManager {
    
    class var realInstance: PeripheralManager {
        return singleton
    }
    
    class var mockInstance: PeripheralManager {
        return mockSingleton
    }

    var peripheral: BKPeripheral!
    var delegate: PeripheralManagerDelegate?

    internal init(mockMode: Bool = false) {
        if mockMode {
            self.peripheral = BKPeripheral()
            self.peripheral.delegate = self
        } else {
            self.peripheral = BKPeripheral()
            self.peripheral.delegate = self
        }
    }
    
    internal func startPeripheral() {
        ULog.verbose("startPeripheral")
        do {
            let localName = "Defender"
            let configuration = BKPeripheralConfiguration(dataServiceUUID: Constants.serviceUUID,
                                                          dataServiceCharacteristicUUID:  Constants.characteristicUUID,
                                                          localName: localName)
            try peripheral.startWithConfiguration(configuration)
            delegate?.peripheralManagerDidStart(self)
        } catch {
            ULog.error("Failed to start peripheral")
        }
    }
    
    internal func sendData(_ data: Data, onCompletion: @escaping (_ success: Bool) -> ()) {
        if peripheral.connectedRemoteCentrals.count == 0 {
            ULog.verbose("No-one to send to")
            onCompletion(false)
        } else {
            ULog.verbose("Send")
            for peer in peripheral.connectedRemoteCentrals {
                peripheral.sendData(data, toRemotePeer: peer) { (data, peer, error) in
                    if let _ = error {
                        onCompletion(false)
                    } else {
                        onCompletion(true)
                    }
                }
            }
        }
    }
    
    internal func stopPeripheral() {
        ULog.verbose("stopPeripheral")
        do {
            try peripheral.stop()
            delegate?.peripheralManagerDidStop(self)
        } catch {
            ULog.error("Failed to stop peripheral")
        }
    }
}

extension PeripheralManager: BKPeripheralDelegate {
    
    func peripheral(_ peripheral: BKPeripheral, remoteCentralDidConnect remoteCentral: BKRemoteCentral) {
        ULog.verbose("Connected")
        remoteCentral.delegate = self
        delegate?.peripheralManagerDidConnect(self, remote: nil) // TODO
    }
    
    func peripheral(_ peripheral: BKPeripheral, remoteCentralDidDisconnect remoteCentral: BKRemoteCentral) {
        ULog.verbose("Disconnected")
        remoteCentral.delegate = nil
        delegate?.peripheralManagerDidDisconnect(self, remote: nil) // TODO
    }
    
}

extension PeripheralManager: BKRemotePeerDelegate {
    
    func remotePeer(_ remotePeer: BKRemotePeer, didSendArbitraryData data: Data) {
        delegate?.peripheralManagerDidReceiveData(self, data: data)
    }
}

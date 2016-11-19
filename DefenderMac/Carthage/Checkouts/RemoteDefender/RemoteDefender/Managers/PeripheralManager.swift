//
//  PeripheralManager.swift
//  RemoteDefender
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
    var verbose = false

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
        DebugPrint("startPeripheral")
        do {
            let localName = "Defender"
            let configuration = BKPeripheralConfiguration(dataServiceUUID: Constants.serviceUUID,
                                                          dataServiceCharacteristicUUID:  Constants.characteristicUUID,
                                                          localName: localName)
            try peripheral.startWithConfiguration(configuration)
            delegate?.peripheralManagerDidStart(self)
        } catch {
            
        }
    }
    
    internal func sendData(_ data: Data, onCompletion: @escaping (_ success: Bool) -> ()) {
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
    
    internal func stopPeripheral() {
        DebugPrint("stopPeripheral")
        do {
            try peripheral.stop()
            delegate?.peripheralManagerDidStop(self)
        } catch {
            
        }
    }
    
    // MARK: Debug logging
    internal func DebugPrint(_ text: String) {
        if (verbose) {
            print(text)
        }
    }
}

extension PeripheralManager: BKPeripheralDelegate {
    
    func peripheral(_ peripheral: BKPeripheral, remoteCentralDidConnect remoteCentral: BKRemoteCentral) {
        DebugPrint("Connected")
        remoteCentral.delegate = self
        delegate?.peripheralManagerDidConnect(self, remote: nil) // TODO
    }
    
    func peripheral(_ peripheral: BKPeripheral, remoteCentralDidDisconnect remoteCentral: BKRemoteCentral) {
        DebugPrint("Disconnected")
        remoteCentral.delegate = nil
        delegate?.peripheralManagerDidDisconnect(self, remote: nil) // TODO
    }
    
}

extension PeripheralManager: BKRemotePeerDelegate {
    
    func remotePeer(_ remotePeer: BKRemotePeer, didSendArbitraryData data: Data) {
        delegate?.peripheralManagerDidReceiveData(self, data: data)
    }
}

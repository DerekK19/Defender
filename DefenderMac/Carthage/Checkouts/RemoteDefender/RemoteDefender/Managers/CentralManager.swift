//
//  CentralManager.swift
//  RemoteDefender
//
//  Created by Derek Knight on 14/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Foundation
import BluetoothKit

private let singleton = CentralManager(mockMode: false)
private let mockSingleton = CentralManager(mockMode: true)

internal protocol CentralManagerDelegate {
    func centralManagerDidBecomeAvailable(_ manager: CentralManager)
    func centralManagerDidConnect(_ manager: CentralManager, remote: Any?)
    func centralManagerDidReceiveData(_ manager: CentralManager, data: Data)
    func centralManagerDidDisconnect(_ manager: CentralManager, remote: Any?)
    func centralManagerDidBecomeUnavailable(_ manager: CentralManager)
}

internal class CentralManager {
    
    class var realInstance: CentralManager {
        return singleton
    }
    
    class var mockInstance: CentralManager {
        return mockSingleton
    }
    
    var central: BKCentral!
    var delegate: CentralManagerDelegate?
    
    internal init(mockMode: Bool) {
        if mockMode {
            self.central = BKCentral()
            self.central.delegate = self
            self.central.addAvailabilityObserver(self)
        } else {
            self.central = BKCentral()
            self.central.delegate = self
            self.central.addAvailabilityObserver(self)
        }
    }
    
    internal func startCentral() {
        NSLog("startCentral")
        do {
            let configuration = BKConfiguration(dataServiceUUID: Constants.serviceUUID,
                                                dataServiceCharacteristicUUID:  Constants.characteristicUUID)
            try central.startWithConfiguration(configuration)
        } catch {
            
        }
    }
    
    internal func scan() {
        central.scanWithDuration(3, progressHandler: { newDiscoveries in
            NSLog("Discovering")
            // Handle newDiscoveries, [BKDiscovery].
        }, completionHandler: { result, error in
            // Handle error.
            // If no error, handle result, [BKDiscovery].'
            if let error = error {
                NSLog("Scan error: \(error)")
            } else {
                NSLog("Scan -> \(result)")
                if let remotePeripheral = result?.first?.remotePeripheral {
                    NSLog("Connecting: \(remotePeripheral)")
                    self.central.connect(remotePeripheral: remotePeripheral) { remotePeripheral, error in
                        if let error = error {
                            NSLog("Connect error: \(error)")
                        } else {
                            NSLog("Connected -> \(remotePeripheral)")
                            remotePeripheral.delegate = self
                            self.delegate?.centralManagerDidConnect(self, remote: nil) // TODO
                        }
                    }
                }
            }
        })
    }
    
    internal func sendData(_ data: Data, onCompletion: @escaping (_ success: Bool) -> ()) {
        for peer in central.connectedRemotePeripherals {
            central.sendData(data, toRemotePeer: peer) { (data, peer, error) in
                if let _ = error {
                    onCompletion(false)
                } else {
                    onCompletion(true)
                }
            }

        }
    }
    internal func disconnect() {
        for peripheral in central.connectedRemotePeripherals {
            do {
                NSLog("Disconnecting: \(peripheral)")
                try central.disconnectRemotePeripheral(peripheral)
                peripheral.delegate = nil
                NSLog("Disconnected")
            } catch {
                NSLog("Error disconnecting")
            }
        }
    }
    
    internal func stopCentral() {
        NSLog("stopCentral")
        do {
            NSLog("Stopping")
            try central.stop()
            NSLog("Stopped")
        } catch {
            NSLog("Error stopping")
        }
    }
}

extension CentralManager : BKCentralDelegate {
    
    func central(_ central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {
        NSLog("remotePeripheralDidDisconnect \(remotePeripheral)")
        self.delegate?.centralManagerDidDisconnect(self, remote: nil) // TODO
        do {
            NSLog("disconnecting \(remotePeripheral)")
            try central.disconnectRemotePeripheral(remotePeripheral)
            NSLog("disconnected")
        } catch {
            NSLog("error disconnecting")
        }
    }
}

extension CentralManager : BKAvailabilityObserver {
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        NSLog("availabilityDidChange - \(availability)")
        switch availability {
        case .available:
            self.delegate?.centralManagerDidBecomeAvailable(self)
        case .unavailable:
            self.delegate?.centralManagerDidBecomeUnavailable(self)
        }
    }
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
        NSLog("unavailabilityCauseDidChange - \(unavailabilityCause)")
    }
}

extension CentralManager: BKRemotePeerDelegate {
    
    func remotePeer(_ remotePeer: BKRemotePeer, didSendArbitraryData data: Data) {
        delegate?.centralManagerDidReceiveData(self, data: data)
    }
}

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
    var verbose = false
    
    internal init(mockMode: Bool = false) {
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
        DebugPrint("startCentral")
        do {
            let configuration = BKConfiguration(dataServiceUUID: Constants.serviceUUID,
                                                dataServiceCharacteristicUUID:  Constants.characteristicUUID)
            try central.startWithConfiguration(configuration)
        } catch {
            
        }
    }
    
    internal func scan() {
        central.scanWithDuration(3, progressHandler: { newDiscoveries in
            self.DebugPrint("Discovering")
            // Handle newDiscoveries, [BKDiscovery].
        }, completionHandler: { result, error in
            // Handle error.
            // If no error, handle result, [BKDiscovery].'
            if let error = error {
                self.DebugPrint("Scan error: \(error)")
            } else {
                self.DebugPrint("Scan -> \(result)")
                if let remotePeripheral = result?.first?.remotePeripheral {
                    self.DebugPrint("Connecting: \(remotePeripheral)")
                    self.central.connect(remotePeripheral: remotePeripheral) { remotePeripheral, error in
                        if let error = error {
                            self.DebugPrint("Connect error: \(error)")
                        } else {
                            self.DebugPrint("Connected -> \(remotePeripheral)")
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
                DebugPrint("Disconnecting: \(peripheral)")
                try central.disconnectRemotePeripheral(peripheral)
                peripheral.delegate = nil
                DebugPrint("Disconnected")
            } catch {
                DebugPrint("Error disconnecting")
            }
        }
    }
    
    internal func stopCentral() {
        DebugPrint("stopCentral")
        do {
            DebugPrint("Stopping")
            try central.stop()
            DebugPrint("Stopped")
        } catch {
            DebugPrint("Error stopping")
        }
    }
    
    // MARK: Debug logging
    internal func DebugPrint(_ text: String) {
        if (verbose) {
            print(text)
        }
    }
}

extension CentralManager : BKCentralDelegate {
    
    func central(_ central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {
        DebugPrint("remotePeripheralDidDisconnect \(remotePeripheral)")
        self.delegate?.centralManagerDidDisconnect(self, remote: nil) // TODO
        do {
            DebugPrint("disconnecting \(remotePeripheral)")
            try central.disconnectRemotePeripheral(remotePeripheral)
            DebugPrint("disconnected")
        } catch {
            DebugPrint("error disconnecting")
        }
    }
}

extension CentralManager : BKAvailabilityObserver {
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        DebugPrint("availabilityDidChange - \(availability)")
        switch availability {
        case .available:
            self.delegate?.centralManagerDidBecomeAvailable(self)
        case .unavailable:
            self.delegate?.centralManagerDidBecomeUnavailable(self)
        }
    }
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
        DebugPrint("unavailabilityCauseDidChange - \(unavailabilityCause)")
    }
}

extension CentralManager: BKRemotePeerDelegate {
    
    func remotePeer(_ remotePeer: BKRemotePeer, didSendArbitraryData data: Data) {
        delegate?.centralManagerDidReceiveData(self, data: data)
    }
}

//
//  CentralManager.swift
//  Defender Remote
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
        ULog.verbose("startCentral")
        do {
            let configuration = BKConfiguration(dataServiceUUID: Constants.serviceUUID,
                                                dataServiceCharacteristicUUID:  Constants.characteristicUUID)
            try central.startWithConfiguration(configuration)
        } catch {
            
        }
    }
    
    internal func scan() {
        central.scanWithDuration(3, progressHandler: { newDiscoveries in
            ULog.verbose("Discovering")
            // Handle newDiscoveries, [BKDiscovery].
        }, completionHandler: { result, error in
            // Handle error.
            // If no error, handle result, [BKDiscovery].'
            if let error = error {
                ULog.error("Scan error: %@", error.localizedDescription)
            } else {
                ULog.verbose("Scan -> %@", String(describing: result))
                if let remotePeripheral = result?.first?.remotePeripheral {
                    ULog.verbose("Connecting: %@", String(describing: remotePeripheral))
                    self.central.connect(remotePeripheral: remotePeripheral) { remotePeripheral, error in
                        if let error = error {
                            ULog.error("Connect error: %@", error.localizedDescription)
                        } else {
                            ULog.verbose("Connected -> %@", String(describing: remotePeripheral))
                            remotePeripheral.delegate = self
                            self.delegate?.centralManagerDidConnect(self, remote: nil) // TODO
                        }
                    }
                }
            }
        })
    }
    
    internal func sendData(_ data: Data, onCompletion: @escaping (_ success: Bool) -> ()) {
        if central.connectedRemotePeripherals.count == 0 {
            ULog.verbose("No-one to send to")
            onCompletion(false)
        } else {
            ULog.verbose("Send")
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
    }
    internal func disconnect() {
        for peripheral in central.connectedRemotePeripherals {
            do {
                ULog.verbose("Disconnecting: %@", String(describing: peripheral))
                try central.disconnectRemotePeripheral(peripheral)
                peripheral.delegate = nil
                ULog.verbose("Disconnected")
            } catch {
                ULog.error("Error disconnecting")
            }
        }
    }
    
    internal func stopCentral() {
        ULog.verbose("stopCentral")
        do {
            ULog.verbose("Stopping")
            try central.stop()
            ULog.verbose("Stopped")
        } catch {
            ULog.error("Error stopping")
        }
    }
}

extension CentralManager : BKCentralDelegate {
    
    func central(_ central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {
        ULog.verbose("remotePeripheralDidDisconnect %@", String(describing: remotePeripheral))
        self.delegate?.centralManagerDidDisconnect(self, remote: nil) // TODO
        do {
            ULog.verbose("disconnecting %@", String(describing: remotePeripheral))
            try central.disconnectRemotePeripheral(remotePeripheral)
            ULog.verbose("disconnected")
        } catch {
            ULog.error("error disconnecting")
        }
    }
}

extension CentralManager : BKAvailabilityObserver {
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        ULog.verbose("availabilityDidChange - %@", String(describing: availability))
        switch availability {
        case .available:
            self.delegate?.centralManagerDidBecomeAvailable(self)
        case .unavailable:
            self.delegate?.centralManagerDidBecomeUnavailable(self)
        }
    }
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
        ULog.verbose("unavailabilityCauseDidChange - %@", String(describing: unavailabilityCause))
    }
}

extension CentralManager: BKRemotePeerDelegate {
    
    func remotePeer(_ remotePeer: BKRemotePeer, didSendArbitraryData data: Data) {
        delegate?.centralManagerDidReceiveData(self, data: data)
    }
}

//
//  WatchSessionController.swift
//  DefenderApp
//
//  Created by Derek Knight on 19/01/17.
//  Copyright © 2017 Derek Knight. All rights reserved.
//

import Foundation
import WatchConnectivity

protocol WatchSessionControllerDelegate {
    func controller(_ controller: WatchSessionController, currentPreset: UInt8)
}

class WatchSessionController: NSObject {
    
    var session : WCSession?
    var delegate: WatchSessionControllerDelegate?
    
    override init() {
        
        super.init()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session!.delegate = self
            session!.activate()
        } else {
            log("iPhone does not support WCSession")
        }
    }
    
    func sendMessage(_ message: WatchMessage) {
        if WCSession.default.isReachable == true {
            let requestValues = [message.rawValue : ""]
            let session = WCSession.default
            
            session.sendMessage(requestValues,
                                replyHandler: { (replyDic: [String : Any]) -> Void in
                                    self.log(replyDic)
                                    
            }, errorHandler: { (error: Error) -> Void in
                self.log(error.localizedDescription)
            })
        }
        else
        {
            log("WCSession isn't reachable from iPhone to Watch")
        }
    }
    func sendMessage(_ message: WatchMessage, content: Any) {
        if WCSession.default.isReachable == true {
            let requestValues = [message.rawValue : content]
            let session = WCSession.default
            session.sendMessage(requestValues,
                                replyHandler: { (replyDic: [String : Any]) -> Void in
                                    self.log("Acknowleged")
//                                    print("\(replyDic)")
            }, errorHandler: { (error: Error) -> Void in
                self.log(error.localizedDescription)
            })
        }
        else
        {
            log("WCSession isn't reachable from iPhone to Watch")
        }
    }
    
    fileprivate func log(_ message: Any) {
        ULog.verbose("%@", String(describing: message))
    }
}

extension WatchSessionController : WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated:
            log("Watch session activated")
            sendMessage(.hello)
        case .inactive:
            log("Watch session inactive")
        case .notActivated:
            log("Watch session not activated")
        default:
            log("Watch session \(activationState)")
        }
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        log("Watch session deactivated")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        log("Watch session inactivate")
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        log("Watch state changed: \(session.activationState)")
    }
    func sessionReachabilityDidChange(_ session: WCSession) {
        log("Watch reachability changed: \(session.isReachable)")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        var diagMessage = "iPhone did receive message"
        for (key, value) in message {
            diagMessage.append("\n \(key) - \(value)")
        }
        log(diagMessage)
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        var diagMessage = "iPhone did receive message (reply)"
        for (key, value) in message {
            diagMessage.append("\n \(key) - \(value)")
        }
        log(diagMessage)
        for (key, value) in message {
            switch WatchMessage(rawValue: key.uppercased()) ?? .unknown {
            case .preset:
                if let value = value as? UInt8 {
                    delegate?.controller(self, currentPreset: value)
                }
            default:
                continue
            }
        }
        replyHandler(["Ack" : "Ack"])
    }
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        log("iPhone did receive data")
    }
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        log("iPhone did receive data (reply)")
        replyHandler(Data())
    }
}

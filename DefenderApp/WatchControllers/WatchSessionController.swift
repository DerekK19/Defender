//
//  WatchSessionController.swift
//  DefenderApp
//
//  Created by Derek Knight on 19/01/17.
//  Copyright © 2017 Derek Knight. All rights reserved.
//

import Foundation
import Flogger
import WatchConnectivity

class WatchSessionController: NSObject {
    
    var session : WCSession?
    
    override init() {
        
        super.init()
        
        if WCSession.isSupported() {
            session = WCSession.default()
            session!.delegate = self
            session!.activate()
        } else {
            Flogger.log.warning("iPhone does not support WCSession")
        }
    }
    
    func sendMessage(_ message: String) {
        if WCSession.default().isReachable == true {
            let requestValues = ["Message" : message]
            let session = WCSession.default()
            
            session.sendMessage(requestValues,
                                replyHandler: { (replyDic: [String : Any]) -> Void in
                                    Flogger.log.verbose(replyDic)
                                    
            }, errorHandler: { (error: Error) -> Void in
                Flogger.log.verbose(error.localizedDescription)
            })
        }
        else
        {
            Flogger.log.verbose("WCSession isn't reachable from iPhone to Watch")
        }
    }
    func sendMessage(_ message: String, content: Any) {
        if WCSession.default().isReachable == true {
            let requestValues = [message : content]
            let session = WCSession.default()
            session.sendMessage(requestValues,
                                replyHandler: { (replyDic: [String : Any]) -> Void in
                                    Flogger.log.verbose("Acknowleged")
//                                    print("\(replyDic)")
            }, errorHandler: { (error: Error) -> Void in
                Flogger.log.verbose(error.localizedDescription)
            })
        }
        else
        {
            Flogger.log.verbose("WCSession isn't reachable from iPhone to Watch")
        }
    }
}

extension WatchSessionController : WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated:
            Flogger.log.verbose("Watch session activated")
            sendMessage("Hello world")
        case .inactive:
            Flogger.log.verbose("Watch session inactive")
        case .notActivated:
            Flogger.log.verbose("Watch session not activated")
        }
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        Flogger.log.verbose("Watch session deactivated")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        Flogger.log.verbose("Watch session inactivate")
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        Flogger.log.verbose("Watch state changed")
    }
    func sessionReachabilityDidChange(_ session: WCSession) {
        Flogger.log.verbose("Watch reachability changed")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        var diagMessage = "iPhone did receive message"
        for (key, value) in message {
            diagMessage.append("\n \(key) - \(value)")
        }
        Flogger.log.verbose(diagMessage)
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        var diagMessage = "iPhone did receive message (reply)"
        for (key, value) in message {
            diagMessage.append("\n \(key) - \(value)")
        }
        Flogger.log.verbose(diagMessage)
        replyHandler(["Ack" : "Ack"])
    }
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        Flogger.log.verbose("iPhone did receive data")
    }
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        Flogger.log.verbose("iPhone did receive data (reply)")
        replyHandler(Data())
    }
}

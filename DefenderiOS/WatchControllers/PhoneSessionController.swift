//
//  PhoneSessionController
//  DefenderApp
//
//  Created by Derek Knight on 19/01/17.
//  Copyright © 2017 Derek Knight. All rights reserved.
//

import Foundation
import WatchConnectivity

protocol PhoneSessionControllerDelegate {
    func controllerDidConnect(_ controller: PhoneSessionController)
    func controllerDidDisconnect(_ controller: PhoneSessionController)
    func controller(_ controller: PhoneSessionController, currentAmplifier: String)
    func controller(_ controller: PhoneSessionController, presets: [String])
    func controller(_ controller: PhoneSessionController, currentPreset: String)
}

class PhoneSessionController : NSObject {
    
    var session : WCSession?
    var delegate: PhoneSessionControllerDelegate?
    
    override init() {
        
        super.init()
        
        if WCSession.isSupported() {
            session = WCSession.default()
            session!.delegate = self
            session!.activate()
        } else {
            log("Watch does not support WCSession")
        }
    }
    
    fileprivate func sendMessage(_ message: WatchMessage) {
        if WCSession.default().isReachable == true {
            let requestValues = [message.rawValue : message]
            let session = WCSession.default()
            
            session.sendMessage(requestValues,
                                replyHandler: { (replyDic: [String : Any]) -> Void in
                                    self.log("\(replyDic)")
                                    
            }, errorHandler: { (error: Error) -> Void in
                NSLog(error.localizedDescription)
            })
        }
        else
        {
            log("WCSession isn't reachable from Watch to iPhone")
        }
    }
    func sendMessage(_ message: WatchMessage, content: Any) {
        if WCSession.default().isReachable == true {
            let requestValues = [message.rawValue : content]
            let session = WCSession.default()
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
    
    fileprivate func log(_ message: String) {
        NSLog(message)
        let requestValues = [WatchMessage.log.rawValue : message]
        let session = WCSession.default()
        
        session.sendMessage(requestValues,
                            replyHandler: { (replyDic: [String : Any]) -> Void in
        }, errorHandler: nil)
    }
}

extension PhoneSessionController : WCSessionDelegate {
    
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated:
            log("iPhone session activated")
        case .inactive:
            log("iPhone session inactive")
        case .notActivated:
            log("iPhone session not activated")
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        log("iPhone reachability changed")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        var diagMessage = "Watch did receive message"
        for (key, value) in message {
            diagMessage.append("\n \(key) - \(value)")
        }
        log(diagMessage)
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        var diagMessage = "Watch did receive message (reply)"
        for (key, value) in message {
            diagMessage.append("\n \(key) - \(value)")
        }
        log(diagMessage)
        for (key, value) in message {
            switch WatchMessage(rawValue: key.uppercased()) ?? .unknown {
            case .connect:
                delegate?.controllerDidConnect(self)
            case .disconnect:
                delegate?.controllerDidDisconnect(self)
            case .amplifier:
                if let value = value as? String {
                    delegate?.controller(self, currentAmplifier: value)
                }
            case .presets:
                if let value = value as? [String] {
                    delegate?.controller(self, presets: value)
                }
            case .preset:
                if let value = value as? String {
                    delegate?.controller(self, currentPreset: value)
                }
            default:
                continue
            }
        }
        replyHandler(["Ack" : "Ack"])
    }
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        log("Watch did receive data")
    }
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        log("Watch did receive data")
        replyHandler(Data())
    }
    
}

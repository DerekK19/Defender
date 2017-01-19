//
//  PhoneCommunicationController.swift
//  DefenderApp
//
//  Created by Derek Knight on 19/01/17.
//  Copyright © 2017 Derek Knight. All rights reserved.
//

import Foundation
import WatchConnectivity

class PhoneCommunicationController : NSObject {
    
    var session : WCSession?
    
    override init() {
        
        super.init()
        
        if WCSession.isSupported() {
            session = WCSession.default()
            session!.delegate = self
            session!.activate()
        } else {
            print("Watch does not support WCSession")
        }
    }
    
    fileprivate func sendMessage(_ message: String) {
        if WCSession.default().isReachable == true {
            let requestValues = ["Message" : message]
            let session = WCSession.default()
            
            session.sendMessage(requestValues,
                                replyHandler: { (replyDic: [String : Any]) -> Void in
                                    NSLog("\(replyDic)")
                                    
            }, errorHandler: { (error: Error) -> Void in
                NSLog(error.localizedDescription)
            })
        }
        else
        {
            print("WCSession isn't reachable from Watch to iPhone")
        }
    }
}

extension PhoneCommunicationController : WCSessionDelegate {
    
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated:
            NSLog("iPhone session activated")
        case .inactive:
            NSLog("iPhone session inactive")
        case .notActivated:
            NSLog("iPhone session not activated")
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        NSLog("iPhone reachability changed")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        NSLog("Watch did receive message (reply)")
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        NSLog("Watch did receive message (reply)")
        replyHandler(["Ack" : "Ack"])
    }
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        NSLog("Watch did receive data")
    }
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        NSLog("Watch did receive data")
        replyHandler(Data())
    }
    
}

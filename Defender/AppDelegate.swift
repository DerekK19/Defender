//
//  AppDelegate.swift
//  Defender
//
//  Created by Derek Knight on 30/07/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa
import Mustang

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        Mustang().detectAmplifiers(
            didConnect: { (amplifier) in
                NSLog("Connected")
            }, didDisconnect: { (amplifier) in
                NSLog("Disconnected")
            }
        )
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}


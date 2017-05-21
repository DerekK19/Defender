//
//  AppDelegate.swift
//  Defender
//
//  Created by Derek Knight on 30/07/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa
import Flogger

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var remoteManager = RemoteManager()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
#if DEBUG
        Flogger.setup()
#endif
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        remoteManager.stop()
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}


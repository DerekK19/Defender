//
//  AppViewControl.swift
//  Defender
//
//  Created by Derek Knight on 20/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class AppViewControl: NSView {
    
    var backgroundColour = NSColor.white
    
    override func draw(_ dirtyRect: NSRect) {
        if !isHidden {
            let context = NSGraphicsContext.current()
            context?.saveGraphicsState()
            context?.patternPhase = NSMakePoint(0, frame.size.height)
            backgroundColour.set()
            NSRectFill(self.bounds)
            context?.restoreGraphicsState()
        }
    }
}

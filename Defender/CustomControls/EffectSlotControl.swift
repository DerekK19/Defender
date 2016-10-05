//
//  EffectSlotControl.swift
//  Defender
//
//  Created by Derek Knight on 5/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class EffectSlotControl: NSView {
    
    var backgroundColour: NSColor = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0) {
        didSet {
            setNeedsDisplay(self.bounds)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        lockFocus()
        let colour = backgroundColour
        colour.setFill()
        let rect = NSBezierPath(roundedRect: dirtyRect, xRadius: 4, yRadius: 4)
        rect.fill()
        unlockFocus()
    }
}

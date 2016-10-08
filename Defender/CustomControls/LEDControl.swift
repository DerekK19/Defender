//
//  LEDControl.swift
//  Defender
//
//  Created by Derek Knight on 8/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class LEDControl: NSView {
    
    var backgroundColour: NSColor = NSColor.red {
        didSet {
            setNeedsDisplay(self.bounds)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if !isHidden {
            lockFocus()
            let colour = backgroundColour
            colour.setFill()
            let rect = NSBezierPath(roundedRect: dirtyRect, xRadius: bounds.width / 2, yRadius: bounds.height / 2)
            rect.fill()
            unlockFocus()
        }
    }
}

//
//  PedalPadControl.swift
//  Defender
//
//  Created by Derek Knight on 5/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class PedalPadControl: NSView {
    
    var backgroundColour: NSColor = NSColor.black {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if !isHidden {
            lockFocus()
            let colour = backgroundColour
            colour.setFill()
            let rect = NSBezierPath(roundedRect: dirtyRect, xRadius: 4, yRadius: 4)
            rect.fill()
            unlockFocus()
        }
    }
}

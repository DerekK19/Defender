//
//  WebSlotControl.swift
//  Defender
//
//  Created by Derek Knight on 7/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class WebSlotControl: NSView {
    
    var backgroundColour: NSColor = NSColor.slotBackground {
        didSet {
            setNeedsDisplay(self.bounds)
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

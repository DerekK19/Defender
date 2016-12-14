//
//  CabinetSlotControl.swift
//  Defender
//
//  Created by Derek Knight on 14/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class CabinetSlotControl: NSView {
    
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

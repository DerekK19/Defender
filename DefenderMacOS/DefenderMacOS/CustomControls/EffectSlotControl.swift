//
//  EffectSlotControl.swift
//  Defender
//
//  Created by Derek Knight on 5/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class EffectSlotControl: NSView {
    
    var backgroundColour: NSColor = NSColor.slotBackground {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if !isHidden {
            let colour = backgroundColour
            colour.setFill()
            let rect = NSBezierPath(roundedRect: dirtyRect, xRadius: 4, yRadius: 4)
            rect.fill()
        }
    }
}

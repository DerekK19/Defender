//
//  EffectControl.swift
//  Defender
//
//  Created by Derek Knight on 4/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class EffectControl: NSView {
    
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
            NSRectFill(dirtyRect)
            unlockFocus()
        }
    }
}

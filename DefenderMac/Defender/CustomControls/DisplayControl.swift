//
//  DisplayControl.swift
//  Defender
//
//  Created by Derek Knight on 8/08/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class DisplayControl: NSView {

    var backgroundColour: NSColor = NSColor.LCDLightBlue {
        didSet {
            setNeedsDisplay(self.bounds)
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

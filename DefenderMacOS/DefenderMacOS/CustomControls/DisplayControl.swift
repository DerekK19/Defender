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
            setNeedsDisplay(bounds)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if !isHidden {
            let colour = backgroundColour
            colour.setFill()
            dirtyRect.fill()
        }
    }
}

//
//  ShadeControl.swift
//  Defender
//
//  Created by Derek Knight on 19/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class ShadeControl: NSView {
    
    var backgroundColour: NSColor = NSColor.shadeClosed {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    
    var isOpen: Bool = false {
        didSet {
            backgroundColour = isOpen ? NSColor.shadeOpen : NSColor.shadeClosed
            isHidden = isOpen
            setNeedsDisplay(bounds)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if !isHidden {
            lockFocus()
            let colour = backgroundColour
            colour.setFill()
            dirtyRect.fill()
            unlockFocus()
        }
    }
}

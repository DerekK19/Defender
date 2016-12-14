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
            setNeedsDisplay(self.bounds)
        }
    }
    
    var isOpen: Bool = false {
        didSet {
            backgroundColour = isOpen ? NSColor.shadeOpen : NSColor.shadeClosed
            self.isHidden = isOpen
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

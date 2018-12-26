//
//  ShadeControl.swift
//  Defender
//
//  Created by Derek Knight on 19/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class ShadeControl: NSView {
    
    private var pBackgroundColour: NSColor = NSColor.shadeClosed
    
    var backgroundColour: NSColor = NSColor.shadeClosed {
        didSet {
            pBackgroundColour = backgroundColour
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
            let colour = pBackgroundColour
            colour.setFill()
            dirtyRect.fill()

        }
    }
}

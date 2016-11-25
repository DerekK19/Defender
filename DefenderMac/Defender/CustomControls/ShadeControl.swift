//
//  ShadeControl.swift
//  Defender
//
//  Created by Derek Knight on 19/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class ShadeControl: NSView {
    
    var backgroundColour: NSColor = NSColor(red: 0.66, green: 0.66, blue: 0.66, alpha: 0.6) {
        didSet {
            setNeedsDisplay(self.bounds)
        }
    }
    
    var isOpen: Bool = false {
        didSet {
            backgroundColour = NSColor(red: 0.66, green: 0.66, blue: 0.66, alpha: isOpen ? 0.0 : 0.6)
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

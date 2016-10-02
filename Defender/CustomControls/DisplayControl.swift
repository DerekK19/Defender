//
//  DisplayControl.swift
//  Defender
//
//  Created by Derek Knight on 8/08/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class DisplayControl: NSView {

    var backgroundColour: NSColor = NSColor(red: 0.62, green: 0.78, blue: 0.88, alpha: 1.0) {
        didSet {
            setNeedsDisplay(self.bounds)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        lockFocus()
        let colour = backgroundColour
        colour.setFill()
        NSRectFill(dirtyRect)
        unlockFocus()
    }
}

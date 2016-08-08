//
//  DisplayControl.swift
//  Defender
//
//  Created by Derek Knight on 8/08/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class DisplayControl: NSView {

    var backgroundColour: NSColor = NSColor(colorLiteralRed: 0.62, green: 0.78, blue: 0.88, alpha: 1.0)
    
    override func drawRect(dirtyRect: NSRect) {
        lockFocus()
        let colour = backgroundColour
        colour.setFill()
        NSRectFill(dirtyRect)
        unlockFocus()
    }
}

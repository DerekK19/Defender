//
//  PedalBodyControl.swift
//  Defender
//
//  Created by Derek Knight on 4/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class PedalBodyControl: NSView {
    
    var backgroundColour: NSColor = NSColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0) {
        didSet {
            setNeedsDisplay(self.bounds)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        let colour = backgroundColour
        let insetRect = NSRect(x: dirtyRect.origin.x+3, y: dirtyRect.origin.y, width: dirtyRect.width-6, height: dirtyRect.height-3)
        let rect = NSBezierPath(roundedRect: dirtyRect, xRadius: 4, yRadius: 4) // Round corner path for full rectangle
        let rect2 = NSBezierPath(roundedRect: insetRect, xRadius: 4, yRadius: 4) // Round corner path for inset rectangle

        lockFocus()

        // Set the fill colour
        colour.setFill()

        // Draw the full rectangle with rounded corners
        rect.fill()

        // Set up a drop shadow (light appears to come from above and to the bottom)
        let dropShadow = NSShadow()
        dropShadow.shadowColor = NSColor.black
        dropShadow.shadowBlurRadius = 10
        dropShadow.shadowOffset = NSSize(width: 0, height: -3)
        
        // save graphics state
        NSGraphicsContext.saveGraphicsState()
        dropShadow.set()
        
        // Draw the inset rectangle, which will apply the drop shadow
        rect2.fill()
        
        // restore state
        NSGraphicsContext.restoreGraphicsState()

        unlockFocus()
    }
}

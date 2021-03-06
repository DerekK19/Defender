//
//  PedalBodyControl.swift
//  Defender
//
//  Created by Derek Knight on 4/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class PedalBodyControl: NSView {
    
    private var pBackgroundColour: NSColor = NSColor.black
    
    var backgroundColour: NSColor = NSColor.black {
        didSet {
            pBackgroundColour = backgroundColour
            setNeedsDisplay(bounds)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        if !isHidden {

            let colour = pBackgroundColour
            let insetRect = NSRect(x: dirtyRect.origin.x+3, y: dirtyRect.origin.y, width: dirtyRect.width-6, height: dirtyRect.height-3)
            let rect = NSBezierPath(roundedRect: dirtyRect, xRadius: 4, yRadius: 4) // Round corner path for full rectangle
            let rect2 = NSBezierPath(roundedRect: insetRect, xRadius: 4, yRadius: 4) // Round corner path for inset rectangle
            
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
        }
    }
}

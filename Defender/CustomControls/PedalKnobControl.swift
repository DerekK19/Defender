//
//  PedalKnobControl.swift
//  Defender
//
//  Created by Derek Knight on 8/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class PedalKnobControl: NSView {
    
    var backgroundColour: NSColor = NSColor.black {
        didSet {
            setNeedsDisplay(self.bounds)
        }
    }
    var foregroundColour: NSColor = NSColor.white
    
    var minValue: Float = 0.1
    var maxValue: Float = 0.9
    
    fileprivate var _floatValue: Float = 0.0
    var floatValue: Float = 0.0 {
        didSet {
            _floatValue = floatValue
            setNeedsDisplay(self.bounds)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if !isHidden {
            lockFocus()
            if let knobImage = NSImage(named: "pedal-knob") {
                let fraction = (self._floatValue - self.minValue) / (self.maxValue - self.minValue)
                let angle = -CGFloat(fraction * 360.0)
                let rotatedKnob = self.imageRotatedByDegrees(knobImage, degrees: angle)
                let copyRect = NSMakeRect((rotatedKnob.size.width-dirtyRect.size.width)/2.0, (rotatedKnob.size.height-dirtyRect.size.height)/2.0, dirtyRect.width, dirtyRect.height)
                rotatedKnob.draw(in: dirtyRect, from: copyRect, operation: .sourceOver, fraction: 1.0)
            }
            unlockFocus()
        }
    }

    // MARK: Private methods
    fileprivate func imageRotatedByDegrees(_ image: NSImage, degrees: CGFloat) -> NSImage {
        var imageBounds = NSRect(origin: NSZeroPoint, size: self.bounds.size)
        
        let boundsPath = NSBezierPath(rect: imageBounds)
        var transform = AffineTransform.identity
        transform.rotate(byDegrees: degrees)
        boundsPath.transform(using: transform)
        let rotatedBounds = NSRect(origin: NSZeroPoint, size: boundsPath.bounds.size)
        let rotatedImage = NSImage(size: rotatedBounds.size)
        
        // Centre the image within the rotated bounds
        imageBounds.origin.x = NSMidX(rotatedBounds) - (NSWidth (imageBounds) / 2)
        imageBounds.origin.y = NSMidY(rotatedBounds) - (NSHeight (imageBounds) / 2)
        
        // Set up the rotation transform
        transform = AffineTransform.identity
        transform.translate(x: (NSWidth(rotatedBounds) / 2), y: (NSHeight(rotatedBounds) / 2))
        transform.rotate(byDegrees: degrees)
        transform.translate(x: -(NSWidth(rotatedBounds) / 2), y: -(NSHeight(rotatedBounds) / 2))
        
        // draw the original image, rotated, into the new image
        rotatedImage.lockFocus()
        (transform as NSAffineTransform).concat()
        image.draw(in: imageBounds, from:NSZeroRect, operation: NSCompositingOperation.copy, fraction:1.0)
        rotatedImage.unlockFocus()
        
        return rotatedImage
    }
    
}

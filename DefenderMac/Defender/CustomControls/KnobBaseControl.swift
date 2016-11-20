//
//  KnobBaseControl.swift
//  Defender
//
//  Created by Derek Knight on 14/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class KnobBaseControl: NSView {
    
    var pixelsPerTick: Float = 10.0
    
    // The knob has a range from minValue to maxValue
    var minValue: Float = 0.0
    var maxValue: Float = 10.0

    // These are represented as degrees limits
    var minStop: Float = 0.0
    var maxStop: Float = 10.0
    
    var startMouse: NSPoint?
    var startValue: Float = 1.0
    var direction: Float = 1.0
    
    internal var _floatValue: Float = 1.0
    var floatValue: Float = 1.0 {
        didSet {
            _floatValue = floatValue
            setNeedsDisplay(self.bounds)
        }
    }
    
    var backgroundColour: NSColor = NSColor.black {
        didSet {
            setNeedsDisplay(self.bounds)
        }
    }
    var foregroundColour: NSColor = NSColor.white
    
    internal func configure(minValue: Float, maxValue: Float, minStop: Float, maxStop: Float, pixelsPerTick: Float) {
        self.pixelsPerTick = pixelsPerTick
        self.minValue = minValue
        self.maxValue = maxValue
        self.minStop = minStop
        self.maxStop = maxStop
    }

    // Event handling
    override var acceptsFirstResponder: Bool {
        return true
    }

    override func mouseDown(with theEvent: NSEvent) {
        startMouse = theEvent.locationInWindow
        if let startMouse = startMouse {
            startValue = _floatValue
            let viewMouse = self.convert(startMouse, from: nil)
            let midX = self.frame.width / 2.0
            direction = viewMouse.x < midX ? 1.0 : -1.0
        }
    }
    
    override func mouseDragged(with theEvent: NSEvent) {
        let nowMouse = theEvent.locationInWindow
        if let startMouse = startMouse {
            _floatValue = yDelta(startPosition: startMouse, endPosition: nowMouse)
            setNeedsDisplay(self.bounds)
        }
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        let nowMouse = theEvent.locationInWindow
        if let startMouse = startMouse {
            floatValue = yDelta(startPosition: startMouse, endPosition: nowMouse)
        }
        startMouse = nil
    }

    internal func yDelta(startPosition: NSPoint, endPosition: NSPoint) -> Float {
        let yChange = Float(endPosition.y - startPosition.y) * direction
        return min(max(startValue + (yChange / pixelsPerTick), minValue), maxValue)
    }
    
    internal func degreesFromFloatValue(_ floatValue: Float) -> CGFloat {
        let fraction = (floatValue - self.minStop) / (self.maxStop - self.minStop)
        let angle = -CGFloat(fraction * 360.0)
//        NSLog("Float \(floatValue) -> Degrees \(angle)")
        return angle
    }
    internal func radiansFromFloatValue(_ floatValue: Float) -> CGFloat {
        let fraction = self.minValue + (floatValue * (self.maxValue - self.minValue))
        let angle =  -(CGFloat(fraction * Float(M_PI) * 2.0) + CGFloat(M_PI / 2.0))
//        NSLog("Float \(floatValue) -> Radians \(angle)")
        return angle
    }
    
    internal func imageRotatedByDegrees(_ image: NSImage, degrees: CGFloat) -> NSImage {
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

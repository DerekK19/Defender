//
//  KnobControl.swift
//  Defender
//
//  Created by Derek Knight on 7/08/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

protocol KnobDelegate {
    func valueDidChangeForKnob(sender: KnobControl, value: Float)
}

class KnobControl: NSView {

    let pixelsPerTick: Float = 15.0
    
    var minValue: Float = 1.0
    var maxValue: Float = 11.6

    var minStop: Float = 1.0
    var maxStop: Float = 10.0
    
    var startMouse: NSPoint!
    var startValue: Float = 1.0
    
    var delegate: KnobDelegate?
    
    private var _floatValue: Float = 1.0
    var floatValue: Float = 1.0 {
        didSet {
            _floatValue = floatValue
            setNeedsDisplayInRect(self.bounds)
        }
    }
    
    // Event handling
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func mouseDown(theEvent: NSEvent) {
        startMouse = theEvent.locationInWindow
        startValue = _floatValue
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        let yChange = Float(theEvent.locationInWindow.y - startMouse.y)
        _floatValue = min(max(startValue + (yChange / pixelsPerTick), minStop), maxStop)
        setNeedsDisplayInRect(self.bounds)
    }
    
    override func mouseUp(theEvent: NSEvent) {
        let yChange = Float(theEvent.locationInWindow.y - startMouse.y)
        floatValue = min(max(startValue + (yChange / pixelsPerTick), minStop), maxStop)
        delegate?.valueDidChangeForKnob(self, value: floatValue)
    }
    
    // MARK: Draw function
    override func drawRect(dirtyRect: NSRect) {
        if let knobImage = NSImage(named: "knob") {
            let fraction = (self._floatValue - self.minValue) / (self.maxValue - self.minValue)
            let angle = -CGFloat(fraction * 360.0)
            let rotatedKnob = self.imageRotatedByDegrees(knobImage, degrees: angle)
            let copyRect = NSMakeRect((rotatedKnob.size.width-dirtyRect.size.width)/2.0, (rotatedKnob.size.height-dirtyRect.size.height)/2.0, dirtyRect.width, dirtyRect.height)
            rotatedKnob.drawInRect(dirtyRect, fromRect: copyRect, operation: .CompositeSourceOver, fraction: 1.0)
        }
    }
    
    // MARK: Private methods
    private func imageRotatedByDegrees(image: NSImage, degrees: CGFloat) -> NSImage {
        var imageBounds = NSRect(origin: NSZeroPoint, size: self.bounds.size)
        
        let boundsPath = NSBezierPath(rect: imageBounds)
        var transform = NSAffineTransform()
        transform.rotateByDegrees(degrees)
        boundsPath.transformUsingAffineTransform(transform)
        let rotatedBounds = NSRect(origin: NSZeroPoint, size: boundsPath.bounds.size)
        let rotatedImage = NSImage(size: rotatedBounds.size)
        
        // Centre the image within the rotated bounds
        imageBounds.origin.x = NSMidX(rotatedBounds) - (NSWidth (imageBounds) / 2)
        imageBounds.origin.y = NSMidY(rotatedBounds) - (NSHeight (imageBounds) / 2)
        
        // Set up the rotation transform
        transform = NSAffineTransform()
        transform.translateXBy((NSWidth(rotatedBounds) / 2), yBy: (NSHeight(rotatedBounds) / 2))
        transform.rotateByDegrees(degrees)
        transform.translateXBy(-(NSWidth(rotatedBounds) / 2), yBy: -(NSHeight(rotatedBounds) / 2))
        
        // draw the original image, rotated, into the new image
        rotatedImage.lockFocus()
        transform.concat()
        image.drawInRect(imageBounds, fromRect:NSZeroRect, operation: NSCompositingOperation.CompositeCopy, fraction:1.0)
        rotatedImage.unlockFocus()
        
        return rotatedImage
    }
    
}
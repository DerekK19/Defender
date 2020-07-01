//
//  WheelControl.swift
//  Defender
//
//  Created by Derek Knight on 9/08/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

protocol WheelDelegate {
    func valueIsChangingForWheel(_ sender: WheelControl, value: Int)
    func valueDidChangeForWheel(_ sender: WheelControl, value: Int)
}

class WheelControl: NSView {

    let pixelsPerTick: Float = 4.0
    
    var minValue: Float = 1.0
    var maxValue: Float = 100.0
    
    var startMouse: NSPoint!
    var startValue: Float = 1.0
    var direction: Float = 1.0
    
    var delegate: WheelDelegate?
    
    fileprivate var _floatValue: Float = 1.0
    var floatValue: Float = 1.0 {
        didSet {
            _floatValue = floatValue
            setNeedsDisplay(bounds)
        }
    }
    var intValue: Int = 0
    
    fileprivate var enabled: Bool = true

    var powerState: PowerState = .off {
        didSet {
            
        }
    }

    // Event handling
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        if !enabled { return }
        startMouse = theEvent.locationInWindow
        startValue = _floatValue
        let midX = (self.frame.origin.x + (self.frame.width / 2.0))
        direction = startMouse.x < midX ? 1.0 : -1.0
    }
    
    override func mouseDragged(with theEvent: NSEvent) {
        if !enabled { return }
        let yChange = Float(theEvent.locationInWindow.y - startMouse.y) * direction
        _floatValue = startValue + (yChange / pixelsPerTick)
        var _intValue = Int(_floatValue) % 100
        if _intValue < 0 { _intValue = 100 + _intValue }
        delegate?.valueIsChangingForWheel(self, value: _intValue)
        setNeedsDisplay(bounds)
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        if !enabled { return }
        let yChange = Float(theEvent.locationInWindow.y - startMouse.y) * direction
        floatValue = startValue + (yChange / pixelsPerTick)
        intValue = Int(floatValue) % 100
        if intValue < 0 { intValue = 100 + intValue }
        delegate?.valueDidChangeForWheel(self, value: intValue)
    }
    
    func setIntValueTo(_ intValue: Int) {
        if !enabled { return }
        if intValue == self.intValue { return }
        self.intValue = intValue
        self.intValue = self.intValue % 100
        if self.intValue < 0 { self.intValue = 100 + self.intValue }
        self.floatValue = Float(self.intValue)
    }
    
    func wheelRotate(by delta: Int) {
        setIntValueTo(self.intValue + delta)
        delegate?.valueDidChangeForWheel(self, value: self.intValue)
    }

    // MARK: Draw function
    override func draw(_ dirtyRect: NSRect) {
        if !isHidden {
            if let knobImage = NSImage(named: "wheel") {
                let fraction = (self._floatValue - self.minValue) / (self.maxValue - self.minValue)
                let angle = -CGFloat(fraction * 360.0)
                let rotatedKnob = self.imageRotatedByDegrees(knobImage, degrees: angle)
                let copyRect = NSMakeRect((rotatedKnob.size.width-dirtyRect.size.width)/2.0, (rotatedKnob.size.height-dirtyRect.size.height)/2.0, dirtyRect.width, dirtyRect.height)
                rotatedKnob.draw(in: dirtyRect, from: copyRect, operation: .sourceOver, fraction: 1.0)
            }
        }
    }
    
    // MARK: Private methods
    fileprivate func imageRotatedByDegrees(_ image: NSImage, degrees: CGFloat) -> NSImage {
        var imageBounds = NSRect(origin: NSZeroPoint, size: bounds.size)
        
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

//
//  KnobBaseControl.swift
//  DefenderApp
//
//  Created by Derek Knight on 29/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit

class KnobBaseControl: UIView {
    
    var pixelsPerTick: Float = 10.0
    
    // The knob has a range from minValue to maxValue
    var minValue: Float = 0.0
    var maxValue: Float = 10.0
    
    // These are represented as degrees limits
    var minStop: Float = 0.0
    var maxStop: Float = 10.0
    
    var startMouse: CGPoint?
    var startValue: Float = 1.0
    var direction: Float = 1.0
    
    internal var _floatValue: Float = 1.0
    var floatValue: Float = 1.0 {
        didSet {
            _floatValue = floatValue
            setNeedsDisplay(self.bounds)
        }
    }
    
    var backgroundColour: UIColor = UIColor.black {
        didSet {
            setNeedsDisplay(self.bounds)
        }
    }
    var foregroundColour: UIColor = UIColor.white
    
    internal func configure(minValue: Float, maxValue: Float, minStop: Float, maxStop: Float, pixelsPerTick: Float) {
        self.pixelsPerTick = pixelsPerTick
        self.minValue = minValue
        self.maxValue = maxValue
        self.minStop = minStop
        self.maxStop = maxStop
    }
    
    /*
 
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
    
    */
    
    internal func yDelta(startPosition: CGPoint, endPosition: CGPoint) -> Float {
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
    
    internal func imageRotatedByDegrees(_ image: UIImage, degrees: CGFloat) -> UIImage {
        /*
        var imageBounds = CGRect(origin: CGPoint.zero, size: self.bounds.size)
        
        let boundsPath = UIBezierPath(rect: imageBounds)
        var transform = AffineTransform.identity
        transform.rotate(byDegrees: degrees)
        boundsPath.transform(using: transform)
        let rotatedBounds = CGRect(origin: CGPoint.zero, size: boundsPath.bounds.size)
        let rotatedImage = UIImage(size: rotatedBounds.size)
        
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
        */
        return image
    }

}

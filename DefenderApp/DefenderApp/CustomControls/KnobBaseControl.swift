//
//  KnobBaseControl.swift
//  DefenderApp
//
//  Created by Derek Knight on 29/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit
import Flogger

class KnobBaseControl: UIView {
    
    var pixelsPerTick: Float = 10.0
    
    // The knob has a range from minValue to maxValue
    var minValue: Float = 0.0
    var maxValue: Float = 10.0
    
    // These are represented as degrees limits
    var minStop: Float = 0.0
    var maxStop: Float = 10.0
    
    var startAt: CGPoint?
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
    
    // Event handling
    func startedPan(at: CGPoint) {
        startAt = at
        startValue = _floatValue
        let midX = self.frame.width / 2.0
        direction = at.x < midX ? -1.0 : 1.0

    }
    
    func panning(at: CGPoint) {
        if let startAt = startAt {
            _floatValue = yDelta(startPosition: startAt, endPosition: at)
            setNeedsDisplay(self.bounds)
        }
    }
    
    func endedPan(at: CGPoint) {
        if let startAt = startAt {
            floatValue = yDelta(startPosition: startAt, endPosition: at)
        }
        startAt = nil

    }
    
    internal func yDelta(startPosition: CGPoint, endPosition: CGPoint) -> Float {
        let yChange = Float(endPosition.y - startPosition.y) * direction
        return min(max(startValue + (yChange / pixelsPerTick), minValue), maxValue)
    }
    
    internal func degreesFromFloatValue(_ floatValue: Float) -> CGFloat {
        let fraction = (floatValue - self.minStop) / (self.maxStop - self.minStop)
        let angle = -CGFloat(fraction * 360.0)
        return angle
    }
    internal func radiansFromFloatValue(_ floatValue: Float) -> CGFloat {
        let fraction = self.minValue + (floatValue * (self.maxValue - self.minValue))
        let angle =  -(CGFloat(fraction * Float(M_PI) * 2.0) + CGFloat(M_PI / 2.0))
        return angle
    }
    
    internal func imageRotatedByDegrees(_ image: UIImage, degrees: CGFloat) -> UIImage {
        let radians = -degrees * CGFloat(M_PI / 180)
        //Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: radians)
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.bounds.size
        //Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        //Rotate the image context
        bitmap.rotate(by: radians)
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(image.cgImage!, in: CGRect(x: -image.size.width / 2, y: -image.size.height / 2, width: image.size.width, height: image.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }

}

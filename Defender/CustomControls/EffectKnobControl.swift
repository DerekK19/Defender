//
//  EffectKnobControl.swift
//  Defender
//
//  Created by Derek Knight on 8/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class EffectKnobControl: NSView {
    
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
            var colour = backgroundColour
            colour.setFill()
            let rect = NSBezierPath(roundedRect: dirtyRect, xRadius: bounds.width / 2, yRadius: bounds.height / 2)
            rect.fill()
            colour = foregroundColour
            let fraction = self.minValue + (self._floatValue * (self.maxValue - self.minValue))
            let angle =  -(CGFloat(fraction * Float(M_PI) * 2.0) + CGFloat(M_PI / 2.0))
            let dirX = cos(angle)
            let dirY = sin(angle)
            let centreX = bounds.width / 2
            let centreY = bounds.height / 2
            let radius = bounds.width / 2
            let startPoint = NSMakePoint(centreX + (radius-4) * dirX, centreY + (radius-4) * dirY)
            let endPoint = NSMakePoint(centreX + radius * dirX, centreY + radius * dirY)
//            NSLog("Value \(_floatValue) - angle \(angle). In \(bounds). Line from \(startPoint) to \(endPoint)")
            let line = NSBezierPath()
            line.move(to: startPoint)
            line.line(to: endPoint)
            line.lineWidth = 1.0
            colour.set()
            line.stroke()
            unlockFocus()
        }
    }
}

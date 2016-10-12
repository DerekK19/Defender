//
//  EffectKnobControl.swift
//  Defender
//
//  Created by Derek Knight on 8/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

protocol EffectKnobDelegate {
    func valueDidChangeForKnob(_ sender: EffectKnobControl, value: Float)
}

class EffectKnobControl: NSView {
    
    var backgroundColour: NSColor = NSColor.black {
        didSet {
            setNeedsDisplay(self.bounds)
        }
    }
    var foregroundColour: NSColor = NSColor.white
    
    let pixelsPerTick: Float = 30.0
    
    var minValue: Float = 0.1
    var maxValue: Float = 0.9

    var minStop: Float = 0.0
    var maxStop: Float = 1.0

    var startMouse: NSPoint!
    var startValue: Float = 1.0
    var direction: Float = 1.0
    
    var delegate: EffectKnobDelegate?

    fileprivate var _floatValue: Float = 0.0
    var floatValue: Float = 0.0 {
        didSet {
            _floatValue = floatValue
            setNeedsDisplay(self.bounds)
        }
    }

    // Event handling
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        startMouse = theEvent.locationInWindow
        startValue = _floatValue
        let viewMouse = self.convert(startMouse!, from: nil)
        let midX = self.frame.width / 2.0
        direction = viewMouse.x < midX ? 1.0 : -1.0
    }
    
    override func mouseDragged(with theEvent: NSEvent) {
        let yChange = Float(theEvent.locationInWindow.y - startMouse.y) * direction
        _floatValue = min(max(startValue + (yChange / pixelsPerTick), minStop), maxStop)
        setNeedsDisplay(self.bounds)
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        let yChange = Float(theEvent.locationInWindow.y - startMouse.y) * direction
        floatValue = min(max(startValue + (yChange / pixelsPerTick), minStop), maxStop)
        delegate?.valueDidChangeForKnob(self, value: floatValue)
    }
    
    // Drawing
    override func draw(_ dirtyRect: NSRect) {
        if !isHidden {
            lockFocus()
            var colour = backgroundColour
            colour.setFill()
            var rect = NSBezierPath(roundedRect: dirtyRect, xRadius: bounds.width / 2, yRadius: bounds.height / 2)
            rect.fill()
            colour = foregroundColour
            let fraction = self.minValue + (self._floatValue * (self.maxValue - self.minValue))
            let angle =  -(CGFloat(fraction * Float(M_PI) * 2.0) + CGFloat(M_PI / 2.0))
            let dirX = cos(angle)
            let dirY = sin(angle)
            let centreX = bounds.width / 2
            let centreY = bounds.height / 2
            let radius = bounds.width / 2
            let dotRadius = CGFloat(1.5)
            let midPoint = NSMakePoint(centreX + (radius-3) * dirX, centreY + (radius-3) * dirY)
            let dotRect = NSMakeRect(midPoint.x - dotRadius, midPoint.y - dotRadius, dotRadius * 2.0, dotRadius * 2.0)
            rect = NSBezierPath(roundedRect: dotRect, xRadius: dotRadius, yRadius: dotRadius)
            colour.set()
            rect.stroke()
            rect.fill()
            unlockFocus()
        }
    }
}

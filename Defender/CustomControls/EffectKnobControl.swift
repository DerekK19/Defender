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

class EffectKnobControl: KnobBaseControl {
    
    var delegate: EffectKnobDelegate?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.configure()
    }
    
    private func configure() {
        super.configure(minValue: 0.0, maxValue: 1.0, minStop: 0.1, maxStop: 0.9, pixelsPerTick: 30)
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        super.mouseUp(with: theEvent)
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
            let angle = radiansFromFloatValue(self._floatValue)
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

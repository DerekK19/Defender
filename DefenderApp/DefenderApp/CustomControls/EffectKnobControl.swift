//
//  EffectKnobControl.swift
//  DefenderApp
//
//  Created by Derek Knight on 2/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit

protocol EffectKnobDelegate {
    func valueDidChangeForKnob(_ sender: EffectKnobControl, value: Float)
}

class EffectKnobControl: KnobBaseControl {
    
    var delegate: EffectKnobDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }
    
    override init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        self.configure()
    }
    
    private func configure() {
        super.configure(minValue: 0.0, maxValue: 1.0, minStop: 0.1, maxStop: 0.9, pixelsPerTick: 30)
    }

    /*
    override func mouseUp(with theEvent: NSEvent) {
        super.mouseUp(with: theEvent)
        delegate?.valueDidChangeForKnob(self, value: floatValue)
    }
    */
 
    // Drawing
    override func draw(_ dirtyRect: CGRect) {
        if !isHidden {
            var colour = backgroundColour
            colour.setFill()
            var rect = UIBezierPath(roundedRect: dirtyRect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: bounds.height / 2, height: bounds.height / 2))
            rect.fill()
            colour = foregroundColour
            let angle = radiansFromFloatValue(self._floatValue)
            let dirX = cos(angle)
            let dirY = sin(angle)
            let centreX = bounds.width / 2
            let centreY = bounds.height / 2
            let radius = bounds.width / 2
            let dotRadius = CGFloat(1.5)
            let midPoint = CGPoint(x: centreX + (radius-3) * dirX, y: centreY + (radius-3) * dirY)
            let dotRect = CGRect(x: midPoint.x - dotRadius, y: midPoint.y - dotRadius, width: dotRadius * 2.0, height: dotRadius * 2.0)
            rect = UIBezierPath(roundedRect: dotRect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: dotRadius, height: dotRadius))
            colour.set()
            rect.stroke()
            rect.fill()
        }
    }
}

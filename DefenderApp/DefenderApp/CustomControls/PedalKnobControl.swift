//
//  PedalKnobControl.swift
//  DefenderApp
//
//  Created by Derek Knight on 29/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit

protocol PedalKnobDelegate {
    func valueDidChangeForKnob(_ sender: PedalKnobControl, value: Float)
}

class PedalKnobControl: KnobBaseControl {
    
    var delegate: PedalKnobDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }
    
    override init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        self.configure()
    }
    
    private func configure() {
        self.backgroundColor = UIColor.clear
        super.configure(minValue: 0.0, maxValue: 1.0, minStop: -0.05, maxStop: 1.05, pixelsPerTick: 40)
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
            if let knobImage = UIImage(named: "pedal-knob") {
                let angle = degreesFromFloatValue(_floatValue)
                let rotatedKnob = self.imageRotatedByDegrees(knobImage, degrees: angle)
                let copyRect = CGRect(x: (rotatedKnob.size.width-dirtyRect.size.width)/2.0, y: (rotatedKnob.size.height-dirtyRect.size.height)/2.0, width: dirtyRect.width, height: dirtyRect.height)
                rotatedKnob.draw(in: dirtyRect)
//                rotatedKnob.draw(in: dirtyRect, from: copyRect, operation: .sourceOver, fraction: 1.0)
            }
        }
    }
    
}

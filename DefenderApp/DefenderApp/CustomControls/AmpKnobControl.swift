//
//  AmpKnobControl.swift
//  DefenderApp
//
//  Created by Derek Knight on 1/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit

protocol AmpKnobDelegate {
    func valueDidChangeForKnob(_ sender: AmpKnobControl, value: Float)
}

class AmpKnobControl: KnobBaseControl {
    
    var delegate: AmpKnobDelegate?
    
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
        super.configure(minValue: 1.0, maxValue: 10.0, minStop: 1.0, maxStop: 12.0, pixelsPerTick: 15)
    }

    /*
    override func mouseUp(with theEvent: NSEvent) {
        super.mouseUp(with: theEvent)
        delegate?.valueDidChangeForKnob(self, value: floatValue)
    }
    */
    
    // MARK: Draw function
    override func draw(_ dirtyRect: CGRect) {
        if !isHidden {
            if let knobImage = UIImage(named: "knob") {
                let angle = degreesFromFloatValue(_floatValue)
                let rotatedKnob = self.imageRotatedByDegrees(knobImage, degrees: angle)
                rotatedKnob.draw(in: dirtyRect)
            }
        }
    }
    
}

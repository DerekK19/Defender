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
        backgroundColor = UIColor.clear
        super.configure(minValue: 0.0, maxValue: 1.0, minStop: -0.05, maxStop: 1.05, pixelsPerTick: 40)
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
    }
    
    @objc fileprivate func handlePan(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: self)
        if recognizer.state == .began {
            super.startedPan(at: location)
        } else if recognizer.state == .changed {
            super.panning(at: location)
        } else if recognizer.state == .ended {
            super.endedPan(at: location)
            delegate?.valueDidChangeForKnob(self, value: floatValue)
        }
    }
    
    // Drawing
    override func draw(_ dirtyRect: CGRect) {
        if !isHidden {
            if let knobImage = UIImage(named: "pedal-knob") {
                let angle = degreesFromFloatValue(_floatValue)
                let rotatedKnob = self.imageRotatedByDegrees(knobImage, degrees: angle)
                rotatedKnob.draw(in: dirtyRect)
            }
        }
    }
    
}

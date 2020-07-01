//
//  AmpKnobControl.swift
//  Defender
//
//  Created by Derek Knight on 7/08/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

protocol AmpKnobDelegate {
    func valueDidChangeForKnob(_ sender: AmpKnobControl, value: Float)
}

class AmpKnobControl: KnobBaseControl {

    var delegate: AmpKnobDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.configure()
    }

    private func configure() {
        super.configure(minValue: 1.0, maxValue: 10.0, minStop: 1.0, maxStop: 12.0, pixelsPerTick: 15)
    }

    override func mouseUp(with theEvent: NSEvent) {
        super.mouseUp(with: theEvent)
        delegate?.valueDidChangeForKnob(self, value: floatValue)
    }
    
    func setFloatValueTo(_ floatValue: Float) {
        super.floatValue = floatValue
        delegate?.valueDidChangeForKnob(self, value: floatValue)
    }    

    // MARK: Draw function
    override func draw(_ dirtyRect: NSRect) {
        if !isHidden {
            if let knobImage = NSImage(named: "knob") {
                let angle = degreesFromFloatValue(_floatValue)
                let rotatedKnob = imageRotatedByDegrees(knobImage, degrees: angle)
                let copyRect = NSMakeRect((rotatedKnob.size.width-dirtyRect.size.width)/2.0, (rotatedKnob.size.height-dirtyRect.size.height)/2.0, dirtyRect.width, dirtyRect.height)
                rotatedKnob.draw(in: dirtyRect, from: copyRect, operation: .sourceOver, fraction: 1.0)
            }
        }
    }

}

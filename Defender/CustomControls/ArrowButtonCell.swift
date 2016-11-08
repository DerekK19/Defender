//
//  ArrowControl.swift
//  Defender
//
//  Created by Derek Knight on 8/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class ArrowButtonCell: NSButtonCell {
    
    var clearColour: NSColor = NSColor(colorLiteralRed: 0.39, green: 0.31, blue: 0.24, alpha: 1.0)
    var whiteColour: NSColor = NSColor(colorLiteralRed: 1.00, green: 0.91, blue: 0.85, alpha: 1.0)
    var greenColour: NSColor = NSColor(colorLiteralRed: 0.95, green: 0.98, blue: 0.66, alpha: 1.0)
    var redColour: NSColor = NSColor(colorLiteralRed: 0.99, green: 0.54, blue: 0.68, alpha: 1.0)
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = whiteColour
    }
    
    override func drawBezel(withFrame frame: NSRect, in controlView: NSView) {
        if let ctx = NSGraphicsContext.current() {
            ctx.saveGraphicsState()
            
            let innerRect = frame.insetBy(dx: 6.0, dy: 6.0)
            let path = NSBezierPath(roundedRect: innerRect, xRadius: innerRect.height/2, yRadius: innerRect.height/2)
            self.backgroundColor?.setFill()
            path.fill()
            
            ctx.restoreGraphicsState()
        }
    }
    
    func setState(_ state: ArrowButtonState, powerState: PowerState) {
        self.backgroundColor = colourForState(state, powerState: powerState)
        self.controlView?.needsDisplay = true
    }
    
    fileprivate func colourForState(_ state: ArrowButtonState, powerState: PowerState) -> NSColor {
        switch powerState {
        case .off:
            return clearColour
        case .on:
            switch state {
            case .active:
                return whiteColour
            case .warning:
                return redColour
            case .ok:
                return greenColour
            }
        }
    }
    
}

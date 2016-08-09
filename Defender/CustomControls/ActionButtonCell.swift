//
//  ActionButtonCell.swift
//  Defender
//
//  Created by Derek Knight on 9/08/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class ActionButtonCell: NSButtonCell {
    
    var whiteColour: NSColor = NSColor(colorLiteralRed: 1.00, green: 0.91, blue: 0.85, alpha: 1.0)
    var greenColour: NSColor = NSColor(colorLiteralRed: 0.95, green: 0.98, blue: 0.66, alpha: 1.0)
    var redColour: NSColor = NSColor(colorLiteralRed: 0.99, green: 0.54, blue: 0.68, alpha: 1.0)
    
    enum State {
        case Initial
        case Warning
        case OK
    }
    
    var currentState: State = .Initial
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = colourForState(currentState)
    }
 
    override func drawBezelWithFrame(frame: NSRect, inView controlView: NSView) {
        if let ctx = NSGraphicsContext.currentContext() {
            ctx.saveGraphicsState()
            
            let innerRect = frame.insetBy(dx: 6.0, dy: 6.0)
            let path = NSBezierPath(roundedRect: innerRect, xRadius: innerRect.height/2, yRadius: innerRect.height/2)
            colourForState(currentState).setFill()
            path.fill()
            
            ctx.restoreGraphicsState()
        }
    }
    
    private func colourForState(state: State) -> NSColor {
        switch state {
        case .Initial:
            return whiteColour
        case .Warning:
            return redColour
        case .OK:
            return greenColour
        }
    }
    
}
//
//  ArrowButtonControl.swift
//  Defender
//
//  Created by Derek Knight on 8/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

enum ArrowButtonState {
    case inactive
    case active
    case current
}

class ArrowButtonControl: NSButton {
    
    let dullColour: NSColor = NSColor(calibratedRed: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
    let brightColour: NSColor = NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

    var currentState: ArrowButtonState = .active
    
    override var title: String {
        get {
            return super.title
        }
        set {
            super.title = newValue
            super.isEnabled = title != ""
        }
    }

    func setState(_ state: ArrowButtonState) {
        currentState = state
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = .center
        attributedTitle = NSAttributedString(string: title,
                                             attributes: [NSAttributedString.Key.foregroundColor : colourForState(currentState),
                                                          NSAttributedString.Key.paragraphStyle : pstyle])
    }
    
    fileprivate func colourForState(_ state: ArrowButtonState) -> NSColor {
        switch state {
        case .active:
            return dullColour
        case .current:
            return brightColour
        case .inactive:
            return (cell as? ArrowButtonCell)?.backgroundColor ?? NSColor.clear
        }
    }
}

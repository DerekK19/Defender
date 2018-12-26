//
//  ActionButtonControl.swift
//  Defender
//
//  Created by Derek Knight on 9/08/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

enum ActionButtonState {
    case active
    case warning
    case ok
}

class ActionButtonControl: NSButton {

    var currentState: ActionButtonState = .active
    
    var powerState: PowerState = .off {
        didSet {
            if powerState == .off {
                currentState = .active
            } else {
            }
            setState(currentState)
        }
    }
    
    func setState(_ state: ActionButtonState) {
        currentState = state
        if let cell = cell as? ActionButtonCell {
            cell.setState(state, powerState: powerState)
            isEnabled = powerState != .off
            let textColour = powerState == .off ? NSColor.white : NSColor.black
            self.attributedTitle = NSAttributedString(string: self.title, attributes: [NSAttributedStringKey.foregroundColor : textColour, NSAttributedStringKey.font: NSFont.systemFont(ofSize: 13)])
            self.attributedAlternateTitle = NSAttributedString(string: self.alternateTitle, attributes: [NSAttributedStringKey.foregroundColor : textColour, NSAttributedStringKey.font: NSFont.systemFont(ofSize: 13)])
        }
    }
    
}

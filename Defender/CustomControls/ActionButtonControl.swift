//
//  ActionButtonControl.swift
//  Defender
//
//  Created by Derek Knight on 9/08/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

enum ActionButtonState {
    case Active
    case Warning
    case OK
}

class ActionButtonControl: NSButton {

    var currentState: ActionButtonState = .Active
    
    var powerState: PowerState = .Off {
        didSet {
            if powerState == .Off {
                currentState = .Active
            } else {
            }
            setState(currentState)
        }
    }
    
    func setState(state: ActionButtonState) {
        currentState = state
        if let cell = cell as? ActionButtonCell {
            cell.setState(state, powerState: powerState)
            self.enabled = powerState != .Off
        }
    }
    
}
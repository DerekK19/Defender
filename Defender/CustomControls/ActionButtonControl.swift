//
//  ActionButtonControl.swift
//  Defender
//
//  Created by Derek Knight on 9/08/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

enum ActionButtonState {
    case Initial
    case Warning
    case OK
}

class ActionButtonControl: NSButton {

    var currentState: ActionButtonState = .Initial
    
    func setState(state: ActionButtonState) {
        currentState = state
        if let cell = cell as? ActionButtonCell {
            cell.setState(state)
        }
    }
    
    
}
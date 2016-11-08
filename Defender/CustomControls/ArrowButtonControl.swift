//
//  ArrowButtonControl.swift
//  Defender
//
//  Created by Derek Knight on 8/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

enum ArrowButtonState {
    case active
    case warning
    case ok
}

class ArrowButtonControl: NSButton {
    
    var currentState: ArrowButtonState = .active
    
    var powerState: PowerState = .off {
        didSet {
            if powerState == .off {
                currentState = .active
            } else {
            }
            setState(currentState)
        }
    }
    
    func setState(_ state: ArrowButtonState) {
        currentState = state
        if let cell = cell as? ArrowButtonCell {
            cell.setState(state, powerState: powerState)
            self.isEnabled = powerState != .off
        }
    }
    
}

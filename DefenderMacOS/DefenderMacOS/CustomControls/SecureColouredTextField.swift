//
//  SecureColouredTextField.swift
//  Defender
//
//  Created by Derek Knight on 25/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class SecureColouredTextField : NSSecureTextField {
    
    override func becomeFirstResponder() -> Bool {
        let rValue = super.becomeFirstResponder()
        if rValue {
            if let textColour = textColor {
                (currentEditor() as? NSTextView)?.insertionPointColor = textColour
            }
        }
        return rValue
    }
    
}

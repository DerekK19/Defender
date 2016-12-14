//
//  NSColor+Colours.swift
//  Defender
//
//  Created by Derek Knight on 14/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

extension NSColor {
    
    class var slotBackground: NSColor {
        get {
            return NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        }
    }
    
    class var shadeClosed: NSColor {
        get {
            return NSColor(red: 0.07, green: 0.09, blue: 0.12, alpha: 0.6)
        }
    }
    
    class var shadeAjar: NSColor {
        get {
            return NSColor(red: 0.07, green: 0.09, blue: 0.12, alpha: 0.3)
        }
    }
    
    class var shadeOpen: NSColor {
        get {
            return NSColor(red: 0.07, green: 0.09, blue: 0.12, alpha: 0.0)
        }
    }
    
    class var lead: NSColor {
        get {
            return NSColor(red: 0.15, green: 0.36, blue: 0.76, alpha: 0.8)
        }
    }
}

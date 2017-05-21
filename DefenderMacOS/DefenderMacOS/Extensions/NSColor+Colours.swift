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
    
    class var yellowPedal: NSColor {
        get {
            return NSColor(red: 1.0, green: 0.97, blue: 0.31, alpha: 1.0)
            
        }
    }
    
    class var greenPedal: NSColor {
        get {
            return NSColor(red: 0.05, green: 0.87, blue: 0.48, alpha: 1.0)
            
        }
    }
    
    class var bluePedal: NSColor {
        get {
            return NSColor(red: 0.17, green: 0.56, blue: 0.98, alpha: 1.0)
            
        }
    }
    
    class var orangePedal: NSColor {
        get {
            return NSColor(red: 0.95, green: 0.63, blue: 0.18, alpha: 1.0)
            
        }
    }
    
    class var greyEffect: NSColor {
        get {
            return NSColor(red: 0.49, green: 0.49, blue: 0.49, alpha: 1.0)
        }
    }
    
    class var blueEffect: NSColor {
        get {
            return NSColor(red: 0.11, green: 0.28, blue: 0.43, alpha: 1.0)
        }
    }
    
    class var greenEffect: NSColor {
        get {
            return NSColor(red: 0.22, green: 0.30, blue: 0.25, alpha: 1.0)
        }
    }
    
    class var purpleEffect: NSColor {
        get {
            return NSColor(red: 0.30, green: 0.30, blue: 0.41, alpha: 1.0)
        }
    }
    
    class var LCDLightBlue: NSColor {
        get {
            return NSColor(red: 0.62, green: 0.78, blue: 0.88, alpha: 1.0)

        }
    }
    
    class var LCDDarkBlue: NSColor {
        get {
            return NSColor(red: 0.3, green: 0.38, blue: 0.6, alpha: 1.0)
        }
    }
}

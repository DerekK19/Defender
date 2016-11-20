//
//  NSColor+Brightness.swift
//  Defender
//
//  Created by Derek Knight on 8/10/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

extension NSColor {
 
    func withBrightness(_ brightness: CGFloat) -> NSColor {
        return NSColor(red: self.redComponent*0.66, green: self.greenComponent*0.66, blue: self.blueComponent*0.66, alpha: self.alphaComponent)
    }
}

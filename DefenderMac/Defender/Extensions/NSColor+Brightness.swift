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
        return NSColor(red: self.redComponent*brightness, green: self.greenComponent*brightness, blue: self.blueComponent*brightness, alpha: self.alphaComponent)
    }
}

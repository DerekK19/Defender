//
//  NSImage+Colour.swift
//  Defender
//
//  Created by Derek Knight on 8/08/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

extension NSImage {
    
    public func imageWithTintColor(_ color: NSColor) -> NSImage {
        let image: NSImage = self.copy() as! NSImage
        image.lockFocus()
        color.set()
        NSRectFillUsingOperation(NSRect(origin: NSZeroPoint, size: image.size), .sourceAtop)
        image.unlockFocus()
        return image
    }
    
}

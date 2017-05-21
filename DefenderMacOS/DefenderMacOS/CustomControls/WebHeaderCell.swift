//
//  WebHeaderCell.swift
//  Defender
//
//  Created by Derek Knight on 8/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class WebHeaderCell : NSTableHeaderCell {
    
    var backgroundColour: NSColor = NSColor.black {
        didSet {
            backgroundColor = backgroundColour
        }
    }

    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        super.draw(withFrame: cellFrame, in: controlView)
        if !controlView.isHidden {
            backgroundColor?.setFill()
            NSRectFill(cellFrame)
            drawInterior(withFrame: cellFrame, in: controlView)
        }
    }
   
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        if !controlView.isHidden {
            font = NSFont(name: "System Regular", size: 13)
            textColor = NSColor.white
            let rect = titleRect(forBounds: cellFrame)
            attributedStringValue.draw(in: rect)
        }
    }
    
}

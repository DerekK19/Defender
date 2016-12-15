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
            self.backgroundColor = backgroundColour
        }
    }

    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        super.draw(withFrame: cellFrame, in: controlView)
        if !controlView.isHidden {
            backgroundColor?.setFill()
            NSRectFill(cellFrame)
            self.drawInterior(withFrame: cellFrame, in: controlView)
        }
    }
   
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        if !controlView.isHidden {
            self.font = NSFont(name: "System Regular", size: 13)
            self.textColor = NSColor.white
            let titleRect = self.titleRect(forBounds: cellFrame)
            self.attributedStringValue.draw(in: titleRect)
        }
    }
    
}

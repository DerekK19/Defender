//
//  ShadeControl.swift
//  DefenderApp
//
//  Created by Derek Knight on 29/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit

class ShadeControl: UIView {
    
    var backgroundColour: UIColor = UIColor.shadeClosed {
        didSet {
            setNeedsDisplay(self.bounds)
        }
    }
    
    var state: ShadeState = .closed {
        didSet {
            backgroundColour = state == .open ? UIColor.shadeOpen : state == .ajar ? UIColor.shadeAjar : UIColor.shadeClosed
            self.isHidden = state == .open
            setNeedsDisplay(self.bounds)
        }
    }
    
    override func draw(_ dirtyRect: CGRect) {
        if !isHidden {
            let colour = backgroundColour
            colour.setFill()
            let rect = UIBezierPath(rect: dirtyRect)
            rect.fill()
        }
    }
}

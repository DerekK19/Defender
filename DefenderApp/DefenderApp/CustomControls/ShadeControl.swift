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
    
    var isOpen: Bool = false {
        didSet {
            backgroundColour = isOpen ? UIColor.shadeOpen : UIColor.shadeClosed
            self.isHidden = isOpen
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

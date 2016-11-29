//
//  ShadeControl.swift
//  DefenderApp
//
//  Created by Derek Knight on 29/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit

class ShadeControl: UIView {
    
    var backgroundColour: UIColor = UIColor(red: 0.66, green: 0.66, blue: 0.66, alpha: 0.6) {
        didSet {
            setNeedsDisplay(self.bounds)
        }
    }
    
    var isOpen: Bool = false {
        didSet {
            backgroundColour = UIColor(red: 0.66, green: 0.66, blue: 0.66, alpha: isOpen ? 0.0 : 0.6)
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

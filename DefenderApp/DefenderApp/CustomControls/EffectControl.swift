//
//  EffectControl.swift
//  DefenderApp
//
//  Created by Derek Knight on 1/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit

class EffectControl: UIView {
    
    var backgroundColour: UIColor = UIColor.slotBackground {
        didSet {
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

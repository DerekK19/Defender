//
//  EffectSlotControl.swift
//  DefenderApp
//
//  Created by Derek Knight on 29/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit

class EffectSlotControl: UIView {
    
    var backgroundColour: UIColor = UIColor.slotBackground {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    
    override func draw(_ dirtyRect: CGRect) {
        if !isHidden {
            let colour = backgroundColour
            colour.setFill()
            let rect = UIBezierPath(roundedRect: dirtyRect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 4, height: 4))
            rect.fill()
        }
    }
}

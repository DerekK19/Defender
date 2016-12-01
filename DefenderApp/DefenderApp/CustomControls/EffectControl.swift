//
//  EffectControl.swift
//  DefenderApp
//
//  Created by Derek Knight on 1/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit


class EffectControl: UIView {
    
    var backgroundColour: UIColor = UIColor(red: 0.13, green: 0.28, blue: 0.43, alpha: 1.0) {
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

//
//  PedalBodyControl.swift
//  DefenderApp
//
//  Created by Derek Knight on 29/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit

class PedalBodyControl: UIView {
    
    var backgroundColour: UIColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0) {
        didSet {
            setNeedsDisplay(self.bounds)
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

    /*
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        backgroundColor = backgroundColour
        let insetRect = CGRect(x: bounds.origin.x+3, y: bounds.origin.y, width: bounds.width-6, height: bounds.height-3)
        let rect = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 4, height: 4)) // Round corner path for full rectangle
        let rect2 = UIBezierPath(roundedRect: insetRect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 4, height: 4)) // Round corner path for inset rectangle
        
        // Set the fill colour
        //colour.setFill()
        
        // Draw the full rectangle with rounded corners
        //rect.fill()
        
        // Set up a drop shadow (light appears to come from above and to the bottom)
        let dropShadow = NSShadow()
        dropShadow.shadowColor = UIColor.black
        dropShadow.shadowBlurRadius = 10
        dropShadow.shadowOffset = CGSize(width: 0, height: -3)
        
            // save graphics state
//            CGGraphicsContext.saveGraphicsState()
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: -3)
        layer.shadowPath = rect2.cgPath
            
        // Draw the inset rectangle, which will apply the drop shadow
        //rect2.fill()
        
            // restore state
//        CGGraphicsContext.restoreGraphicsState()
            
    }
 */
}

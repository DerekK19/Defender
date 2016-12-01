//
//  PedalBodyControl.swift
//  DefenderApp
//
//  Created by Derek Knight on 29/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit

class PedalBodyControl: UIView {
    
    let shadowWidth: CGFloat = 3
    let cornerRadius: CGFloat = 4
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }
    
    override init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        self.configure()
    }
    
    private func configure() {
        self.backgroundColor = UIColor.clear
    }
    
    var backgroundColour: UIColor = UIColor.slotBackground {
        didSet {
            setNeedsDisplay(self.bounds)
        }
    }
    
    private func insetPath (by offset: CGFloat) -> UIBezierPath {
        let insetRect = CGRect(x: bounds.origin.x+offset, y: bounds.origin.y, width: bounds.width-(offset*2), height: bounds.height-offset)
        let path = UIBezierPath(roundedRect: insetRect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        return path
    }
    
    override func draw(_ dirtyRect: CGRect) {
        if !isHidden {
            let colour = backgroundColour
            colour.setFill()
            insetPath(by: 0).fill()
        }
    }

    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let shadowLayer = CAShapeLayer()
        shadowLayer.frame = self.bounds
        shadowLayer.shadowColor = UIColor.slotBackground.cgColor
        shadowLayer.shadowOpacity = 1.0
        shadowLayer.shadowOffset = CGSize(width: 0, height: -3)
        shadowLayer.shadowRadius = 3
        shadowLayer.fillRule = kCAFillRuleEvenOdd
        shadowLayer.name = "My Shadow"
        
        // Create the larger rectangle path.
        let path = CGMutablePath()
        
        path.addRect(self.bounds.insetBy(dx: -3, dy: -3))
        
        // Add the inner path so it's subtracted from the outer path.
        // someInnerPath could be a simple bounds rect, or maybe
        // a rounded one for some extra fanciness.
        let someInnerPath = insetPath(by: 0).cgPath
        path.addPath(someInnerPath)
        path.closeSubpath()
        
        shadowLayer.path = path
        
        self.layer.sublayers?.forEach { if $0.name == "My Shadow" { $0.removeFromSuperlayer() } }
        self.layer.addSublayer(shadowLayer)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = someInnerPath
        shadowLayer.mask = maskLayer
    }
}

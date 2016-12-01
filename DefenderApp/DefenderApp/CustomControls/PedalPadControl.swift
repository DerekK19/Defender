//
//  PedalPadControl.swift
//  DefenderApp
//
//  Created by Derek Knight on 30/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit

class PedalPadControl: UIView {
    
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
    
    override func draw(_ dirtyRect: CGRect) {
        if !isHidden {
            let colour = backgroundColour
            colour.setFill()
            let rect = UIBezierPath(roundedRect: dirtyRect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 4, height: 4))
            rect.fill()
        }
    }
}

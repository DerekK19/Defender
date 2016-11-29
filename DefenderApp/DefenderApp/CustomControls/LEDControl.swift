//
//  LEDControl.swift
//  DefenderApp
//
//  Created by Derek Knight on 18/11/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit

class LEDControl: UIView {
    
    var backgroundColour: UIColor = UIColor.clear {
        didSet {
            self.backgroundColor = backgroundColour
            setNeedsDisplay(self.bounds)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        privateInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        privateInit()
    }
    
    private func privateInit() {
        self.layer.cornerRadius = self.frame.width / 2
    }
    
}

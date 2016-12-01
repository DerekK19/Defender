//
//  UIColor+Colours.swift
//  DefenderApp
//
//  Created by Derek Knight on 1/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit

extension UIColor {
    
    class var slotBackground: UIColor {
        get {
            return UIColor(red: 0.07, green: 0.09, blue: 0.12, alpha: 1.0)
        }
    }
    
    class var shadeClosed: UIColor {
        get {
            return UIColor(red: 0.07, green: 0.09, blue: 0.12, alpha: 0.6)
        }
    }
    
    class var shadeAjar: UIColor {
        get {
            return UIColor(red: 0.07, green: 0.09, blue: 0.12, alpha: 0.3)
        }
    }

    class var shadeOpen: UIColor {
        get {
            return UIColor(red: 0.07, green: 0.09, blue: 0.12, alpha: 0.0)
        }
    }
    
}

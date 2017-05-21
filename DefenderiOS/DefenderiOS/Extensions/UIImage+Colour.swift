//
//  UIImage+Colour.swift
//  DefenderApp
//
//  Created by Derek Knight on 1/12/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import UIKit

extension UIImage {
    
    public func imageWithTintColor(_ color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
        var rect = CGRect.zero
        rect.size = size
        color.set()
        UIRectFill(rect)
        draw(in: rect, blendMode: .destinationIn, alpha: 1.0)
        let outImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outImage!
    }
    
}

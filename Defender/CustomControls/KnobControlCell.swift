//
//  KnobControlCell.swift
//  Defender
//
//  Created by Derek Knight on 7/08/16.
//  Copyright © 2016 Derek Knight. All rights reserved.
//

import Cocoa

class KnobControlCell: NSSliderCell {
    
    override func drawInteriorWithFrame(cellFrame: NSRect, inView controlView: NSView) {
        let cellFrame = drawingRectForBounds(cellFrame)
        
        if let knobImage = NSImage(named: "knob") {
            let fraction = (self.doubleValue - self.minValue) / (self.maxValue - self.minValue)
            let angle = CGFloat((fraction * 360.0) - 180.0) //CGFloat((fraction * (2.0 * M_PI)) - (M_PI / 2.0))
            let rotatedKnob = self.imageRotatedByDegrees(knobImage, degrees: angle)
            let copyRect = NSMakeRect((rotatedKnob.size.width-cellFrame.size.width)/2.0, (rotatedKnob.size.height-cellFrame.size.height)/2.0, cellFrame.width, cellFrame.height)
            rotatedKnob.drawInRect(cellFrame, fromRect: copyRect, operation: .CompositeSourceOver, fraction: 1.0)
        }
    }

    private func imageRotatedByDegrees(image: NSImage, degrees: CGFloat) -> NSImage {
        var imageBounds = NSRect(origin: NSZeroPoint, size: self.cellSize)
        
        let boundsPath = NSBezierPath(rect: imageBounds)
        var transform = NSAffineTransform()
        transform.rotateByDegrees(degrees)
        boundsPath.transformUsingAffineTransform(transform)
        let rotatedBounds = NSRect(origin: NSZeroPoint, size: boundsPath.bounds.size)
        let rotatedImage = NSImage(size: rotatedBounds.size)

        // Centre the image within the rotated bounds
        imageBounds.origin.x = NSMidX(rotatedBounds) - (NSWidth (imageBounds) / 2)
        imageBounds.origin.y = NSMidY(rotatedBounds) - (NSHeight (imageBounds) / 2)
        
        // Set up the rotation transform
        transform = NSAffineTransform()
        transform.translateXBy((NSWidth(rotatedBounds) / 2), yBy: (NSHeight(rotatedBounds) / 2))
        transform.rotateByDegrees(degrees)
        transform.translateXBy(-(NSWidth(rotatedBounds) / 2), yBy: -(NSHeight(rotatedBounds) / 2))

        // draw the original image, rotated, into the new image
        rotatedImage.lockFocus()
        transform.concat()
        image.drawInRect(imageBounds, fromRect:NSZeroRect, operation: NSCompositingOperation.CompositeCopy, fraction:1.0)
        rotatedImage.unlockFocus()
        
        return rotatedImage
    }
    
}

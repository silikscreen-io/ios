//
//  HexaButton.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 18.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

var R: CGFloat = 18
var width: CGFloat = 2 * R
var r: CGFloat = 0.86603 * R
var height: CGFloat = 2 * r
var xStep: CGFloat = 0.5 * R
var maskImage: UIImage?

var buttons: [Int: HexaButton] = [:]

class HexaButton: UIButton {

    var index: Int
    var color = UIColor(red: 1, green: 0.3, blue: 1, alpha: 0)
    var image: UIImage?
    
    
    override init(frame: CGRect) {
        index = 0
        super.init(frame: frame)
    }
    
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    class func addButton(x: CGFloat, y: CGFloat, target: AnyObject?, action: Selector, view: UIView) {
        var button = HexaButton(frame: CGRectMake(x, y, width, height))
        button.index = buttons.count
        button.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(button)
        buttons[button.index] = button
    }
    
    
    
    class func hideAllButtons(hidden: Bool) {
        for (_, button) in buttons {
            button.hidden = hidden
        }
    }
    
    
    
    func setMainImage(image: UIImage?) {
        if image != nil {
            var destinationSize = self.frame.size
            UIGraphicsBeginImageContext(destinationSize)
            image!.drawInRect(CGRectMake(0, 0, destinationSize.width, destinationSize.height))
            var newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            self.image = newImage
            self.setNeedsDisplay()
        }
    }
    
    
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        if (CGRectContainsPoint(self.bounds, point)) {
            if maskImage == nil {
                return super.pointInside(point, withEvent: event)
            } else {
                let image = maskImage!
                let pointX = trunc(point.x)
                let pointY = trunc(point.y)
                let cgImage = image.CGImage
                let width = image.size.width
                let height = image.size.height
                var pixelData: [CUnsignedChar]  = [0, 0, 0, 0]
                let bytesPerPixel: UInt = 4
                let bytesPerRow: UInt = bytesPerPixel * 1
                let bitsPerComponent: UInt = 8
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let bitmapInfo = CGBitmapInfo.ByteOrder32Big// | CGBitmapInfo.fromMask(CGImageAlphaInfo.PremultipliedLast.toRaw())
                let context = CGBitmapContextCreate(&pixelData, 1, 1, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo)
                CGContextSetBlendMode(context, kCGBlendModeCopy)
                
                CGContextTranslateCTM(context, -pointX, pointY - height)
                CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), cgImage)
                let a = CGFloat(pixelData[3]) / 255.0
                return a != 0.0
            }
        } else {
            return false;
        }
    }
    
    

    override func drawRect(rect: CGRect)
    {
        //// General Declarations
       var context = UIGraphicsGetCurrentContext()
        //// Color Declarations
        
        let fillColor = color
        
        //// Polygon Drawing
        var polygonPath = UIBezierPath()
        polygonPath.moveToPoint(CGPointMake(xStep, 0))
        polygonPath.addLineToPoint(CGPointMake(xStep + R, 0))
        polygonPath.addLineToPoint(CGPointMake(width, r))
        polygonPath.addLineToPoint(CGPointMake(xStep + R, height))
        polygonPath.addLineToPoint(CGPointMake(xStep, height))
        polygonPath.addLineToPoint(CGPointMake(0, r))
        polygonPath.closePath()
        
        if image != nil {
            let strokeColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.6)
            var imagePattern = UIColor(patternImage: image!)
            CGContextSaveGState(context)
            CGContextSetPatternPhase(context, CGSizeMake(0, 0))
            imagePattern.setFill()
            polygonPath.fill()
            CGContextRestoreGState(context)
            strokeColor.setStroke()
            polygonPath.lineWidth = 1;
            polygonPath.stroke()
        } else {
            fillColor.setFill()
            polygonPath.fill()
        }
    }

}

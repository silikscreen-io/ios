//
//  HexaButton.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 18.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

var gBigRadius: CGFloat = 18
var gWidth: CGFloat = 2 * gBigRadius
var gSmallRadiusr: CGFloat = 0.86603 * gBigRadius
var gHeight: CGFloat = 2 * gSmallRadiusr
var gXStep: CGFloat = 0.5 * gBigRadius
var maskImage: UIImage?
var maskImages: [Int: UIImage] = [:]

var buttons: [Int: HexaButton] = [:]

class HexaButton: UIButton {
    var R: CGFloat?
    var width: CGFloat?
    var r: CGFloat?
    var height: CGFloat?
    var xStep: CGFloat?

    var index: Int?
    var color = UIColor(red: 1, green: 0.3, blue: 1, alpha: 0)
    var image: UIImage?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    override init() {
        super.init()
    }
    
    
    init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat) {
        R = width / 2
        self.width = 2 * R!
        r = 0.86603 * R!
        height = 2 * r!
        xStep =  0.5 * R!
        super.init(frame: CGRectMake(x, y, height!, width))
    }
    
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    class func addButton(x: CGFloat, y: CGFloat, target: AnyObject?, action: Selector, view: UIView) {
        var button = HexaButton(frame: CGRectMake(x, y, gHeight, gWidth))
        button.R = gBigRadius
        button.width = gWidth
        button.r = gSmallRadiusr
        button.height = gHeight
        button.xStep = gXStep
        button.index = buttons.count
        button.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        dispatch_async(dispatch_get_main_queue(), {
            view.addSubview(button)
        })
        buttons[button.index!] = button
    }
    
    
    
    class func hideAllButtons(hidden: Bool) {
        for (_, button) in buttons {
            button.hidden = hidden
        }
    }
    
    
    
    func setMainImage(image: UIImage?) {
        if image != nil {
            let widthRatio = image!.size.width / frame.size.width
            let heightRatio = image!.size.height / frame.size.height
            let ratio = widthRatio < heightRatio ? widthRatio : heightRatio
            let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: frame.size.width * ratio, height: frame.size.height * ratio ))
            let imageRef = CGImageCreateWithImageInRect(image!.CGImage, rect);
            let croppedImage = UIImage(CGImage: imageRef)
            var destinationSize = self.frame.size
            
            UIGraphicsBeginImageContextWithOptions(destinationSize, false, 0)
            var context = UIGraphicsGetCurrentContext()
            CGContextSetInterpolationQuality(context, kCGInterpolationHigh)
            
            croppedImage!.drawInRect(CGRectMake(0, 0, destinationSize.width, destinationSize.height))
            var newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
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
                let bitmapInfo = CGBitmapInfo.ByteOrder32Big | CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)
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
        polygonPath.moveToPoint(CGPointMake(self.r!, 0))
        polygonPath.addLineToPoint(CGPointMake(self.height!, self.xStep!))
        polygonPath.addLineToPoint(CGPointMake(self.height!, self.xStep! + self.R!))
        polygonPath.addLineToPoint(CGPointMake(self.r!, self.width!))
        polygonPath.addLineToPoint(CGPointMake(0, self.width! - self.xStep!))
        polygonPath.addLineToPoint(CGPointMake(0, self.xStep!))
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

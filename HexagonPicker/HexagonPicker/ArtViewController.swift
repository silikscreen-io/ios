//
//  ArtViewController.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 18.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit
import CoreMotion

protocol ArtViewControllerDelegate {
    func dismissArtViewController()
}


class ArtViewController: UIViewController {
    
    let queue = dispatch_queue_create("com.vaisoft.hexagonpicker", nil)
    
    var delegate: ArtViewControllerDelegate!
    
    let motionManager = CMMotionManager()
    var artContent: ArtContentView?
    var visualEffectView: UIVisualEffectView?
    
    let maxXMovement: CGFloat = 20
    let maxYMovement: CGFloat = 20
    let minMotion: Double = 0.005
    var prevGX: Double?
    var prevGY: Double?
    var frameBase: CGRect?
    var deviceOrientation: UIDeviceOrientation?
    
    var tagsOn = true
    var artContentDisplayed = false

    var image: UIImage?
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var tagsOnOffButton: UIButton!
    @IBOutlet weak var showRouteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initParallaxEffect()
        
        fillViewWithButtons()
        
        var mask = UIImage(named: "hexagon_100.png")!
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        mask.drawInRect(CGRectMake(0, 0, width, height))
        var newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        maskImage = newImage
        
        backgroundImage.image = image
        frameBase = backgroundImage.frame
        initMotions()
        self.view.bringSubviewToFront(tagsOnOffButton)
        backgroundImage.alpha = tagsOn ? 0.8 : 1
        self.view.bringSubviewToFront(showRouteButton)
        
        let singleTap = UITapGestureRecognizer(target: self, action: "tapDetected")
        singleTap.numberOfTapsRequired = 1
        backgroundImage!.userInteractionEnabled = true
        backgroundImage!.addGestureRecognizer(singleTap)
        
        var frame = self.view.bounds
        frame.origin.x = 50
        frame.origin.y = 50
        artContent = ArtContentView(backgroundImage!, frame, artContentDisplayed)
        artContent!.addDescription("Currently On Display Currently On Display Currently On Display Currently On Display")
        for _ in 0...Int(arc4random_uniform(4)) {
            artContent!.addButton(ArtContentView.CONTENT_ID)
        }
    }
    
    
    
    func tapDetected() {
        artContentDisplayed = !artContentDisplayed
        artContent!.show(artContentDisplayed)
        let alpha: CGFloat = artContentDisplayed ? 0 : 0.8
        UIView.animateWithDuration(0.2, animations: { self.tagsOnOffButton.alpha = alpha })
        UIView.animateWithDuration(0.2, animations: { self.showRouteButton.alpha = alpha })
        if artContentDisplayed {
            motionManager.stopAccelerometerUpdates()
        } else {
            initMotions()
        }
    }

    
    
    override func viewDidAppear(animated: Bool) {
        deviceOrientation = UIDevice.currentDevice().orientation
    }
    
    
    
    @IBAction func showRouteButtonPressed(sender: UIButton) {
        if delegate != nil {
            delegate.dismissArtViewController()
        }
    }
    
    
    
    func initMotions() {
        if !motionManager.accelerometerAvailable {
            return
        }
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: {(accelerometerData, error) in
            self.outputAccelertionData(accelerometerData.acceleration)
        })
    }
    
    
    
    func outputAccelertionData(acceleration: CMAcceleration) {
        var gX = acceleration.x
        var gY = -acceleration.y
        if deviceOrientation == UIDeviceOrientation.LandscapeLeft {
            gX = -acceleration.y
            gY = acceleration.x
        } else if deviceOrientation == UIDeviceOrientation.LandscapeRight {
            gX = acceleration.y
            gY = -acceleration.x
        }
        if prevGX == nil || fabs(prevGX! - gX) >= minMotion {
            backgroundImage.frame.origin.x = frameBase!.origin.x + CGFloat(gX) * maxXMovement
            prevGX = gX
        }
        if prevGY == nil || fabs(prevGY! - gY) >= minMotion {
            backgroundImage.frame.origin.y = frameBase!.origin.y + CGFloat(gY) * maxYMovement
            prevGY = gY
        }
    }

    
    
    
    func initParallaxEffect() {
        var motionGroup = UIMotionEffectGroup()
        motionGroup.motionEffects = [getEffect("center.x", UIInterpolatingMotionEffectType.TiltAlongHorizontalAxis, -55, 55),
            getEffect("center.y", UIInterpolatingMotionEffectType.TiltAlongVerticalAxis, -55, 55)]
        backgroundImage.addMotionEffect(motionGroup)
    }
    
    
    
    func fillButtonWithImage(imageName: String) {
        var index = Int(arc4random_uniform(UInt32(buttons.count)))
        if let button = buttons[index] {
            button.setMainImage(UIImage(named: imageName))
        }
    }
    
    
    
    func fillViewWithButtons() {
        dispatch_async(queue, {
            self.optimizeHexagonWidth()
            let screenSize = self.view.bounds
            let maxX = screenSize.width
            let maxY = screenSize.height
            var firstLine = true
            var x: CGFloat = 0
            var y: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
            while trunc(y + height) <= maxY {
                while trunc(x + width) <= maxX {
                    HexaButton.addButton(x, y: y, target: self, action: "buttonPressed:", view: self.view)
                    x += width + R
                }
                firstLine = !firstLine
                if firstLine {
                    x = 0
                } else {
                    x = width - xStep
                }
                y += r
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.fillButtonWithImage("ann.jpg")
                self.fillButtonWithImage("gal.jpg")
                self.fillButtonWithImage("rah.jpg")
                self.fillButtonWithImage("ste.jpg")
                self.view.bringSubviewToFront(self.tagsOnOffButton)
                self.backgroundImage.alpha = self.tagsOn ? 0.8 : 1
                self.view.bringSubviewToFront(self.showRouteButton)
            })
        })
    }
    
    
    
    func optimizeHexagonWidth() {
        let screenWidth = self.view.bounds.width
        println(screenWidth)
        var x: CGFloat = 0
        var currentWidth: CGFloat = width
        var firstHexagon = true
        var numberOfFullHexagones: CGFloat = 0
        var numberOfHalfHexagones: CGFloat = 0
        while (x + currentWidth) <= screenWidth {
            x += currentWidth
            if firstHexagon {
                numberOfFullHexagones++
            } else {
                numberOfHalfHexagones++
            }
            firstHexagon = !firstHexagon
            currentWidth = firstHexagon ? width : R
        }
        if firstHexagon {
            numberOfFullHexagones++
        }
        var radius = screenWidth / (2 * numberOfFullHexagones + numberOfHalfHexagones)
        initHexagonWithRadius(radius)
    }
    
    
    
    override func viewWillLayoutSubviews() {
        if deviceOrientation == nil {
            return
        }
        let previousOrientation = deviceOrientation
        deviceOrientation = UIDevice.currentDevice().orientation
        if previousOrientation == deviceOrientation {
            return
        }
        let maxX = self.view.frame.width
        let maxY = self.view.frame.height
        var firstLine = true
        var x: CGFloat = 0
        var y: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
        var index: Int = 0
        while trunc(y + height) <= maxY {
            while trunc(x + width) <= maxX {
                if index >= buttons.count {
                    return
                }
                buttons[index]!.frame.origin = CGPoint(x: x, y: y)
                x += width + R
                ++index
            }
            firstLine = !firstLine
            if firstLine {
                x = 0
            } else {
                x = width - xStep
            }
            y += r
        }
        var frame = self.view.bounds
        frame.origin.x = 50
        frame.origin.y = 50
        artContent!.updateToFrame(frame)
    }
    
    
    
    func initHexagonWithRadius(radius: CGFloat) {
        R = radius
        width = 2 * R
        r = 0.86603 * R
        height = 2 * r
        xStep = 0.5 * R
    }
    
    
    
    func buttonPressed(button: HexaButton) {
        if button.image == nil {
            button.setMainImage(UIImage(named: "user.jpg"))
        } else {
            let title = NSLocalizedString("Alert", comment:"Alert")
            let message = NSLocalizedString("You pressed button #\(button.index)", comment:"This function is only available on the iPhone")
            let alertDialog: UIAlertView! = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: NSLocalizedString("OK", comment:"Cancel"))
            alertDialog.show();
        }
    }
    
    
    
    func getEffect(keyPath: String, _ type: UIInterpolatingMotionEffectType, _ minValue: Float, _ maxValue: Float) -> UIMotionEffect {
        let effect = UIInterpolatingMotionEffect(keyPath: keyPath, type: type)
        effect.minimumRelativeValue = minValue
        effect.maximumRelativeValue = maxValue
        return effect;
    }

    
    
    @IBAction func tagsOnOffButtonPressed(sender: UIButton) {
        HexaButton.hideAllButtons(tagsOn)
        tagsOn = !tagsOn
        let alpha: CGFloat = tagsOn ? 0.8 : 1
        UIView.animateWithDuration(0.2, animations: { self.backgroundImage.alpha = alpha })
        sender.setTitle(tagsOn ? "tags on" : "tags off", forState: UIControlState.Normal)
    }
}


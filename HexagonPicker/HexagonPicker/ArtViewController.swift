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


class ArtViewController: UIViewController, UIScrollViewDelegate {
    var homeViewController: UIViewController?
    
    let queue = dispatch_queue_create("com.vaisoft.hexagonpicker", nil)
    
    var delegate: ArtViewControllerDelegate!
    
    let motionManager = CMMotionManager()
#if iOS8Delta
    var artContent: ArtContentView?
#else
    var artContent: ArtContentImageView?
#endif
    var visualEffectView: UIVisualEffectView?
    
    let maxXMovement: CGFloat = 10
    let maxYMovement: CGFloat = 10
    let minMotion: Double = 0.005
    var prevGX: Double?
    var prevGY: Double?
    var frameBase: CGRect?
    
    var tagsOn = true
    var artContentDisplayed = false

    var scrollView: UIScrollView?
    var art: Art?
    var backgroundImageView: UIImageView?
    var screenshotView: UIImageView?
    var screenshot: UIImage?
    
    let buttonWidth: CGFloat = 100
    let buttonHeight: CGFloat = 40
    let buttonPadding: CGFloat = 20
    var tagsOnOffButton: UIButton?
    var showRouteButton: UIButton?
    
    var screenSize: CGRect?
    var statusBarHeight: CGFloat?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let statusBarFrame = UIApplication.sharedApplication().statusBarFrame
        statusBarHeight = statusBarFrame.height < statusBarFrame.width ? statusBarFrame.height : statusBarFrame.width
        self.view.backgroundColor = UIColor(red: 15 / 255, green: 108 / 255, blue: 74 / 255, alpha: 1)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged", name: ORIENTATION_CHANGED_NOTIFICATION, object: nil)
        screenSize = self.view.bounds
        updateScreenSize()
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
        fillViewWithButtons()
        
        var mask = UIImage(named: "hexagon_100.png")!
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        mask.drawInRect(CGRectMake(0, 0, width, height))
        var newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        maskImage = newImage
        
        initScrollView()
        
        initbackgroundImageView()
        
        setupScrollViewWithArt()
        
        initMotions()

        initButtons()
    }
    
    
    
    func getScrollViewHeight() -> CGRect {
        var frame = screenSize!
        frame.origin.y = statusBarHeight!
        frame.size.height -= statusBarHeight!
        return frame
    }
    
    
    
    func initScrollView() {
        scrollView = UIScrollView(frame: getScrollViewHeight())
        scrollView!.delegate = self
        self.view.addSubview(scrollView!)
    }
    
    
    
    func setupScrollViewWithArt() {
        let imageSize = art!.image!.size
        scrollView!.contentSize = imageSize
        var scrollViewFrame = scrollView!.frame
        let scaleWidth = scrollViewFrame.width / imageSize.width
        let scaleHeight = scrollViewFrame.height / imageSize.height
        let minScale = min(scaleWidth, scaleHeight)
        scrollView!.minimumZoomScale = minScale
        scrollView!.maximumZoomScale = 1.0
        scrollView!.zoomScale = minScale
        frameBase = backgroundImageView!.frame
        centerScrollViewContent()
    }
    
    
    
    func updateScrollView() {
        scrollView!.frame = getScrollViewHeight()
        let imageSize = art!.image!.size
        var scrollViewFrame = scrollView!.frame
        let scaleWidth = scrollViewFrame.width / imageSize.width
        let scaleHeight = scrollViewFrame.height / imageSize.height
        let minScale = min(scaleWidth, scaleHeight)
        scrollView!.minimumZoomScale = minScale
        scrollView!.maximumZoomScale = 1.0
        if scrollView!.zoomScale < minScale {
            scrollView!.zoomScale = minScale
        }
        centerScrollViewContent()
    }
    
    
    
    func centerScrollViewContent() {
        let boundsSize = scrollView!.bounds.size
        var contentsFrame = backgroundImageView!.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        backgroundImageView!.frame = contentsFrame
        frameBase = backgroundImageView!.frame
    }
    
    
    
    func initbackgroundImageView() {
        //backgroundImageView = UIImageView(frame: getFrameForbackgroundImageView())
        let imageSize = art!.image!.size
        backgroundImageView = UIImageView(frame: CGRect(origin: CGPoint(), size: imageSize))
        
        backgroundImageView!.image = art!.image
        frameBase = backgroundImageView!.frame
        
        let singleTap = UITapGestureRecognizer(target: self, action: "tapDetected")
        singleTap.numberOfTapsRequired = 1
        backgroundImageView!.userInteractionEnabled = true
        backgroundImageView!.addGestureRecognizer(singleTap)
        //self.view.addSubview(backgroundImageView!)
        scrollView!.addSubview(backgroundImageView!)
    }
    
    
    
    func updateScreenSize() -> Bool {
        let deviceOrientationPortrait =  ((deviceOrientation == UIDeviceOrientation.Portrait) || (deviceOrientation == UIDeviceOrientation.PortraitUpsideDown)) ? true : false
        let minSize = screenSize!.size.width < screenSize!.height ? screenSize!.size.width : screenSize!.height
        let maxSize = screenSize!.size.width > screenSize!.height ? screenSize!.size.width : screenSize!.height
        if deviceOrientationPortrait {
            if minSize == screenSize!.size.width {
                return false
            }
            screenSize!.size = CGSize(width: minSize, height: maxSize)
        } else {
            if maxSize == screenSize!.size.width {
                return false
            }
            screenSize!.size = CGSize(width: maxSize, height: minSize)
        }
        return true
    }
    
    
    
    func initButtons() {
        var screenFrame = screenSize!
        var buttonFrame = CGRect(x: buttonPadding, y: screenFrame.height - buttonHeight - buttonPadding, width: buttonWidth, height: buttonHeight)
        tagsOnOffButton = UIButton(frame: buttonFrame)
        initButton(&tagsOnOffButton!, tagsOn ? "tags off" : "tags on", "tagsOnOffButtonPressed:")
        buttonFrame = CGRect(x: screenFrame.width - buttonWidth - buttonPadding, y: screenFrame.height - buttonHeight - buttonPadding, width: buttonWidth, height: buttonHeight)
        showRouteButton = UIButton(frame: buttonFrame)
        initButton(&showRouteButton!, "show route", "showRouteButtonPressed:")
    }
    
    
    
    func updateButtons() {
        var screenFrame = screenSize!
        tagsOnOffButton!.frame = CGRect(x: buttonPadding, y: screenFrame.height - buttonHeight - buttonPadding, width: buttonWidth, height: buttonHeight)
        showRouteButton!.frame = CGRect(x: screenFrame.width - buttonWidth - buttonPadding, y: screenFrame.height - buttonHeight - buttonPadding, width: buttonWidth, height: buttonHeight)
    }
    
    
    
    func initButton(inout button: UIButton, _ title: String, _ selector: Selector) {
        button.setTitle(title, forState: UIControlState.Normal)
        button.backgroundColor = UIColor.blackColor()
        button.alpha = 0.7
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        button.addTarget(self, action: selector, forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
    }
    
    
    
    func getFrameForbackgroundImageView() -> CGRect {
        var frame = screenSize!
        frame.origin.x = -maxXMovement
        frame.origin.y = -maxYMovement
        frame.size.width += 2 * maxXMovement
        frame.size.height += 2 * maxYMovement
        return frame
    }
    
    
    
    func tapDetected() {
        if tagsOn {
            return
        }
        if !artContentDisplayed {
            initContentView()
        }
        artContentDisplayed = !artContentDisplayed
        artContent!.show(artContentDisplayed)
        let alpha: CGFloat = artContentDisplayed ? 0 : 0.8
        UIView.animateWithDuration(0.2, animations: { self.tagsOnOffButton!.alpha = alpha })
        UIView.animateWithDuration(0.2, animations: { self.showRouteButton!.alpha = alpha })
//        if artContentDisplayed {
//            motionManager.stopAccelerometerUpdates()
//        } else {
//            initMotions()
//        }
    }

    
    
    override func viewDidAppear(animated: Bool) {
        //deviceOrientation = UIDevice.currentDevice().orientation
        //initContentView()
    }
    
    
    
    func initContentView() {
        createScreenshot()
        #if iOS8Delta
            artContent = ArtContentView(screenshotView!, screenshotView!.frame, artContentDisplayed)
            #else
            artContent = ArtContentImageView(screenshot!, view.bounds, artContentDisplayed, view)
        #endif
        artContent!.addDescription("Currently On Display Currently On Display Currently On Display Currently On Display")
        for _ in 0...Int(arc4random_uniform(4)) {
            #if iOS8Delta
                artContent!.addButton(ArtContentView.CONTENT_ID)
                #else
                artContent!.addButton(ArtContentImageView.CONTENT_ID)
            #endif
        }
        
    }
    
    
    
    func createScreenshot() {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, true, 1)
        self.view.drawViewHierarchyInRect(self.view.bounds, afterScreenUpdates: true)
        screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        #if iOS8Delta
            screenshotView = UIImageView(image: screenshot)
            self.view.addSubview(screenshotView!)
        #endif
    }
    
    
    
    func showRouteButtonPressed(sender: UIButton) {
        if delegate == nil {
            let mapViewController = GMapViewController()
            mapViewController.homeViewController = self
            mapViewController.artForRoute = art
            if iOS8Delta {
                showViewController(mapViewController, sender: self)
            } else {
                presentViewController(mapViewController, animated: true, completion: nil)
            }
        } else {
            delegate.dismissArtViewController()
        }
    }
    
    
    
    func dismissMap() {
        self.dismissViewControllerAnimated(true, completion: {
            if self.homeViewController != nil {
                (self.homeViewController as ArtFeedViewController).dismissArtViewController()
            }
        })
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
            backgroundImageView!.frame.origin.x = frameBase!.origin.x + CGFloat(gX) * maxXMovement
            prevGX = gX
        }
        if prevGY == nil || fabs(prevGY! - gY) >= minMotion {
            backgroundImageView!.frame.origin.y = frameBase!.origin.y + CGFloat(gY) * maxYMovement
            prevGY = gY
        }
    }

    
    
    
    func initParallaxEffect() {
        var motionGroup = UIMotionEffectGroup()
        motionGroup.motionEffects = [getEffect("center.x", UIInterpolatingMotionEffectType.TiltAlongHorizontalAxis, -55, 55),
            getEffect("center.y", UIInterpolatingMotionEffectType.TiltAlongVerticalAxis, -55, 55)]
        backgroundImageView!.addMotionEffect(motionGroup)
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
            let screenSize = self.screenSize!
            let maxX = screenSize.width
            let maxY = screenSize.height
            var firstLine = true
            var x: CGFloat = 0
            var y: CGFloat = self.statusBarHeight!
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
                self.view.bringSubviewToFront(self.tagsOnOffButton!)
                UIView.animateWithDuration(0.2, animations: { self.backgroundImageView!.alpha = self.tagsOn ? 0.6 : 1 })
                self.view.bringSubviewToFront(self.showRouteButton!)
            })
        })
    }
    
    
    
    func optimizeHexagonWidth() {
        let screenWidth = screenSize!.width
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
    
    
    
    func orientationChanged() {
        if !updateScreenSize() {
            return
        }

        //backgroundImageView!.frame = getFrameForbackgroundImageView()
        updateScrollView()
        updateButtons()
        if artContent != nil {
            artContent!.updateToFrame(screenSize!)
        }
        let maxX = screenSize!.width
        let maxY = screenSize!.height
        var firstLine = true
        var x: CGFloat = 0
        var y: CGFloat = statusBarHeight!
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

    
    
    func tagsOnOffButtonPressed(sender: UIButton) {
        HexaButton.hideAllButtons(tagsOn)
        tagsOn = !tagsOn
        let alpha: CGFloat = tagsOn ? 0.8 : 1
        UIView.animateWithDuration(0.2, animations: { self.backgroundImageView!.alpha = alpha })
        sender.setTitle(tagsOn ? "tags off" : "tags on", forState: UIControlState.Normal)
        if tagsOn {
            initMotions()
        } else {
            motionManager.stopAccelerometerUpdates()
            backgroundImageView!.frame.origin.x = frameBase!.origin.x
            backgroundImageView!.frame.origin.y = frameBase!.origin.y
        }
    }
    
    
    
    func viewForZoomingInScrollView(scrollView: UIScrollView!) -> UIView! {
        return backgroundImageView
    }

    
    
    func scrollViewDidZoom(scrollView: UIScrollView!) {
        centerScrollViewContent()
    }

}


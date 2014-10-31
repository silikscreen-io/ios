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
    var artContentView: UIView?
    var artShareView: UIView?
    var artShareMenuView: ArtShareMenuView?
    
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
    let buttonPadding: CGFloat = 10
    var tagsOnOffButton: UIButton?
    var showRouteButton: UIButton?
    var shareButton: UIButton?
    var backButton: UIButton?
    
    var screenSize: CGRect?
    
    var homeToolbar: UIToolbar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged", name: ORIENTATION_CHANGED_NOTIFICATION, object: nil)
        screenSize = self.view.bounds
        println("before: \(screenSize)")
        //updateScreenSize()
        println("after: \(screenSize)")
        fillViewWithButtons()
        
        var mask = UIImage(named: "hexagon_100.png")!
        UIGraphicsBeginImageContext(CGSize(width: gWidth, height: gHeight))
        mask.drawInRect(CGRectMake(0, 0, gWidth, gHeight))
        var newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        maskImage = newImage
        
        initScrollView()
        
        initbackgroundImageView()
        
        setupScrollViewWithArt()
        
        initMotions()

        initButtons()
        
        artShareMenuView = ArtShareMenuView(self.view)
        
        //initNavigationBar()
    }
    
    
    
    func initNavigationBar() {
        var frame = screenSize!
        frame.origin.y = frame.height - 300
        frame.size.height = 300
        homeToolbar = UIToolbar()
        homeToolbar!.frame = frame
        //homeToolbar!.barStyle = UIBarStyle.Black
        //homeToolbar!.alpha = 0.7
        var button = UIButton(frame: CGRect(x: 20, y: 20, width: 100, height: 100))
        button.setImage(UIImage(named: "ann.jpg"), forState: UIControlState.Normal)
        button.setImage(UIImage(named: "gal.jpg"), forState: UIControlState.Highlighted)
        homeToolbar.addSubview(button)
        self.view.addSubview(homeToolbar!)
    }
    
    
    
    func initScrollView() {
        scrollView = UIScrollView(frame: screenSize!)
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
        scrollView!.frame = screenSize!
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
        let deviceOrientationPortrait = ((deviceOrientation! == UIDeviceOrientation.Portrait) || (deviceOrientation! == UIDeviceOrientation.PortraitUpsideDown)) ? true : false
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
        buttonFrame = CGRect(x: (screenFrame.width - buttonWidth) / 2, y: screenFrame.height - buttonHeight - buttonPadding, width: buttonWidth, height: buttonHeight)
        shareButton = UIButton(frame: buttonFrame)
        initButton(&shareButton!, "share", "shareButtonPressed:")
        buttonFrame = CGRect(x: buttonPadding, y: buttonPadding, width: buttonWidth / 2, height: buttonHeight)
        backButton = UIButton(frame: buttonFrame)
        initButton(&backButton!, "back", "backButtonPressed:")
    }
    
    
    
    func updateButtons() {
        var screenFrame = screenSize!
        tagsOnOffButton!.frame = CGRect(x: buttonPadding, y: screenFrame.height - buttonHeight - buttonPadding, width: buttonWidth, height: buttonHeight)
        showRouteButton!.frame = CGRect(x: screenFrame.width - buttonWidth - buttonPadding, y: screenFrame.height - buttonHeight - buttonPadding, width: buttonWidth, height: buttonHeight)
        shareButton!.frame = CGRect(x: (screenFrame.width - buttonWidth) / 2, y: screenFrame.height - buttonHeight - buttonPadding, width: buttonWidth, height: buttonHeight)
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
//        artContentView!.show(artContentDisplayed)
        if iOS8Delta {
            (artContentView! as ArtContentView).show(artContentDisplayed)
        } else {
            (artContentView! as ArtContentImageView).show(artContentDisplayed)
        }
        let alpha: CGFloat = artContentDisplayed ? 0 : 0.8
        UIView.animateWithDuration(0.2, animations: { self.tagsOnOffButton!.alpha = alpha })
        UIView.animateWithDuration(0.2, animations: { self.showRouteButton!.alpha = alpha })
    }
    
    
    
    func initContentView() {
        createScreenshot()
        if iOS8Delta {
//            let artContentView = ArtContentView(screenshotView!, screenshotView!.frame, artContentDisplayed)
            let artContentView = ArtContentView(self.view, screenshotView!.frame, artContentDisplayed)
            artContentView.addDescription("Currently On Display Currently On Display Currently On Display Currently On Display")
            for _ in 0...Int(arc4random_uniform(4)) {
                artContentView.addButton(ArtContentView.CONTENT_ID)
            }
            self.artContentView = artContentView
        } else {
            let artContentView = ArtContentImageView(screenshot!, view.bounds, artContentDisplayed, view)
            artContentView.addDescription("Currently On Display Currently On Display Currently On Display Currently On Display")
            for _ in 0...Int(arc4random_uniform(4)) {
                artContentView.addButton(ArtContentImageView.CONTENT_ID)
            }
            self.artContentView = artContentView
        }
    }
    
    
    
    func createScreenshot() {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, true, 1)
        self.view.drawViewHierarchyInRect(self.view.bounds, afterScreenUpdates: true)
        screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if iOS8Delta {
            screenshotView = UIImageView(image: screenshot)
            self.view.addSubview(screenshotView!)
        }
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
    
    
    
    func shareButtonPressed(sender: UIButton) {
        artShareMenuView!.show()
    }
    
    
    
    func backButtonPressed(sender: UIButton) {
        if homeViewController!.isMemberOfClass(GMapViewController.self) {
            (homeViewController as GMapViewController).dismissArtViewControllerWithowtShowingRout()
        } else if homeViewController!.isMemberOfClass(ArtFeedViewController.self) {
            (homeViewController as ArtFeedViewController).dismissArtViewController()
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
            var y: CGFloat = 0
            while trunc(y + gHeight) <= maxY {
                while trunc(x + gWidth) <= maxX {
                    HexaButton.addButton(x, y: y, target: self, action: "buttonPressed:", view: self.view)
                    x += gWidth + gBigRadius
                }
                firstLine = !firstLine
                if firstLine {
                    x = 0
                } else {
                    x = gWidth - gXStep
                }
                y += gSmallRadiusr
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.fillButtonWithImage("ann.jpg")
                self.fillButtonWithImage("gal.jpg")
                self.fillButtonWithImage("rah.jpg")
                self.fillButtonWithImage("ste.jpg")
                self.view.bringSubviewToFront(self.tagsOnOffButton!)
                UIView.animateWithDuration(0.2, animations: { self.backgroundImageView!.alpha = self.tagsOn ? 0.6 : 1 })
                self.view.bringSubviewToFront(self.showRouteButton!)
                self.view.bringSubviewToFront(self.shareButton!)
                self.view.bringSubviewToFront(self.artShareMenuView!)
                self.view.bringSubviewToFront(self.backButton!)
                //self.view.bringSubviewToFront(self.homeToolbar!)
            })
        })
    }
    
    
    
    func optimizeHexagonWidth() {
        let screenWidth = screenSize!.width
        //println(screenWidth)
        var x: CGFloat = 0
        var currentWidth: CGFloat = gWidth
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
            currentWidth = firstHexagon ? gWidth : gBigRadius
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
        if artContentView != nil {
//            artContentView!.updateToFrame(screenSize!)
            if iOS8Delta {
                (artContentView! as ArtContentView).updateToFrame(screenSize!)
            } else {
                (artContentView! as ArtContentImageView).updateToFrame(screenSize!)
            }
        }
        artShareMenuView!.update(screenSize!)
        let maxX = screenSize!.width
        let maxY = screenSize!.height
        var firstLine = true
        var x: CGFloat = 0
        var y: CGFloat = 0
        var index: Int = 0
        while trunc(y + gHeight) <= maxY {
            while trunc(x + gWidth) <= maxX {
                if index >= buttons.count {
                    return
                }
                buttons[index]!.frame.origin = CGPoint(x: x, y: y)
                x += gWidth + gBigRadius
                ++index
            }
            firstLine = !firstLine
            if firstLine {
                x = 0
            } else {
                x = gWidth - gXStep
            }
            y += gSmallRadiusr
        }
    }
    
    
    
    func initHexagonWithRadius(radius: CGFloat) {
        gBigRadius = 18
        gWidth = 2 * gBigRadius
        gSmallRadiusr = 0.86603 * gBigRadius
        gHeight = 2 * gSmallRadiusr
        gXStep = 0.5 * gBigRadius
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
    
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}


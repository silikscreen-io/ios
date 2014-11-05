//
//  ArtFeedViewController.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 23.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

var deviceOrientation: UIDeviceOrientation?
let ORIENTATION_CHANGED_NOTIFICATION = "orientationChangedNotification"
var YYY: CGFloat = 10

class ArtFeedViewController: UIViewController, GMapViewControllerDelegate, UIScrollViewDelegate, ArtDelegate {
    let SHOW_ART_FROM_FEED_SEGUE_ID = "showArtFromFeedSegue"
    
    var images: [UIImage] = []
    var artViews: [ArtView] = []
    
    let SHOW_MAP_SEGUE_ID = "showMapSegue"

    var scrollView: UIScrollView!
    var contentOffset: CGPoint?
    var scrollingStarted = false
    var upSwipeRecognizer: UISwipeGestureRecognizer?
    var downSwipeRecognizer: UISwipeGestureRecognizer?
    
    
    let buttonsToolbarHeight: CGFloat = 48
    var buttonsBarDisplayed = true
    var homeToolbar: UIToolbar!
    var homeToolbarImageView: UIImageView!
    var homeToolbarItems: [UIBarItem]!
    
    var buttonsToolbarView: UIView?
    var buttonHome: UIButton?
    var buttonSearch: UIButton?
    var buttonMap: UIButton?
    var buttonUser: UIButton?
    
    var tappedArt: Art?
    
    var screenSize: CGRect?
    var deviceOrientationLandscape = false
    
    var artistTopButtonPrevious: HexaButton?
    var artistTopButton: HexaButton?
    var artistTopButtonNext: HexaButton?
    var artTopButtonIndex = 0
    
    var artIndexFirstDisplayed = 0
    var artIndexTopDisplayed = 0
    var artIndexFirst = 0
    
    var firstLayout = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "imageForArtLoaded:", name: IMAGE_FOR_ART_LOADED_NOTIFICATION_ID, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "imageForArtReloaded:", name: IMAGE_FOR_ART_RELOADED_NOTIFICATION_ID, object: nil)
    }
    
    
    
    override func viewWillLayoutSubviews() {
        if !firstLayout {
            return
        }
        firstLayout = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationDidChange:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        screenSize = self.view.bounds
        deviceOrientationLandscape = screenSize?.width > screenSize?.height
        //updateScreenSize()
        initFeed()
        initScrollView()
        initNavigationBar()
        scrollView.delegate = self
    }
    
    
    
    func deviceOrientationDidChange(notification: NSNotification) {
        let orientation = UIDevice.currentDevice().orientation
        
        if orientation == UIDeviceOrientation.PortraitUpsideDown || orientation == UIDeviceOrientation.FaceUp || orientation == UIDeviceOrientation.FaceDown || orientation == UIDeviceOrientation.Unknown || deviceOrientation == orientation || deviceOrientation == nil {
            let devOrientation =  ((deviceOrientation! == UIDeviceOrientation.Portrait) || (deviceOrientation! == UIDeviceOrientation.PortraitUpsideDown)) ? "Portrait" : "Landscape"
            println("deviceOrientationChanged: " + devOrientation)
            deviceOrientation = orientation;
            return;
        }
        deviceOrientation = orientation;
        deviceOrientationLandscape = (deviceOrientation! != UIDeviceOrientation.Portrait) && (deviceOrientation! != UIDeviceOrientation.PortraitUpsideDown)
        let devOrientation =  ((deviceOrientation! == UIDeviceOrientation.Portrait) || (deviceOrientation! == UIDeviceOrientation.PortraitUpsideDown)) ? "Portrait" : "Landscape"
        println("deviceOrientationChanged: " + devOrientation)
        NSNotificationCenter.defaultCenter().postNotificationName(ORIENTATION_CHANGED_NOTIFICATION, object: nil)
        updateView()
    }
    
    
    
    func updateView() {
        if !updateScreenSize() {
            return
        }
//        updateScrollView()
        updateScrollView1()
        updateNavigationBar()
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
    
    
    
    func showButtonsBar() {
        if deviceOrientationLandscape {
            if !buttonsBarDisplayed {
                buttonsBarDisplayed = true
                let buttonsToolbarX = self.buttonsToolbarView!.frame.origin.x
                var newX = buttonsToolbarX - self.buttonsToolbarHeight
                UIView.animateWithDuration(0.3, animations: {
                    self.buttonsToolbarView!.frame.origin.x = newX
                })
                let homeToolbarX = self.homeToolbar!.frame.origin.x
                newX = homeToolbarX + self.buttonsToolbarHeight / 2
                UIView.animateWithDuration(0.3, animations: {
                    self.homeToolbar!.frame.origin.x = newX
                })
            }
        } else {
            if !buttonsBarDisplayed {
                buttonsBarDisplayed = true
                let buttonsToolbarY = self.buttonsToolbarView!.frame.origin.y
                var newY = buttonsToolbarY - self.buttonsToolbarHeight
                UIView.animateWithDuration(0.3, animations: {
                    self.buttonsToolbarView!.frame.origin.y = newY
                })
                let homeToolbarY = self.homeToolbar!.frame.origin.y
                newY = homeToolbarY + self.buttonsToolbarHeight / 2
                UIView.animateWithDuration(0.3, animations: {
                    self.homeToolbar!.frame.origin.y = newY
                })
            }
        }
    }
    
    
    
    func swipeUp() {
        if buttonsBarDisplayed {
            buttonsBarDisplayed = false
            //            var frame = buttonsToolbarView!.frame
            let buttonsToolbarY = self.buttonsToolbarView!.frame.origin.y
            var newY = buttonsToolbarY + self.buttonsToolbarHeight
            UIView.animateWithDuration(0.3, animations: {
                self.buttonsToolbarView!.frame.origin.y = newY
            })
            let homeToolbarY = self.homeToolbar!.frame.origin.y
            newY = homeToolbarY - self.buttonsToolbarHeight / 2
            UIView.animateWithDuration(0.3, animations: {
                self.homeToolbar!.frame.origin.y = newY
            })
        }
    }
    
    
    
    func initFeed() {
        for index in 1...6 {
            images.append(UIImage(named: "Picture\(index).jpg")!)
        }
    }
    
    
    
    func initScrollView() {
        scrollView = UIScrollView()
        fillScrollView()
        self.view.addSubview(scrollView)
        contentOffset = scrollView!.contentOffset
        if artistTopButton != nil {
            view.bringSubviewToFront(artistTopButton!)
        }
    }
    
    
    
    func updateScrollView() {
        artViews.removeAll(keepCapacity: false)
        scrollView!.subviews.map{ $0.removeFromSuperview() }
        fillScrollView()
        view.bringSubviewToFront(artistTopButton!)
    }
    
    
    
    func updateScrollView1() {
        let contentOffset = scrollView.contentOffset
//        println(scrollView.contentOffset)
//        if artistTopButton != nil {
//            artistTopButton!.removeFromSuperview()
//            artistTopButton = nil
//            artTopButtonIndex = 0
//        }
        var frame = screenSize!
        scrollView!.frame = frame
        let screenWidth = frame.width
        let screenHeigth = frame.height
        var scrollViewLength: CGFloat = 0
        frame = CGRect()
        for artView in artViews {
            artView.resize(scrollViewLength, screenWidth, screenHeigth, deviceOrientationLandscape)
            scrollViewLength += (deviceOrientationLandscape ? artView.frame.width : artView.frame.height)
//            if artistTopButton == nil {
//                artistTopButton = artView.artistButton
//                artistTopButton!.removeFromSuperview()
//                view.addSubview(artistTopButton!)
//            } else if artistTopButtonNext == nil {
//                artistTopButtonNext = artView.artistButton
//            }
        }
        scrollView.contentSize = (deviceOrientationLandscape ? CGSize(width: scrollViewLength, height: screenHeigth) : CGSize(width: screenWidth, height: scrollViewLength))
        let artView = artViews[artIndexTopDisplayed]
        let rect = scrollView.convertRect(artView.frame, toView: view)
        //println(rect)
        scrollView.setContentOffset(rect.origin, animated: false)//CGPoint(x: contentOffset.y, y: contentOffset.x)
    }
    
    
    
    func fillScrollView() {
        if artistTopButton != nil {
            artistTopButton!.removeFromSuperview()
            artistTopButton = nil
            artTopButtonIndex = 0
        }
        var frame = screenSize!
        scrollView!.frame = frame
        let screenWidth = frame.width
        let screenHeigth = frame.height
        var scrollViewLength: CGFloat = 0
        frame = CGRect()
        for art in artsDisplayed {
            let artView = ArtView(art, scrollViewLength, screenWidth, screenHeigth, self, deviceOrientationLandscape)
            scrollView.addSubview(artView)
            scrollViewLength += (deviceOrientationLandscape ? artView.frame.width : artView.frame.height)
            art.delegate = self
            artViews.append(artView)
            if artistTopButton == nil {
                artistTopButton = artView.artistButton
                artistTopButton!.removeFromSuperview()
                view.addSubview(artistTopButton!)
            } else if artistTopButtonNext == nil {
                artistTopButtonNext = artView.artistButton
            }
        }
        scrollView.contentSize = (deviceOrientationLandscape ? CGSize(width: scrollViewLength, height: screenHeigth) : CGSize(width: screenWidth, height: scrollViewLength))
    }
    
    
    
    func imageForArtLoaded(notification: NSNotification) {
        let notificationDictionary = (notification.userInfo! as NSDictionary)
        let loadedForFeed = (notificationDictionary.objectForKey("loadedForFeed") as NSNumber).boolValue
        if !loadedForFeed {
            return
        }
        let art = notificationDictionary.objectForKey("art") as Art
        let artView = notificationDictionary.objectForKey("artView") as? ArtView
        
        
//        let imageViewTest = UIImageView(image: art.image)
//        imageViewTest.frame = CGRect(x: 30, y: YYY, width: 100, height: 100)
//        YYY += 30
//        view.addSubview(imageViewTest)
//        dispatch_async(dispatch_get_main_queue(), {
//            let imageViewTest = UIImageView(image: art.image)
//            imageViewTest.frame = CGRect(x: 30, y: YYY, width: 100, height: 100)
//            YYY += 30
//            self.view.addSubview(imageViewTest)
//        })

        if artView != nil {
            //println("View update started")
            artView!.update(art, deviceOrientationLandscape)
            //println("View updated")
        } else {
            var frame = screenSize!
            scrollView!.frame = frame
            let screenWidth = frame.width
            let screenHeigth = frame.height
            var scrollViewLength = deviceOrientationLandscape ? scrollView.contentSize.width : scrollView.contentSize.height
            frame = CGRect()
            let artView = ArtView(art, scrollViewLength, screenWidth, screenHeigth, self, deviceOrientationLandscape)
            scrollView.addSubview(artView)
            //println("Image added to scroll view")
            scrollViewLength += (deviceOrientationLandscape ? artView.frame.width : artView.frame.height)
            art.delegate = self
            artViews.append(artView)
            if artistTopButton == nil {
                artistTopButton = artView.artistButton
                artistTopButton!.removeFromSuperview()
                view.addSubview(artistTopButton!)
            } else if artistTopButtonNext == nil {
                artistTopButtonNext = artView.artistButton
            }
            //println("scrollView.contentSize \(scrollView.contentSize)")
            scrollView.contentSize = (deviceOrientationLandscape ? CGSize(width: scrollViewLength, height: screenHeigth) : CGSize(width: screenWidth, height: scrollViewLength))
        }
    }
    
    
    
    func imageForArtReloaded(notification: NSNotification) {
        let notificationDictionary = (notification.userInfo! as NSDictionary)
        let art = notificationDictionary.objectForKey("art") as Art
        let artView = notificationDictionary.objectForKey("artView") as ArtView
        var frame = screenSize!
        scrollView!.frame = frame
        let screenWidth = frame.width
        let screenHeigth = frame.height
        artView.update(art, deviceOrientationLandscape)
    }
    
    
    
    func artTapped(art: Art) {
        tappedArt = art
        performSegueWithIdentifier(SHOW_ART_FROM_FEED_SEGUE_ID, sender: self)
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SHOW_ART_FROM_FEED_SEGUE_ID {
            let artViewController = segue.destinationViewController as ArtViewController
            artViewController.homeViewController = self
            artViewController.art = tappedArt
        } else if segue.identifier == SHOW_MAP_SEGUE_ID {
            let mapViewController = segue.destinationViewController as GMapViewController
            mapViewController.delegate = self
        }
    }
    
    
    
    func updateNavigationBar() {
        var screenSize = self.screenSize!
        var frame = self.screenSize!
        var origin = frame.origin
        if deviceOrientationLandscape {
            if buttonsBarDisplayed {
                frame.origin.x = screenSize.width
                frame.size.width = buttonsToolbarHeight / 2
                homeToolbar!.frame = frame
                frame.origin.x = screenSize.width - buttonsToolbarHeight
                frame.size.width = buttonsToolbarHeight
                buttonsToolbarView!.frame = frame
            } else {
                frame.origin.x = frame.width - buttonsToolbarHeight / 2
                frame.size.width = buttonsToolbarHeight / 2
                homeToolbar!.frame = frame
                frame.origin.x = screenSize.width
                frame.size.width = buttonsToolbarHeight
                buttonsToolbarView!.frame = frame
            }
            //homeToolbarImageView.transform = CGAffineTransformMakeRotation(-90.0 / 180.0 * CGFloat(M_PI))
            //buttonsToolbarImageView.transform = CGAffineTransformMakeRotation(-90.0 / 180.0 * CGFloat(M_PI))
        } else {
            if buttonsBarDisplayed {
                frame.origin.y = screenSize.height
                frame.size.height = buttonsToolbarHeight / 2
                homeToolbar!.frame = frame
                frame.origin.y = screenSize.height - buttonsToolbarHeight
                frame.size.height = buttonsToolbarHeight
                buttonsToolbarView!.frame = frame
            } else {
                frame.origin.y = frame.height - buttonsToolbarHeight / 2
                frame.size.height = buttonsToolbarHeight / 2
                homeToolbar!.frame = frame
                frame.origin.y = screenSize.height
                frame.size.height = buttonsToolbarHeight
                buttonsToolbarView!.frame = frame
            }
            //homeToolbarImageView.transform = CGAffineTransformMakeRotation(0)
            //buttonsToolbarImageView.transform = CGAffineTransformMakeRotation(0)
        }
        updateNavigationBarButtons()
        view.bringSubviewToFront(buttonsToolbarView!)
        view.bringSubviewToFront(homeToolbar)
    }
    
    
    
    func updateNavigationBarButtons() {
        var stepX = screenSize!.width / 4
        var stepY: CGFloat = 0
        var buttonSize = CGSize(width: stepX, height: buttonsToolbarHeight)
        if deviceOrientationLandscape {
            stepX = 0
            stepY = screenSize!.height / 4
            buttonSize = CGSize(width: buttonsToolbarHeight, height: stepY)
        }
        var buttonPosition = CGPoint(x: 0, y: 0)
        buttonHome!.frame = CGRect(origin: buttonPosition, size: buttonSize)
        buttonPosition = CGPoint(x: buttonPosition.x + stepX, y: buttonPosition.y + stepY)
        buttonSearch!.frame = CGRect(origin: buttonPosition, size: buttonSize)
        buttonPosition = CGPoint(x: buttonPosition.x + stepX, y: buttonPosition.y + stepY)
        buttonMap!.frame = CGRect(origin: buttonPosition, size: buttonSize)
        buttonPosition = CGPoint(x: buttonPosition.x + stepX, y: buttonPosition.y + stepY)
        buttonUser!.frame = CGRect(origin: buttonPosition, size: buttonSize)
    }
    
    
    
    func initNavigationBar() {
        var screenSize = self.screenSize!
        var frame = self.screenSize!
        if deviceOrientationLandscape {
            frame.origin.x = screenSize.width
            frame.size.width = buttonsToolbarHeight / 2
            homeToolbar = UIToolbar()
            addToolbar(&homeToolbar, frame)
            initHomeToolbar()
            
            frame.origin.x = screenSize.width - buttonsToolbarHeight
            frame.size.width = buttonsToolbarHeight
            buttonsToolbarView = UIView()
            addToolbar(&buttonsToolbarView!, frame)
            initButtonsToolbar()
        } else {
            frame.origin.y = frame.height
            frame.size.height = buttonsToolbarHeight / 2
            homeToolbar = UIToolbar()
            addToolbar(&homeToolbar, frame)
            initHomeToolbar()
            
            frame.origin.y = screenSize.height - buttonsToolbarHeight
            frame.size.height += buttonsToolbarHeight / 2
            buttonsToolbarView = UIView()
            addToolbar(&buttonsToolbarView!, frame)
            initButtonsToolbar()
        }
    }
    
    
    
    func addToolbar(inout view: UIView, _ frame: CGRect) {
        view.frame = frame
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        self.view.addSubview(view)
    }
    
    
    
    func addToolbar(inout toolbar: UIToolbar!, _ frame: CGRect) {
        toolbar!.frame = frame
        toolbar!.barStyle = UIBarStyle.Black
        toolbar!.alpha = 0.7
        self.view.addSubview(toolbar!)
    }
    
    
    
    func getButtonForToolbar(inout imageView: UIImageView, _ action: Selector) -> UIButton {
        imageView.autoresizingMask = UIViewAutoresizing.None
        imageView.contentMode = UIViewContentMode.Center
        let button = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        button.frame = CGRectMake(0, 0, 30, 30);
        button.addSubview(imageView)
        button.addTarget(self, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        imageView.center = button.center
        return button
    }
    
    
    
    func initHomeToolbar() {
        let singleTap = UITapGestureRecognizer(target: self, action: "homeToolbarTapDetected")
        singleTap.numberOfTapsRequired = 1
        homeToolbar.userInteractionEnabled = true
        homeToolbar.addGestureRecognizer(singleTap)
    }
    
    
    
    func initButtonsToolbar() {
        buttonHome = UIButton()
        initButton(&buttonHome!, "homeButtonPressed", "hexagon")
        buttonSearch = UIButton()
        initButton(&buttonSearch!, "searchButtonPressed", "search")
        buttonMap = UIButton()
        initButton(&buttonMap!, "mapButtonPressed", "map")
        buttonUser = UIButton()
        initButton(&buttonUser!, "userButtonPressed", "user")
        updateNavigationBarButtons()
    }
    
    
    
    func initButton(inout button: UIButton, _ selector: Selector, _ imageName: String) {
        button.addTarget(self, action: selector, forControlEvents: UIControlEvents.TouchUpInside)
        button.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        buttonsToolbarView!.addSubview(button)
    }
    
    
    
    func homeButtonPressed() {
        
    }
    
    
    
    func searchButtonPressed() {
        
    }
    
    
    
    func mapButtonPressed() {
        performSegueWithIdentifier("showMapSegue", sender: self)
    }
    
    
    
    func userButtonPressed() {
        let userViewController = UserViewController()
        userViewController.homeViewController = self
        if iOS8Delta {
            showViewController(userViewController, sender: self)
        } else {
            presentViewController(userViewController, animated: true, completion: nil)
        }
    }
    
    
    
    func homeToolbarTapDetected() {
        showButtonsBar()
    }
    
    
    
    func mapButtonTapped() {
        performSegueWithIdentifier("showMapSegue", sender: self)
    }
    
    
    
    func dismissGMapViewController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    func dismissArtViewController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollingStarted = true
//        for artView in artViews {
//            artView.hideStatistic()
//        }
    }

    
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if deviceOrientationLandscape {
            if buttonsBarDisplayed {
                if screenSize!.width - homeToolbar.frame.origin.x >= homeToolbar.frame.width / 2 {
                    homeToolbar.frame.origin.x = screenSize!.width - homeToolbar.frame.width
                    buttonsToolbarView!.frame.origin.x = screenSize!.width
                    buttonsBarDisplayed = false
                } else {
                    buttonsToolbarView!.frame.origin.x = screenSize!.width - buttonsToolbarView!.frame.width
                    homeToolbar.frame.origin.x = screenSize!.width
                }
            }
        } else {
            if buttonsBarDisplayed {
                if screenSize!.height - homeToolbar.frame.origin.y >= homeToolbar.frame.height / 2 {
                    homeToolbar.frame.origin.y = screenSize!.height - homeToolbar.frame.height
                    buttonsToolbarView!.frame.origin.y = screenSize!.height
                    buttonsBarDisplayed = false
                } else {
                    buttonsToolbarView!.frame.origin.y = screenSize!.height - buttonsToolbarView!.frame.height
                    homeToolbar.frame.origin.y = screenSize!.height
                }
            }
        }
        scrollingStarted = false
//        if !decelerate {
//            for artView in artViews {
//                artView.showStatistic()
//            }
//        }
    }
    
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        for artView in artViews {
//            artView.showStatistic()
//        }
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
//        println(scrollView.contentOffset)
        if deviceOrientationLandscape {
            scrollViewDidScrollLandscape(scrollView)
        } else {
            scrollViewDidScrollPortrait(scrollView)
        }
        contentOffset = scrollView.contentOffset
    }
    
    
    
    func scrollViewDidScrollLandscape(scrollView: UIScrollView) {
        scrollViewDidScrollLandscapeArtistButton(scrollView)
        if !scrollingStarted {
            return
        }
        if buttonsBarDisplayed {
            let deltaX = scrollView.contentOffset.x - contentOffset!.x
            let scrolledDown = scrollView.contentOffset.x > contentOffset!.x
            if scrolledDown {
                buttonsToolbarView!.frame.origin.x += deltaX
                homeToolbar.frame.origin.x -= deltaX / 2
                if homeToolbar.frame.origin.x <= screenSize!.width - homeToolbar.frame.width {
                    homeToolbar.frame.origin.x = screenSize!.width - homeToolbar.frame.width
                    buttonsToolbarView!.frame.origin.x = screenSize!.width
                    buttonsBarDisplayed = false
                }
            } else {
                buttonsToolbarView!.frame.origin.x += deltaX
                homeToolbar.frame.origin.x -= deltaX / 2
                if buttonsToolbarView!.frame.origin.x <= screenSize!.width - buttonsToolbarView!.frame.width {
                    buttonsToolbarView!.frame.origin.x = screenSize!.width - buttonsToolbarView!.frame.width
                    homeToolbar.frame.origin.x = screenSize!.width
                }
            }
        } else {
            var speedX = scrollView.contentOffset.x - contentOffset!.x
            if speedX < -20 {
                showHomeToolbar()
                buttonsBarDisplayed = true
            }
        }
    }
    
    
    
    func scrollViewDidScrollPortrait(scrollView: UIScrollView) {
        scrollViewDidScrollPortraitArtistButton(scrollView)
        if !scrollingStarted {
            return
        }
        if buttonsBarDisplayed {
            let deltaY = scrollView.contentOffset.y - contentOffset!.y
            let scrolledDown = scrollView.contentOffset.y > contentOffset!.y
            if scrolledDown {
                buttonsToolbarView!.frame.origin.y += deltaY
                homeToolbar.frame.origin.y -= deltaY / 2
                if homeToolbar.frame.origin.y <= screenSize!.height - homeToolbar.frame.height {
                    homeToolbar.frame.origin.y = screenSize!.height - homeToolbar.frame.height
                    buttonsToolbarView!.frame.origin.y = screenSize!.height
                    buttonsBarDisplayed = false
                }
            } else {
                buttonsToolbarView!.frame.origin.y += deltaY
                homeToolbar.frame.origin.y -= deltaY / 2
                if buttonsToolbarView!.frame.origin.y <= screenSize!.height - buttonsToolbarView!.frame.height {
                    buttonsToolbarView!.frame.origin.y = screenSize!.height - buttonsToolbarView!.frame.height
                    homeToolbar.frame.origin.y = screenSize!.height
                }
            }
        } else {
            var speedY = scrollView.contentOffset.y - contentOffset!.y
            if speedY < -20 {
                showHomeToolbar()
                buttonsBarDisplayed = true
            }
        }
    }
    
    
    
    
    func updateDesplayedArts(newIndex: Int) {
        artIndexTopDisplayed += newIndex
        println("artIndexTopDisplayed: \(artIndexTopDisplayed)")
        if newIndex > 0 {
            if artIndexTopDisplayed > MAX_NUMBER_OF_LOADED_IMAGES / 2 {
                //artIndexTopDisplayed -= newIndex
                println("artIndexTopDisplayed: \(artIndexTopDisplayed)")
                let addArtIndex = artIndexFirst + MAX_NUMBER_OF_LOADED_IMAGES
                println("addArtIndex: \(addArtIndex)")
                println("artViews.count: \(artViews.count)")
                if artIndexFirst + MAX_NUMBER_OF_LOADED_IMAGES < arts.count {
                    let newDisplayedArt = arts[addArtIndex]
                    currentNumberOfLoadedImages--
                    var artView: ArtView?
                    if artIndexTopDisplayed + MAX_NUMBER_OF_LOADED_IMAGES / 2 - newIndex < artViews.count {
                        artView = artViews[artIndexTopDisplayed + MAX_NUMBER_OF_LOADED_IMAGES / 2 - newIndex]
                    }
                    newDisplayedArt.loadImage(artView)
                    clearImage(artIndexTopDisplayed - MAX_NUMBER_OF_LOADED_IMAGES / 2 - newIndex)
                    artIndexFirst += newIndex
                }
            }
        } else {
            if artIndexTopDisplayed - MAX_NUMBER_OF_LOADED_IMAGES / 2 < 0 {
                artIndexTopDisplayed = 0
                return
            }
            artIndexFirst += newIndex
            println("artToReloadImageView: \(artIndexTopDisplayed - MAX_NUMBER_OF_LOADED_IMAGES / 2)")
            let newDisplayedArtView = artViews[artIndexTopDisplayed - MAX_NUMBER_OF_LOADED_IMAGES / 2]
            newDisplayedArtView.art!.reloadImage(newDisplayedArtView)
            clearImage(artIndexTopDisplayed + MAX_NUMBER_OF_LOADED_IMAGES / 2)
        }
        println(artIndexTopDisplayed)
    }
    
    
    
    func clearImage(index: Int) {
        println("artViews.count: \(artViews.count)")
        println("artToDeleteImageView: \(index)")
        var artToDeleteImageView = artViews[index]
        artToDeleteImageView.art!.image = nil
        artToDeleteImageView.image = nil
        artsDisplayed.removeAtIndex(find(artsDisplayed, artToDeleteImageView.art!)!)
    }
    
    
    
    func scrollViewDidScrollPortraitArtistButton(scrollView: UIScrollView) {
        let scrolledDown = scrollView.contentOffset.y > contentOffset!.y
        if scrolledDown {
            let nextArt = artViews[artTopButtonIndex + 1]
            let rect = scrollView.convertRect(nextArt.frame, toView: view)
            if rect.origin.y <= nextArt.artistButton!.frame.height + nextArt.padding * 2 {
                //                println(rect.origin.y - nextArt.artistButton!.height! - nextArt.padding * 2)
                artistTopButton!.frame.origin.y = rect.origin.y - artistTopButton!.frame.height - nextArt.padding
                if artistTopButton!.frame.origin.y + artistTopButton!.frame.height + nextArt.padding <= 0 {
                    artistTopButton!.removeFromSuperview()
                    let currentTopArt = artViews[artTopButtonIndex]
                    currentTopArt.artistButton!.frame = CGRect(origin: CGPoint(x: currentTopArt.frame.width - artistTopButton!.frame.width - currentTopArt.padding, y: currentTopArt.frame.height - artistTopButton!.frame.height - currentTopArt.padding), size: artistTopButton!.frame.size)
                    currentTopArt.artistButton = artistTopButton
                    currentTopArt.addSubview(artistTopButton!)
                    
                    artistTopButton = nextArt.artistButton
                    artistTopButton!.removeFromSuperview()
                    view.addSubview(artistTopButton!)
                    artTopButtonIndex++
                    updateDesplayedArts(1)
                }
            }
        } else if (artTopButtonIndex > 0) {
            let previousArt = artViews[artTopButtonIndex - 1]
            let rect = scrollView.convertRect(previousArt.frame, toView: view)
            let newY = rect.origin.y + rect.height
            if rect.origin.y + rect.height > 0 {
                artistTopButton!.frame.origin.y = newY + previousArt.padding
                if newY >= artistTopButton!.frame.height + previousArt.padding * 2 {
                    artistTopButton!.removeFromSuperview()
                    let currentTopArt = artViews[artTopButtonIndex]
                    currentTopArt.artistButton!.frame = CGRect(origin: CGPoint(x: currentTopArt.frame.width - artistTopButton!.frame.width - currentTopArt.padding, y: currentTopArt.padding), size: artistTopButton!.frame.size)
                    currentTopArt.artistButton = artistTopButton
                    currentTopArt.addSubview(artistTopButton!)
                    
                    artistTopButton = previousArt.artistButton
                    artistTopButton!.removeFromSuperview()
                    artistTopButton!.frame = CGRect(origin: CGPoint(x: currentTopArt.frame.width - artistTopButton!.frame.width - currentTopArt.padding, y: currentTopArt.padding), size: artistTopButton!.frame.size)
                    view.addSubview(artistTopButton!)
                    artTopButtonIndex--
                    updateDesplayedArts(-1)
                }
            }
        }
    }
    
    
    
    func scrollViewDidScrollLandscapeArtistButton(scrollView: UIScrollView) {
        let scrolledLeft = scrollView.contentOffset.x > contentOffset!.x
        if scrolledLeft {
            let nextArt = artViews[artTopButtonIndex + 1]
            let rect = scrollView.convertRect(nextArt.frame, toView: view)
            if rect.origin.x <= nextArt.artistButton!.width! + nextArt.padding * 2 {
                artistTopButton!.frame.origin.x = rect.origin.x - artistTopButton!.frame.width - nextArt.padding
                if artistTopButton!.frame.origin.x + artistTopButton!.frame.width + nextArt.padding <= 0 {
                    artistTopButton!.removeFromSuperview()
                    let currentTopArt = artViews[artTopButtonIndex]
                    currentTopArt.artistButton!.frame = CGRect(origin: CGPoint(x: currentTopArt.frame.width - artistTopButton!.frame.width - currentTopArt.padding, y: currentTopArt.padding), size: artistTopButton!.frame.size)
                    currentTopArt.artistButton = artistTopButton
                    currentTopArt.addSubview(artistTopButton!)
                    
                    artistTopButton = nextArt.artistButton
                    artistTopButton!.removeFromSuperview()
                    view.addSubview(artistTopButton!)
                    artTopButtonIndex++
                    updateDesplayedArts(1)
                }
            }
        } else if (artTopButtonIndex > 0) {
            let previousArt = artViews[artTopButtonIndex - 1]
            let rect = scrollView.convertRect(previousArt.frame, toView: view)
            let newX = rect.origin.x + rect.width
            if rect.origin.x + rect.width > 0 {
                artistTopButton!.frame.origin.x = newX + previousArt.padding
                if newX >= artistTopButton!.frame.width + previousArt.padding * 2 {
                    artistTopButton!.removeFromSuperview()
                    let currentTopArt = artViews[artTopButtonIndex]
                    currentTopArt.artistButton!.frame = CGRect(origin: CGPoint(x: currentTopArt.padding, y: currentTopArt.padding), size: artistTopButton!.frame.size)
                    currentTopArt.artistButton = artistTopButton
                    currentTopArt.addSubview(artistTopButton!)
                    
                    artistTopButton = previousArt.artistButton
                    artistTopButton!.removeFromSuperview()
                    artistTopButton!.frame = CGRect(origin: CGPoint(x: currentTopArt.padding, y: currentTopArt.padding), size: artistTopButton!.frame.size)
                    view.addSubview(artistTopButton!)
                    artTopButtonIndex--
                    updateDesplayedArts(-1)
                }
            }
        }
    }
    
    
    
    func showHomeToolbar() {
        buttonsBarDisplayed = true
        if deviceOrientationLandscape {
            UIView.animateWithDuration(0.2, animations: {
                self.showHomeToolbar(&self.buttonsToolbarView!.frame.origin.x, &self.homeToolbar!.frame.origin.x)
            })
        } else {
            UIView.animateWithDuration(0.2, animations: {
                self.showHomeToolbar(&self.buttonsToolbarView!.frame.origin.y, &self.homeToolbar!.frame.origin.y)
            })
        }
    }
    
    
    
    func showHomeToolbar(inout buttonsToolbarCoordinate: CGFloat, inout _ homeToolbarCoordinate: CGFloat) {
        buttonsToolbarCoordinate -= self.buttonsToolbarHeight
        homeToolbarCoordinate += self.buttonsToolbarHeight / 2
    }


}

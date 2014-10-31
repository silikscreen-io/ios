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
    
    
    let buttonsToolbarHeight: CGFloat = 60
    var buttonsToolbarImageView: UIImageView!
    var buttonsBarDisplayed = true
    var buttonsToolbar: UIToolbar!
    var buttonItems: [UIBarItem] = []
    var homeToolbar: UIToolbar!
    var homeToolbarImageView: UIImageView!
    var homeToolbarItems: [UIBarItem]!
    
    var tappedArt: Art?
    
    var screenSize: CGRect?
    var deviceOrientationLandscape = false
    
    var artistTopButtonPrevious: HexaButton?
    var artistTopButton: HexaButton?
    var artistTopButtonNext: HexaButton?
    var artTopButtonIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationDidChange:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        screenSize = self.view.bounds
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
        updateScrollView()
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
                UIView.animateWithDuration(0.3, animations: {
                    self.buttonsToolbar!.frame.origin.x = 0
                    self.homeToolbar!.frame.origin.x = -self.buttonsToolbarHeight / 2
                })
            }
        } else {
            if !buttonsBarDisplayed {
                buttonsBarDisplayed = true
                let buttonsToolbarY = self.buttonsToolbar!.frame.origin.y
                var newY = buttonsToolbarY - self.buttonsToolbarHeight
                UIView.animateWithDuration(0.3, animations: {
                    self.buttonsToolbar!.frame.origin.y = newY
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
            //            var frame = buttonsToolbar!.frame
            let buttonsToolbarY = self.buttonsToolbar!.frame.origin.y
            var newY = buttonsToolbarY + self.buttonsToolbarHeight
            UIView.animateWithDuration(0.3, animations: {
                self.buttonsToolbar!.frame.origin.y = newY
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
        view.bringSubviewToFront(artistTopButton!)
    }
    
    
    
    func updateScrollView() {
        artViews.removeAll(keepCapacity: false)
        scrollView!.subviews.map{ $0.removeFromSuperview() }
        fillScrollView()
        view.bringSubviewToFront(artistTopButton!)
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
        for art in arts {
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
                frame.size.width = buttonsToolbarHeight
                buttonsToolbar!.frame = frame
                frame.origin.x = origin.x - buttonsToolbarHeight / 2
                frame.size.width = buttonsToolbarHeight / 2
                homeToolbar!.frame = frame
            } else {
                frame.size.width = buttonsToolbarHeight / 2
                homeToolbar!.frame = frame
                frame.size.width = buttonsToolbarHeight
                frame.origin.x = origin.x - buttonsToolbarHeight
                buttonsToolbar!.frame = frame
            }
            homeToolbarImageView.transform = CGAffineTransformMakeRotation(90.0 / 180.0 * CGFloat(M_PI))
            buttonsToolbarImageView.transform = CGAffineTransformMakeRotation(90.0 / 180.0 * CGFloat(M_PI))
        } else {
            if buttonsBarDisplayed {
                frame.origin.y = screenSize.height
                frame.size.height = buttonsToolbarHeight / 2
                homeToolbar!.frame = frame
                frame.origin.y = screenSize.height - buttonsToolbarHeight
                frame.size.height = buttonsToolbarHeight
                buttonsToolbar!.frame = frame
            } else {
                frame.origin.y = frame.height - buttonsToolbarHeight / 2
                frame.size.height = buttonsToolbarHeight / 2
                homeToolbar!.frame = frame
                frame.origin.y = screenSize.height
                frame.size.height = buttonsToolbarHeight
                buttonsToolbar!.frame = frame
            }
            homeToolbarImageView.transform = CGAffineTransformMakeRotation(0)
            buttonsToolbarImageView.transform = CGAffineTransformMakeRotation(0)
        }
        view.bringSubviewToFront(buttonsToolbar)
        view.bringSubviewToFront(homeToolbar)
    }
    
    
    
    func initNavigationBar() {
        //println("initNavigationBar")
        var frame = screenSize!
        frame.origin.y = frame.height
        frame.size.height = buttonsToolbarHeight / 2
        homeToolbar = UIToolbar()
        addToolbar(&homeToolbar, frame)
        initHomeToolbar()
        
        frame.origin.y = screenSize!.height - buttonsToolbarHeight
        frame.size.height += buttonsToolbarHeight / 2
        buttonsToolbar = UIToolbar()
        addToolbar(&buttonsToolbar, frame)
        initButtonsToolbar()
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
        homeToolbarImageView = UIImageView(image: UIImage(named: "arrowUp_icon.png"))
        let item = UIBarButtonItem(customView: getButtonForToolbar(&homeToolbarImageView!, "homeButtonTapped"))
        var space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: "homeButtonTapped")
        homeToolbarItems = Array(arrayLiteral: space, item, space)
        homeToolbar.items = homeToolbarItems
    }
    
    
    
    func initButtonsToolbar() {
        buttonsToolbarImageView = UIImageView(image: UIImage(named: "map_icon.png"))
        let item = UIBarButtonItem(customView: getButtonForToolbar(&buttonsToolbarImageView!, "mapButtonTapped"))
        var space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        buttonItems = Array(arrayLiteral: space, item, space)
        buttonsToolbar.items = buttonItems
    }
    
    
    
    func homeButtonTapped() {
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
                if homeToolbar.frame.origin.x >= -homeToolbar.frame.width / 2 {
                    homeToolbar.frame.origin.x = 0
                    buttonsToolbar.frame.origin.x = -buttonsToolbar.frame.width
                    buttonsBarDisplayed = false
                } else {
                    buttonsToolbar.frame.origin.x = 0
                    homeToolbar.frame.origin.x = -homeToolbar.frame.width
                }
            }
        } else {
            if buttonsBarDisplayed {
                if screenSize!.height - homeToolbar.frame.origin.y >= homeToolbar.frame.height / 2 {
                    homeToolbar.frame.origin.y = screenSize!.height - homeToolbar.frame.height
                    buttonsToolbar.frame.origin.y = screenSize!.height
                    buttonsBarDisplayed = false
                } else {
                    buttonsToolbar.frame.origin.y = screenSize!.height - buttonsToolbar.frame.height
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
            if scrollView.contentOffset.x > contentOffset!.x {
                buttonsToolbar.frame.origin.x -= deltaX
                homeToolbar.frame.origin.x += deltaX / 2
                if homeToolbar.frame.origin.x >= 0 {
                    homeToolbar.frame.origin.x = 0
                    buttonsToolbar.frame.origin.x = -buttonsToolbar.frame.width
                    buttonsBarDisplayed = false
                }
            } else {
                buttonsToolbar.frame.origin.x -= deltaX
                homeToolbar.frame.origin.x += deltaX / 2
                if buttonsToolbar.frame.origin.x >= 0 {
                    homeToolbar.frame.origin.x = -homeToolbar.frame.width
                    buttonsToolbar.frame.origin.x = 0
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
                buttonsToolbar.frame.origin.y += deltaY
                homeToolbar.frame.origin.y -= deltaY / 2
                if homeToolbar.frame.origin.y <= screenSize!.height - homeToolbar.frame.height {
                    homeToolbar.frame.origin.y = screenSize!.height - homeToolbar.frame.height
                    buttonsToolbar.frame.origin.y = screenSize!.height
                    buttonsBarDisplayed = false
                }
            } else {
                buttonsToolbar.frame.origin.y += deltaY
                homeToolbar.frame.origin.y -= deltaY / 2
                if buttonsToolbar.frame.origin.y <= screenSize!.height - buttonsToolbar.frame.height {
                    buttonsToolbar.frame.origin.y = screenSize!.height - buttonsToolbar.frame.height
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
                }
            }
        }
    }
    
    
    
    func showHomeToolbar() {
        buttonsBarDisplayed = true
        if deviceOrientationLandscape {
            UIView.animateWithDuration(0.2, animations: {
                self.buttonsToolbar!.frame.origin.x = -self.buttonsToolbar!.frame.width
                self.homeToolbar!.frame.origin.x = 0
            })
        } else {
            UIView.animateWithDuration(0.2, animations: {
                self.buttonsToolbar!.frame.origin.y = self.buttonsToolbar!.frame.origin.y - self.buttonsToolbarHeight
                self.homeToolbar!.frame.origin.y = self.homeToolbar!.frame.origin.y + self.buttonsToolbarHeight / 2
            })
        }
    }

}

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
    var buttonsBarDisplayed = true
    var buttonsToolbar: UIToolbar!
    var buttonItems: [UIBarItem] = []
    var homeToolbar: UIToolbar!
    var homeToolbarItems: [UIBarItem]!
    
    var tappedArt: Art?
    
    var screenSize: CGRect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            deviceOrientation = orientation;
            return;
        }
        deviceOrientation = orientation;
        let devOrientation =  ((deviceOrientation! == UIDeviceOrientation.Portrait) || (deviceOrientation! == UIDeviceOrientation.PortraitUpsideDown)) ? "Portrait" : "Landscape"
        //println("deviceOrientationChanged: " + devOrientation)
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
    
    
    
    func swipeDown() {
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
        var frame = screenSize!
        scrollView!.frame = frame
        let screenWidth = frame.width
        var scrollViewContentHeight: CGFloat = 0
        frame = CGRect()
        for art in arts {
            let artView = ArtView(art, scrollViewContentHeight, screenWidth)
            scrollView.addSubview(artView)
            scrollViewContentHeight += artView.frame.height
            art.delegate = self
            artViews.append(artView)
        }
        scrollView.contentSize = CGSize(width: screenWidth, height: scrollViewContentHeight)
        self.view.addSubview(scrollView)
        contentOffset = scrollView!.contentOffset
        println(contentOffset)
    }
    
    
    
    func updateScrollView() {
        artViews.removeAll(keepCapacity: false)
        scrollView!.subviews.map{ $0.removeFromSuperview() }
        var frame = screenSize!
        scrollView!.frame = frame
        let screenWidth = frame.width
        var scrollViewContentHeight: CGFloat = 0
        frame = CGRect()
        for art in arts {
            let artView = ArtView(art, scrollViewContentHeight, screenWidth)
            scrollView.addSubview(artView)
            scrollViewContentHeight += artView.frame.height
            art.delegate = self
            artViews.append(artView)
        }
        scrollView.contentSize = CGSize(width: screenWidth, height: scrollViewContentHeight)
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
        var frame = screenSize!
        if buttonsBarDisplayed {
            frame.origin.y = frame.height
            frame.size.height = buttonsToolbarHeight / 2
            homeToolbar!.frame = frame
            frame.origin.y = screenSize!.height - buttonsToolbarHeight
            frame.size.height += buttonsToolbarHeight / 2
            buttonsToolbar!.frame = frame
        } else {
            frame.origin.y = frame.height - buttonsToolbarHeight / 2
            frame.size.height = buttonsToolbarHeight / 2
            homeToolbar!.frame = frame
            frame.origin.y = screenSize!.height
            frame.size.height += buttonsToolbarHeight / 2
            buttonsToolbar!.frame = frame
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
    
    
    
    func initHomeToolbar() {
        var item = UIBarButtonItem(title: "Home", style: UIBarButtonItemStyle.Plain, target: self, action: "homeButtonTapped")
        item.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        var space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        homeToolbarItems = Array(arrayLiteral: space, item, space)
        homeToolbar.items = homeToolbarItems
    }
    
    
    
    func initButtonsToolbar() {
        var item = UIBarButtonItem(image: UIImage(named: "map_icon.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "mapButtonTapped")
        item.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        var space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        buttonItems = Array(arrayLiteral: space, item, space)
        buttonsToolbar.items = buttonItems
    }
    
    
    
    func homeButtonTapped() {
        swipeDown()
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
        for artView in artViews {
            artView.hideStatistic()
        }
    }

    
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
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
        scrollingStarted = false
        if !decelerate {
            for artView in artViews {
                artView.showStatistic()
            }
        }
    }
    
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        for artView in artViews {
            artView.showStatistic()
        }
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollingStarted {
            if buttonsBarDisplayed {
                let deltaY = scrollView.contentOffset.y - contentOffset!.y
                if scrollView.contentOffset.y > contentOffset!.y {
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
        contentOffset = scrollView.contentOffset
    }
    
    
    
    func showHomeToolbar() {
        buttonsBarDisplayed = true
        UIView.animateWithDuration(0.2, animations: {
            self.buttonsToolbar!.frame.origin.y = self.buttonsToolbar!.frame.origin.y - self.buttonsToolbarHeight
            self.homeToolbar!.frame.origin.y = self.homeToolbar!.frame.origin.y + self.buttonsToolbarHeight / 2
        })
    }

}

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
var deviceOrientationLandscape = false

class ArtToolbarViewController: UIViewController, UIScrollViewDelegate, UIViewControllerTransitioningDelegate {
    
    var delegate: ArtFeedViewControllerDelegate?

    var scrollView: UIScrollView!
    var contentOffset: CGPoint?
    var scrollingStarted = false
    var handleScrollingStarted = false
    
    let buttonsToolbarHeight: CGFloat = 44
    var buttonsBarDisplayed = true
    var homeToolbar: UIToolbar!
    var homeToolbarImageView: UIImageView!
    var homeToolbarItems: [UIBarItem]!
    
    var buttonsToolbarView: UIView?
    var buttonHome: UIButton?
    var buttonSearch: UIButton?
    var buttonMap: UIButton?
    var buttonUser: UIButton?
    
    var screenSize: CGRect?
    
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
        contentOffset = CGPoint()
    }
    
    
    
    override func viewWillLayoutSubviews() {
        if !firstLayout {
            return
        }
        firstLayout = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged", name: ORIENTATION_CHANGED_NOTIFICATION, object: nil)
        screenSize = self.view.bounds
        deviceOrientationLandscape = screenSize?.width > screenSize?.height
        initNavigationBar()
        scrollView.delegate = self
    }
    
    
    
    func orientationChanged() {
        updateView()
    }
    
    
    
    func updateView() -> Bool {
        if !updateScreenSize() {
            return false
        }
        updateNavigationBar()
        return true
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
//        let searchViewController = SearchTableViewController()
//        presentViewController(searchViewController, animated: false, completion: nil)
    }
    
    
    
    func mapButtonPressed() {
        let mapViewController = GMapViewController()
        if iOS8Delta {
            showViewController(mapViewController, sender: self)
        } else {
            presentViewController(mapViewController, animated: true, completion: nil)
        }
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
    
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollingStarted = true
        handleScrollingStarted = true
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
        if !decelerate {
            handleScrollingStarted = false
        }
    }
    
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        handleScrollingStarted = false
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
        if !scrollingStarted {
            return
        }
        if buttonsBarDisplayed {
            let deltaY = scrollView.contentOffset.y - contentOffset!.y
            let scrolledDown = scrollView.contentOffset.y > contentOffset!.y
            if scrolledDown {
                if buttonsToolbarView!.frame.origin.y >= screenSize!.height {
                    return
                }
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
    
    
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransitionAnimator()
    }
    
    
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransitionAnimator(false)
    }
}

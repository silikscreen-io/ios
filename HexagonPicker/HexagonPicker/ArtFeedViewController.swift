//
//  ArtFeedViewController.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 23.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

protocol ArtFeedViewControllerDelegate {
    func dismissArtFeedViewController()
}

class ArtFeedViewController: ArtToolbarViewController, GMapViewControllerDelegate, ArtDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchControllerDelegate {
    let SHOW_ART_FROM_FEED_SEGUE_ID = "showArtFromFeedSegue"
    
//    var searchDisplayController: UISearchDisplayController?
    var searchArts: [Art] = []
    
    var images: [UIImage] = []
    var artViews: [ArtView] = []
    
    let SHOW_MAP_SEGUE_ID = "showMapSegue"
    
    var tappedArt: Art?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchArts = arts
        view.backgroundColor = UIColor.blackColor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "imageForArtLoaded:", name: IMAGE_FOR_ART_LOADED_NOTIFICATION_ID, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "imageForArtReloaded:", name: IMAGE_FOR_ART_RELOADED_NOTIFICATION_ID, object: nil)
        scrollView = UIScrollView()
    }
    
    
    
    override func viewWillLayoutSubviews() {
        if !firstLayout {
            return
        }
        super.viewWillLayoutSubviews()
        initFeed()
        initScrollView()
        initNavigationBar()
        scrollView.delegate = self
    }
    
    
    
    override func updateView() -> Bool {
        if super.updateView() {
            updateScrollView()
        }
        return true
    }
    
    
    
    func initFeed() {
        for index in 1...6 {
            images.append(UIImage(named: "Picture\(index).jpg")!)
        }
    }
    
    
    
    func initScrollView() {
        fillScrollView()
        self.view.addSubview(scrollView)
        contentOffset = scrollView!.contentOffset
        if artistTopButton != nil {
            view.bringSubviewToFront(artistTopButton!)
        }
    }
    
    
    
    func updateScrollView() {
        let contentOffset = scrollView.contentOffset
        var frame = screenSize!
        scrollView!.frame = frame
        let screenWidth = frame.width
        let screenHeigth = frame.height
        var scrollViewLength: CGFloat = 0
        frame = CGRect()
        for artView in artViews {
            artView.resize(scrollViewLength, screenWidth, screenHeigth, deviceOrientationLandscape)
            scrollViewLength += (deviceOrientationLandscape ? artView.frame.width : artView.frame.height)
        }
        scrollView.contentSize = (deviceOrientationLandscape ? CGSize(width: scrollViewLength, height: screenHeigth) : CGSize(width: screenWidth, height: scrollViewLength))
        let artView = artViews[artIndexTopDisplayed]
        let rect = scrollView.convertRect(artView.frame, toView: view)
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
        if screenSize == nil {
            return
        }
        let notificationDictionary = (notification.userInfo! as NSDictionary)
        let loadedForFeed = (notificationDictionary.objectForKey("loadedForFeed") as NSNumber).boolValue
        if !loadedForFeed {
            return
        }
        let art = notificationDictionary.objectForKey("art") as Art
        let artView = notificationDictionary.objectForKey("artView") as? ArtView

        if artView != nil {
            artView!.update(art, deviceOrientationLandscape)
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
            artViewController.modalPresentationStyle = UIModalPresentationStyle.Custom
            artViewController.transitioningDelegate = self
        } else if segue.identifier == SHOW_MAP_SEGUE_ID {
            let mapViewController = segue.destinationViewController as GMapViewController
            mapViewController.delegate = self
        }
    }
    
    
    
    override func homeButtonPressed() {
        
    }
    
    
    
    override func searchButtonPressed() {
        let searchViewController = SearchTableViewController()
        presentViewController(searchViewController, animated: false, completion: nil)
    }
    
    
    
//    override func mapButtonPressed() {
//        //performSegueWithIdentifier("showMapSegue", sender: self)
//    }
    
    
    
    override func userButtonPressed() {
        let userViewController = UserViewController()
        userViewController.homeViewController = self
        if iOS8Delta {
            showViewController(userViewController, sender: self)
        } else {
            presentViewController(userViewController, animated: true, completion: nil)
        }
    }
    
    
    
    func dismissGMapViewController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    func dismissArtViewController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    func dismissUserViewController() {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.delegate!.dismissArtFeedViewController()
        })
    }
    
    
    
    override func scrollViewDidScrollLandscape(scrollView: UIScrollView) {
        scrollViewDidScrollLandscapeArtistButton(scrollView)
        super.scrollViewDidScrollLandscape(scrollView)
    }
    
    
    
    override func scrollViewDidScrollPortrait(scrollView: UIScrollView) {
        scrollViewDidScrollPortraitArtistButton(scrollView)
        super.scrollViewDidScrollPortrait(scrollView)
    }
    
    
    
    
    func updateDisplayedArts(newIndex: Int) {
        if !handleScrollingStarted {
            return
        }
        artIndexTopDisplayed += newIndex
        println("artIndexTopDisplayed: \(artIndexTopDisplayed)")
        if newIndex > 0 {
            if artIndexTopDisplayed > MAX_NUMBER_OF_LOADED_IMAGES / 2 {
                //artIndexTopDisplayed -= newIndex
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
    }
    
    
    
    func clearImage(index: Int) {
        println("artViews.count: \(artViews.count)")
        println("artToDeleteImageView: \(index)")
        if index < artViews.count {
            var artToDeleteImageView = artViews[index]
            artToDeleteImageView.art!.image = nil
            artToDeleteImageView.image = nil
            artsDisplayed.removeAtIndex(find(artsDisplayed, artToDeleteImageView.art!)!)
        }
    }
    
    
    
    func scrollViewDidScrollPortraitArtistButton(scrollView: UIScrollView) {
        let scrolledDown = scrollView.contentOffset.y > contentOffset!.y
        if scrolledDown {
            if artTopButtonIndex + 1 >= artViews.count {
                return
            }
            let nextArt = artViews[artTopButtonIndex + 1]
            let rect = scrollView.convertRect(nextArt.frame, toView: view)
            if rect.origin.y <= nextArt.artistButton!.frame.height + nextArt.padding * 2 {
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
                    updateDisplayedArts(1)
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
                    updateDisplayedArts(-1)
                }
            }
        }
    }
    
    
    
    func scrollViewDidScrollLandscapeArtistButton(scrollView: UIScrollView) {
        let scrolledLeft = scrollView.contentOffset.x > contentOffset!.x
        if scrolledLeft {
            if artTopButtonIndex + 1 >= artViews.count {
                return
            }
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
                    updateDisplayedArts(1)
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
                    updateDisplayedArts(-1)
                }
            }
        }
    }
}

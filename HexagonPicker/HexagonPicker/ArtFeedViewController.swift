//
//  ArtFeedViewController.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 23.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

var artFeedViewController: UIViewController?


protocol ArtFeedViewControllerDelegate {
    func dismissArtFeedViewController()
}

let ARTS_LOADED_NOTIFICATION = "artsLoadedNotification"
var YYY: CGFloat = 0
var artsDidLoaded = false

class ArtFeedViewController: ArtToolbarViewController, GMapViewControllerDelegate, ArtDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchControllerDelegate {
    let SHOW_ART_FROM_FEED_SEGUE_ID = "showArtFromFeedSegue"
    
//    var searchDisplayController: UISearchDisplayController?
    var searchArts: [Art] = []
    
    var images: [UIImage] = []
    var artViews: [ArtView] = []
    
    let SHOW_MAP_SEGUE_ID = "showMapSegue"
    
    var tappedArt: Art?
    var scrollViewInitialized = false
    
    @IBOutlet weak var silkView: UIView!
    @IBOutlet weak var silkLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        artFeedViewController = self
        silkView.frame.size.height += 20
        searchArts = arts
        view.backgroundColor = UIColor.blackColor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "imageForArtLoaded:", name: IMAGE_FOR_ART_LOADED_NOTIFICATION_ID, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "imageForArtReloaded:", name: IMAGE_FOR_ART_RELOADED_NOTIFICATION_ID, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "artsLoaded", name: ARTS_LOADED_NOTIFICATION, object: nil)
        scrollView = UIScrollView()
    }
    
    
    
    override func viewWillLayoutSubviews() {
        if !firstLayout {
            return
        }
        super.viewWillLayoutSubviews()
        initFeed()
        if artsDidLoaded {
            initScrollView()
        }
        scrollView.delegate = self
        view.bringSubviewToFront(silkView)
    }
    
    
    
    override func viewDidLayoutSubviews() {
        silkView.frame.origin.y = -20
        silkView.frame.size.height += 20
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
    
    
    
    func artsLoaded() {
        if screenSize != nil {
            initScrollView()
        }
    }
    
    
    
    func initScrollView() {
        if scrollViewInitialized {
            return
        }
        scrollViewInitialized = true
        self.view.addSubview(scrollView)
        fillScrollView()
        contentOffset = scrollView!.contentOffset
        if artistTopButton != nil {
            view.bringSubviewToFront(artistTopButton!)
        }
        view.bringSubviewToFront(homeToolbar!)
        view.bringSubviewToFront(buttonsToolbarView!)
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
//        dispatch_async(dispatch_get_main_queue(), {
        if self.artistTopButton != nil {
            self.artistTopButton!.removeFromSuperview()
            self.artistTopButton = nil
            self.artTopButtonIndex = 0
        }
        var frame = self.screenSize!
        self.scrollView!.frame = frame
        let screenWidth = frame.width
        let screenHeigth = frame.height
        var scrollViewLength: CGFloat = 0
        frame = CGRect()
//        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
//        dispatch_async(queue, {
            for art in arts {
                let artView = ArtView(art, scrollViewLength, screenWidth, screenHeigth, self, deviceOrientationLandscape)
//                dispatch_async(dispatch_get_main_queue(), {
                    self.scrollView.addSubview(artView)
                    if artView.image != nil {
                        artView.alpha = 0
                        UIView.animateWithDuration(0.5, animations: { () -> Void in
                            artView.alpha = 1
                        })
                    }
//                })
                scrollViewLength += (deviceOrientationLandscape ? artView.frame.width : artView.frame.height)
                self.scrollView.contentSize = (deviceOrientationLandscape ? CGSize(width: scrollViewLength, height: screenHeigth) : CGSize(width: screenWidth, height: scrollViewLength))
                art.delegate = self
                self.artViews.append(artView)
//                dispatch_async(dispatch_get_main_queue(), {
                    if self.artistTopButton == nil {
                        self.artistTopButton = artView.artistButton
                        if self.artistTopButton != nil {
                            self.view.addSubview(self.artistTopButton!)
                        }
                    } else if self.artistTopButtonNext == nil {
                        self.artistTopButtonNext = artView.artistButton
                    }
//                })
            }
//        })
//        dispatch_async(dispatch_get_main_queue(), {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.silkView.alpha = 0
            })
//        })
//        })
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
            let artIndex = find(arts, art)
            if artIndex != nil && artIndex < artViews.count {
                artViews[artIndex!].image = art.image
                artViews[artIndex!].alpha = 0
                UIView.animateWithDuration(3, animations: { () -> Void in
                    self.artViews[artIndex!].alpha = 1
                })
            }
        }
    }
    
    
    
    func imageForArtReloaded(notification: NSNotification) {
        let notificationDictionary = (notification.userInfo! as NSDictionary)
        let art = notificationDictionary.objectForKey("art") as Art
        let artView = notificationDictionary.objectForKey("artView") as ArtView
        let artIndex = find(arts, art)
        if artIndex != nil && (artIndex! < artIndexTopDisplayed - MAX_NUMBER_OF_LOADED_IMAGES / 2 - 1 || artIndex > artIndexTopDisplayed + MAX_NUMBER_OF_LOADED_IMAGES / 2 + 1) {
            clearImage(artIndex!)
//            art.image = nil
//            artView.image = nil
            return
        }
        artView.update(art, deviceOrientationLandscape)
        artView.alpha = 0
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            artView.alpha = 1
        })
    }
    
    
    
    func artTapped(art: Art) {
        tappedArt = art
        performSegueWithIdentifier(SHOW_ART_FROM_FEED_SEGUE_ID, sender: self)
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SHOW_ART_FROM_FEED_SEGUE_ID {
            let artViewController = segue.destinationViewController as ArtViewController
            artViewController.art = tappedArt
            artViewController.modalPresentationStyle = UIModalPresentationStyle.Custom
            artViewController.transitioningDelegate = self
        } else if segue.identifier == SHOW_MAP_SEGUE_ID {
            let mapViewController = segue.destinationViewController as GMapViewController
            mapViewController.delegate = self
        }
    }
    
    
    
    override func homeButtonPressed() {
        let featuredViewController = FeaturedViewController()
        presentViewController(featuredViewController, animated: true, completion: nil)
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
        if newIndex > 0 {
            if artIndexTopDisplayed > MAX_NUMBER_OF_LOADED_IMAGES / 2 {
                let addArtIndex = artIndexFirst + MAX_NUMBER_OF_LOADED_IMAGES
                if artIndexFirst + MAX_NUMBER_OF_LOADED_IMAGES < arts.count {
                    let newDisplayedArt = arts[addArtIndex]
                    currentNumberOfLoadedImages--
                    var artView: ArtView?
                    if artIndexTopDisplayed + MAX_NUMBER_OF_LOADED_IMAGES / 2 - newIndex < artViews.count {
                        artView = artViews[artIndexTopDisplayed + MAX_NUMBER_OF_LOADED_IMAGES / 2 - newIndex]
                    }
                    newDisplayedArt.reloadImage(artView!)
                    artView!.addButton()
                    clearImage(artIndexTopDisplayed - MAX_NUMBER_OF_LOADED_IMAGES / 2 - newIndex)
                    artIndexFirst += newIndex
                }
            }
        } else {
            if artIndexTopDisplayed - MAX_NUMBER_OF_LOADED_IMAGES / 2 < 0 {
                return
            }
            artIndexFirst += newIndex
            let newDisplayedArtView = artViews[artIndexTopDisplayed - MAX_NUMBER_OF_LOADED_IMAGES / 2]
            newDisplayedArtView.art!.reloadImage(newDisplayedArtView)
            newDisplayedArtView.addButton()
            clearImage(artIndexTopDisplayed + MAX_NUMBER_OF_LOADED_IMAGES / 2)
        }
    }
    
    
    
    func clearImage(index: Int) {
        if index < artViews.count {
            var artToDeleteImageView = artViews[index]
            artToDeleteImageView.art!.image = nil
            artToDeleteImageView.image = nil
            artToDeleteImageView.removeButton()
            let index = find(artsDisplayed, artToDeleteImageView.art!)
            if index != nil {
                artsDisplayed.removeAtIndex(index!)
            }
        }
    }
    
    
    
    func scrollViewDidScrollPortraitArtistButton(scrollView: UIScrollView) {
        println("artistTopButton!.frame.origin.y: \(artistTopButton!.frame.origin.y)")
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
            } else {
                if artistTopButton!.frame.origin.y < artViews[artTopButtonIndex].padding {
                    artistTopButton!.frame.origin.y += contentOffset!.y - scrollView.contentOffset.y
                } else {
                    artistTopButton!.frame.origin.y = artViews[artTopButtonIndex].padding
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
            } else {
                if artistTopButton!.frame.origin.x < artViews[artTopButtonIndex].padding {
                    artistTopButton!.frame.origin.x += contentOffset!.x - scrollView.contentOffset.x
                } else {
                    artistTopButton!.frame.origin.x = artViews[artTopButtonIndex].padding
                }
            }
        }
    }


}

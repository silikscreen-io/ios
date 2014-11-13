//
//  ArtistDetailViewController.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 30.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

class ArtistDetailViewController: CollectionsViewController {
    
    var artist: Artist?
    
    override func viewDidLoad() {
        personName = artist!.name
        artsSource = artist!.arts
        super.viewDidLoad()
    }
}
//class ArtistDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    
//    let cellIdentifier = "collectionArtCell"
//    
//    
//    var artist: Artist?
//    var arts:[String: [Art]] = [:]
//    var citiesLabels: [UILabel] = []
//    var screenSize: CGRect?
//    var firstLayout = true
//    
//    var artistLabel: UILabel?
//    let buttonWidth: CGFloat = 100
//    let buttonHeight: CGFloat = 40
//    let buttonPadding: CGFloat = 10
//    var backButton: UIButton?
//    
//    
//    let cellSize: CGFloat = 100
//    let scrollPadding: CGFloat = 50
//    
//    var scrollView: UIScrollView = UIScrollView()
//    var collectionViews = [UICollectionView: String]()
//    let flowLayout = UICollectionViewFlowLayout()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = UIColor.blackColor()
//        
//        for art in artist!.arts {
//            if self.arts[art.city] == nil {
//                let array = [art]
//                self.arts[art.city] = array
//            } else {
//                self.arts[art.city]!.append(art)
//            }
//        }
//        view.addSubview(scrollView)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "previewLoaded:", name: PREVIEW_LOADED_NOTIFICATION_ID, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged", name: ORIENTATION_CHANGED_NOTIFICATION, object: nil)
//    }
//    
//    
//    
//    func initArtsCollectionViews() {
//        flowLayout.itemSize = CGSizeMake(cellSize, cellSize)
//        flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
//        var position: CGFloat = scrollPadding
//        for (city, _) in self.arts {
//            println(city)
//            addArtsCollectionView(position, city)
//            initCityLabel(position, city)
//            position += cellSize + scrollPadding
//        }
//        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: position)
//        alignCollectionViews()
//    }
//    
//    
//    
//    func addArtsCollectionView(position: CGFloat, _ city: String) {
//        let flowLayout = UICollectionViewFlowLayout()
//        flowLayout.itemSize = CGSizeMake(cellSize, cellSize)
//        flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
//        let collectionView = UICollectionView(frame: CGRectMake(0, position, screenSize!.width, cellSize), collectionViewLayout: flowLayout)
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        
//        collectionView.registerNib(UINib(nibName: "CollectionArtCell", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
//        scrollView.addSubview(collectionView)
//        
//        collectionViews[collectionView] = city
//    }
//    
//    
//    
//    override func viewWillLayoutSubviews() {
//        if !firstLayout {
//            return
//        }
//        firstLayout = false
//        screenSize = self.view.bounds
//        initButtons()
//        artistLabel = UILabel()
//        artistLabel!.text = artist!.name
//        artistLabel!.font = UIFont(name: artistLabel!.font.description, size: 30)
//        artistLabel!.sizeToFit()
//        artistLabel!.textColor = UIColor.magentaColor()
//        updateArtistLabel()
//        view.addSubview(artistLabel!)
//        alignScrollView()
//        initArtsCollectionViews()
//    }
//    
//    
//    
//    func alignScrollView() {
//        scrollView.frame = screenSize!
//        scrollView.frame.origin.y = scrollPadding
//    }
//    
//    
//    
//    func initCityLabel(position: CGFloat, _ city: String) {
//        let label = UILabel()
//        label.text = city
//        label.font = UIFont(name: "SnellRoundhand-Black", size: 30)
//        label.sizeToFit()
//        label.textColor = UIColor.grayColor()
//        label.frame.origin.y = position - label.frame.height
//        alignLabel(label)
//        citiesLabels.append(label)
//        scrollView.addSubview(label)
//    }
//    
//    
//    
//    func alignLabel(label: UILabel) {
//        label.frame.origin.x = (screenSize!.width - label.frame.width) / 2
//    }
//    
//    
//    
//    func alignCityLabels() {
//        for label in citiesLabels {
//            alignLabel(label)
//        }
//    }
//    
//    
//    
//    func alignCollectionViews() {
//        for (view, city) in collectionViews {
//            view.frame.origin.x = 0
//            view.frame.size.width = screenSize!.width
//            let artsCount = CGFloat(self.arts[city]!.count)
//            let collectionViewSize = cellSize * artsCount
//            if collectionViewSize < screenSize!.width {
//                view.frame.origin.x = (screenSize!.width - collectionViewSize) / 2
//            }
//        }
//    }
//    
//    
//    
//    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//        let city = collectionViews[collectionView]
//        return self.arts[city!]!.count
//    }
//    
//    
//    
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 1
//    }
//    
//    
//    
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        println("B let cell = collectionView.deque")
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath:indexPath) as UICollectionViewCell
//        println("A let cell = collectionView.deque")
//        let city = collectionViews[collectionView]
//        let art = self.arts[city!]![indexPath.section]
//        let imageView = cell.viewWithTag(100) as UIImageView
//        if art.previewImage == nil {
//            imageView.image = nil
//            art.loadPreview(collectionView, indexPath)
//        } else {
//            imageView.image = art.previewImage
//            let activityIndicatorView = cell.viewWithTag(101) as UIActivityIndicatorView
//            activityIndicatorView.hidden = true
//        }
//        println(indexPath)
//        return cell
//    }
//    
//    
//    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//        return UIEdgeInsetsMake(0, 1, 0, 1)
//    }
//    
//    
//    
//    func previewLoaded(notification: NSNotification) {
//        let notificationDictionary = (notification.userInfo! as NSDictionary)
//        let collectionView = notificationDictionary.objectForKey("collectionView") as? UICollectionView
//        if collectionView == nil {
//            return
//        }
//        let indexPath = notificationDictionary.objectForKey("indexPath") as? NSIndexPath
//        println(indexPath)
//        //collectionView!.reloadItemsAtIndexPaths([indexPath!])
//        collectionView!.reloadData()
//    }
//    
//    
//    
//    func updateArtistLabel() {
//        artistLabel!.frame = CGRect(origin: CGPoint(x: (screenSize!.width - artistLabel!.frame.width) / 2, y: buttonPadding), size: artistLabel!.frame.size)
//    }
//    
//    
//    
//    func initButtons() {
//        var screenFrame = screenSize!
//        let buttonFrame = CGRect(x: buttonPadding, y: buttonPadding, width: 48, height: 48)
//        backButton = UIButton(frame: buttonFrame)
//        initButton(&backButton!, "back_arrow", "backButtonPressed:")
//    }
//    
//    
//    
//    func initButton(inout button: UIButton, _ imageName: String, _ selector: Selector) {
//        button.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
//        button.alpha = 0.7
//        button.addTarget(self, action: selector, forControlEvents: UIControlEvents.TouchUpInside)
//        self.view.addSubview(button)
//    }
//    
//    
//    
//    func updateScreenSize() -> Bool {
//        let deviceOrientationPortrait = ((deviceOrientation! == UIDeviceOrientation.Portrait) || (deviceOrientation! == UIDeviceOrientation.PortraitUpsideDown)) ? true : false
//        let minSize = screenSize!.size.width < screenSize!.height ? screenSize!.size.width : screenSize!.height
//        let maxSize = screenSize!.size.width > screenSize!.height ? screenSize!.size.width : screenSize!.height
//        if deviceOrientationPortrait {
//            if minSize == screenSize!.size.width {
//                return false
//            }
//            screenSize!.size = CGSize(width: minSize, height: maxSize)
//        } else {
//            if maxSize == screenSize!.size.width {
//                return false
//            }
//            screenSize!.size = CGSize(width: maxSize, height: minSize)
//        }
//        return true
//    }
//    
//    
//    
//    func orientationChanged() {
//        if !updateScreenSize() {
//            return
//        }
//        updateArtistLabel()
//        alignScrollView()
//        alignCityLabels()
//        alignCollectionViews()
//    }
//    
//    
//    
//    func backButtonPressed(sender: UIButton) {
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: PREVIEW_LOADED_NOTIFICATION_ID, object: nil)
//        dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    
//    
//    override func prefersStatusBarHidden() -> Bool {
//        return true
//    }
//}

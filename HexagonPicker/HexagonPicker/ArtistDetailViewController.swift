//
//  ArtistDetailViewController.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 30.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

class ArtistDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    let cellIdentifier = "collectionArtCell"

    
    var artist: Artist?
    var arts:[String: [Art]] = [:]
    var screenSize: CGRect?
    var firstLayout = true
    
    var artistLabel: UILabel?
    let buttonWidth: CGFloat = 100
    let buttonHeight: CGFloat = 40
    let buttonPadding: CGFloat = 10
    var backButton: UIButton?
    
    var scrollView: UIScrollView = UIScrollView()
    var collectionViews = [UICollectionView: String]()
    let flowLayout = UICollectionViewFlowLayout()
    var dataArray: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        
        for art in artist!.arts {
            if self.arts[art.city] == nil {
                let array = [art]
                self.arts[art.city] = array
            } else {
                self.arts[art.city]!.append(art)
            }
        }
        
        for index in 0...50 {
            dataArray.append("Cell \(index)")
        }
        view.addSubview(scrollView)
    }
    
    
    
    func initArtsCollectionViews() {
        flowLayout.itemSize = CGSizeMake(50, 50)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        var position: CGFloat = 100
        for (city, _) in self.arts {
            println(city)
            addArtsCollectionView(position, city)
            position += 100
        }
    }
    
    
    
    func addArtsCollectionView(position: CGFloat, _ city: String) {
        let collectionView = UICollectionView(frame: CGRectMake(0, position, screenSize!.width, 100), collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.registerNib(UINib(nibName: "CollectionArtCell", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        scrollView.addSubview(collectionView)
        
        collectionViews[collectionView] = city
    }
    
    
    
    override func viewWillLayoutSubviews() {
        if !firstLayout {
            return
        }
        firstLayout = false
        screenSize = self.view.bounds
        initButtons()
        artistLabel = UILabel()
        artistLabel!.text = artist!.name
        artistLabel!.font = UIFont(name: artistLabel!.font.description, size: 30)
        artistLabel!.sizeToFit()
        artistLabel!.textColor = UIColor.magentaColor()
        updateArtistLabel()
        view.addSubview(artistLabel!)
        scrollView.frame = screenSize!
        initArtsCollectionViews()
    }
    
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        let city = collectionViews[collectionView]
        return self.arts[city!]!.count
    }
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath:indexPath) as UICollectionViewCell
        let city = collectionViews[collectionView]
        let art = self.arts[city!]![indexPath.section]
        let imageView = cell.viewWithTag(100) as UIImageView
        imageView.image = art.iconImage
        println(art.artDescription)
        return cell
    }
    
    
    
    func updateArtistLabel() {
        artistLabel!.frame = CGRect(origin: CGPoint(x: (screenSize!.width - artistLabel!.frame.width) / 2, y: buttonPadding), size: artistLabel!.frame.size)
    }
    
    
    
    func initButtons() {
        var screenFrame = screenSize!
        let buttonFrame = CGRect(x: buttonPadding, y: buttonPadding, width: 48, height: 48)
        backButton = UIButton(frame: buttonFrame)
        initButton(&backButton!, "back_arrow", "backButtonPressed:")
    }
    
    
    
    func initButton(inout button: UIButton, _ imageName: String, _ selector: Selector) {
        button.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        button.alpha = 0.7
        button.addTarget(self, action: selector, forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
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
    
    
    
    func orientationChanged() {
        if !updateScreenSize() {
            return
        }
        updateArtistLabel()
    }
    
    
    
    func backButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

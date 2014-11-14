//
//  UserViewController.swift
//  Silkscreen
//
//  Created by Vlasov Illia on 05.11.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

class UserViewController: CollectionsViewController {
    
    let paddingX: CGFloat = 10
    
    let userNamePaddingY: CGFloat = 30
    
    var instagramLabel: UILabel?
    var instagramButton: UIButton?
    
    var userPicture: HexaButton?

    override func viewDidLoad() {
        personName = currentUser!.fullName!
        artsSource = currentUser!.likes
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged", name: ORIENTATION_CHANGED_NOTIFICATION, object: nil)

        // Do any additional setup after loading the view.
    }
    
    
    
    override func initArtsCollectionViews() {
        initPicture()
        initInstagram()
        collectionViewPosition += instagramLabel!.frame.origin.y + instagramLabel!.frame.height
        super.initArtsCollectionViews()
    }
    
    
    
    func initInstagram() {
        let y = userPicture!.frame.origin.y + userPicture!.frame.height + 4 * buttonPadding
        instagramLabel = UILabel()
        instagramLabel!.frame = CGRect(origin: CGPoint(x: paddingX, y: y), size: CGSize(width: screenSize!.width, height: 10))
        instagramLabel!.text = "Instagram"
        instagramLabel!.textAlignment = NSTextAlignment.Center
        instagramLabel!.numberOfLines = 0
        instagramLabel!.sizeToFit()
        instagramLabel!.frame = CGRect(origin: CGPoint(x: screenSize!.width / 2 - paddingX - instagramLabel!.frame.width, y: y - instagramLabel!.frame.size.height / 2), size: instagramLabel!.frame.size)
        instagramLabel!.textColor = UIColor.whiteColor()
        scrollView.addSubview(instagramLabel!)

        
        var buttonFrame = CGRect(x: screenSize!.width / 2 + paddingX, y: y - buttonHeight / 2, width: buttonWidth * 2, height: buttonHeight)
        instagramButton = UIButton(frame: buttonFrame)
        initTextButton(&instagramButton!, "Log out", "logoutButtonPressed:")
        scrollView.contentSize.height += instagramLabel!.frame.height + collectionPadding
    }
    
    
    
    func initTextButton(inout button: UIButton, _ title: String, _ selector: Selector) {
        button.setTitle(title, forState: UIControlState.Normal)
        button.backgroundColor = UIColor.blackColor()
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        button.addTarget(self, action: selector, forControlEvents: UIControlEvents.TouchUpInside)
        scrollView.addSubview(button)
    }
    
    
    
    func initPicture() {
        userPicture = HexaButton(100, 250, currentUser!.profilePicture!.size.width)
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: userPicture!.frame.size)
        let imageRef = CGImageCreateWithImageInRect(currentUser!.profilePicture!.CGImage, rect);
        userPicture!.setMainImage(UIImage(CGImage: imageRef))
        scrollView.addSubview(userPicture!)
        scrollView.contentSize.height += userPicture!.height! + 4 * buttonPadding
        alignPicture()
    }
    
    
    
    func alignPicture() {
        var width = userPicture!.frame.width
        var height = userPicture!.frame.height
        var availableWidth = screenSize!.width
        if width > availableWidth {
            let ratio = width / availableWidth
            width = availableWidth
            height /= ratio
        }
        let x = (availableWidth - width) / 2
        userPicture!.frame = CGRect(x: x, y: 0, width: width, height: height)
    }
    
    
    
    func alignInstagram() {
        let y = userPicture!.frame.origin.y + userPicture!.frame.height + 4 * buttonPadding
        let buttonFrame = CGRect(x: screenSize!.width / 2 + buttonPadding, y: y - buttonHeight / 2, width: buttonWidth * 2, height: buttonHeight)
        instagramButton!.frame = buttonFrame
        instagramLabel!.frame = CGRect(origin: CGPoint(x: screenSize!.width / 2 - buttonPadding - instagramLabel!.frame.width, y: y - instagramLabel!.frame.size.height / 2), size: instagramLabel!.frame.size)
    }
    
    
    
    
    override func orientationChanged() -> Bool {
        if !super.orientationChanged() {
            return false
        }
        alignPicture()
        alignInstagram()
        return true
    }
    
    
    
    func logoutButtonPressed(sender: UIButton) {
        if presentingViewController!.isMemberOfClass(ArtFeedViewController.self) {
            (presentingViewController as ArtFeedViewController).dismissUserViewController()
            artsDisplayed.removeAll(keepCapacity: false)
            buttonsLoadedNumber = 0
        }
    }
}
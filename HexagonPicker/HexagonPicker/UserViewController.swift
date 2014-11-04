//
//  UserViewController.swift
//  Silkscreen
//
//  Created by Vlasov Illia on 05.11.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {
    var homeViewController: UIViewController?
    
    let buttonWidth: CGFloat = 50
    let buttonHeight: CGFloat = 40
    let buttonPadding: CGFloat = 10
    let paddingX: CGFloat = 10
    
    var backButton: UIButton?
    
    var screenSize: CGRect?
    var firstLayout = true
    
    var userName: UILabel?
    let userNamePaddingY: CGFloat = 50
    
    var userPicture: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged", name: ORIENTATION_CHANGED_NOTIFICATION, object: nil)

        // Do any additional setup after loading the view.
    }
    
    
    
    override func viewWillLayoutSubviews() {
        if !firstLayout {
            return
        }
        firstLayout = false
        screenSize = self.view.bounds
        initFullNameLabel()
        initPicture()
        let buttonFrame = CGRect(x: buttonPadding, y: buttonPadding, width: buttonWidth, height: buttonHeight)
        backButton = UIButton(frame: buttonFrame)
        initButton(&backButton!, "back", "backButtonPressed:")
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
    
    
    
    func initFullNameLabel() {
        userName = UILabel()
        alignUserName()
        userName!.textColor = UIColor.whiteColor()
        view.addSubview(userName!)
    }
    
    
    
    func alignUserName() {
        userName!.frame = CGRect(origin: CGPoint(x: paddingX, y: userNamePaddingY), size: CGSize(width: screenSize!.width - 2 * paddingX, height: 10))
        userName!.text = currentUser!.fullName
        userName!.textAlignment = NSTextAlignment.Center
        userName!.numberOfLines = 0
        userName!.sizeToFit()
        userName!.frame = CGRect(origin: CGPoint(x: (screenSize!.width - userName!.frame.width) / 2 - paddingX, y: userNamePaddingY), size: userName!.frame.size)
    }
    
    
    
    func initPicture() {
        userPicture = UIImageView(image: currentUser!.profilePicture)
        alignPicture()
        view.addSubview(userPicture!)
    }
    
    
    
    func alignPicture() {
        var width = userPicture!.frame.width
        var height = userPicture!.frame.height
        var availableWidth = screenSize!.width - 2 * paddingX
        if width > availableWidth {
            let ratio = width / availableWidth
            width = availableWidth
            height /= ratio
        }
        let x = (availableWidth - width) / 2
        let y = userName!.frame.origin.y + userName!.frame.height + userNamePaddingY
        userPicture!.frame = CGRect(x: x, y: y, width: width, height: height)
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
        alignUserName()
        alignPicture()
    }
    
    
    
    func backButtonPressed(sender: UIButton) {
        if homeViewController!.isMemberOfClass(ArtFeedViewController.self) {
            (homeViewController as ArtFeedViewController).dismissArtViewController()
        }
    }

}

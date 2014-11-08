//
//  ArtistDetailViewController.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 30.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

class ArtistDetailViewController: UIViewController {
    
    var artist: Artist?
    var screenSize: CGRect?
    var firstLayout = true
    
    var artistLabel: UILabel?
    let buttonWidth: CGFloat = 100
    let buttonHeight: CGFloat = 40
    let buttonPadding: CGFloat = 10
    var backButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
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

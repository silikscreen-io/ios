//
//  ArtistDetailViewController.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 30.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

class ArtistDetailViewController: UIViewController {
    var homeViewController: UIViewController?
    
    var screenSize: CGRect?
    let buttonWidth: CGFloat = 100
    let buttonHeight: CGFloat = 40
    let buttonPadding: CGFloat = 10
    var backButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        screenSize = self.view.bounds
        initButtons()
        let label = UILabel()
        label.text = "User details"
        label.sizeToFit()
        label.textColor = UIColor.magentaColor()
        label.frame = CGRect(origin: CGPoint(x: (screenSize!.width - label.frame.width) / 2, y: buttonPadding), size: label.frame.size)
        view.addSubview(label)
    }
    
    
    
    func initButtons() {
        var screenFrame = screenSize!
        var buttonFrame = CGRect(x: buttonPadding, y: buttonPadding, width: buttonWidth / 2, height: buttonHeight)
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
    
    
    
    func backButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

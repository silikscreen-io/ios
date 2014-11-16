//
//  FeaturedViewController.swift
//  Silkscreen
//
//  Created by Vlasov Illia on 16.11.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

class FeaturedViewController: UIViewController {
    
    var buttons: [ArtistButton] = []
    var screenSize: CGRect?
    var firstLayout = true

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged", name: ORIENTATION_CHANGED_NOTIFICATION, object: nil)
    }
    
    
    
    override func viewWillLayoutSubviews() {
        if !firstLayout {
            return
        }
        firstLayout = false
        screenSize = self.view.bounds
        fillViewWithButtons()
    }
    
    
    
    func fillViewWithButtons() {
        var screenSize = self.screenSize!
        
        let landscape = screenSize.width > screenSize.height
        let smallRadiusr = screenSize.width / ((landscape ? 5 : 3) * 2)
        let bigRadius = smallRadiusr / 0.86603
        let width = 2 * bigRadius
        let height = 2 * smallRadiusr
        let xStep = 0.5 * bigRadius
        
        let maxX = screenSize.width
        let maxY = screenSize.height
        var firstLine = true
        var x: CGFloat = 0
        var y: CGFloat = 0
        var button: ArtistButton?
        let featuredArtists = 5
        var index = 0
        while index < featuredArtists {
            while trunc(x + height) <= maxX {
                button = ArtistButton(x, y, CGSize(width: height, height: width), artistsSortedByArtsNumber[index], self)
                x += height
                let imageName = users[index]
                button!.setMainImage(UIImage(named: imageName))
                view.addSubview(button!)
                buttons.append(button!)
                ++index
            }
            firstLine = !firstLine
            if firstLine {
                x = 0
            } else {
                x = smallRadiusr
            }
            y += bigRadius + xStep
        }
    }
    
    
    
    func updateButtons() {
        for button in buttons {
            button.removeFromSuperview()
        }
        buttons.removeAll(keepCapacity: true)
        fillViewWithButtons()
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
        updateButtons()
    }
    
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}

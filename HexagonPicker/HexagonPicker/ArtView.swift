//
//  ArtView.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 29.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

let queue = dispatch_queue_create("com.example.MyQueue", nil)


class ArtView: UIImageView {
    let users = ["ann.jpg", "gal.jpg", "rah.jpg", "ste.jpg"]
    
    let padding: CGFloat = 10
    
    let buttonWidth: CGFloat = 34
    var artistButton: HexaButton?
    var parentViewController: UIViewController?
    
    var art: Art?
    
    init(_ art: Art, _ length: CGFloat, _ width: CGFloat, _ heigth: CGFloat, _ parentViewController: UIViewController, _ deviceOrientationLandscape: Bool) {
        super.init()
        self.parentViewController = parentViewController
        self.art = art
        
        let imageSize = art.image!.size
        let imageWidth = imageSize.width
        let imageHeight = imageSize.height
        let scaleFactor = (deviceOrientationLandscape ? imageSize.height / heigth : imageSize.width / width)
        let imageViewLength = (deviceOrientationLandscape ? imageWidth / scaleFactor : imageHeight / scaleFactor)
        if deviceOrientationLandscape {
            frame.origin.x = length
        } else {
            frame.origin.y = length
        }
        frame.size = (deviceOrientationLandscape ? CGSize(width: imageViewLength, height: heigth) : CGSize(width: width, height: imageViewLength))
        image = art.image
        
        let singleTap = UITapGestureRecognizer(target: art, action: "tapDetected:")
        singleTap.numberOfTapsRequired = 1
        userInteractionEnabled = true
        addGestureRecognizer(singleTap)
        initButtons(width, heigth)
    }
    
    
    
    func update(art: Art, _ deviceOrientationLandscape: Bool) {
//        dispatch_async(queue, {
//            self.art = art
//            self.image = art.image
////            var error: NSError?
////            let imageData: NSData? = NSData(contentsOfURL: NSURL(string: link)!, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &error)
////            if error == nil {
////                pictures1[link] = UIImage(data: imageData!)
////                dispatch_async(dispatch_get_main_queue(), {
////                    NSNotificationCenter.defaultCenter().postNotificationName(pictureLoadedNotification, object:self)
////                })
////            }
//        });
        self.art = art
        image = art.image
        
        let singleTap = UITapGestureRecognizer(target: art, action: "tapDetected:")
        singleTap.numberOfTapsRequired = 1
        userInteractionEnabled = true
        addGestureRecognizer(singleTap)
    }
    
    
    
    func resize(length: CGFloat, _ width: CGFloat, _ heigth: CGFloat, _ deviceOrientationLandscape: Bool) {
        let size = frame.size
        let currentWidth = size.width
        let currentHeight = size.height
        let scaleFactor = (deviceOrientationLandscape ? currentHeight / heigth : currentWidth / width)
        let imageViewLength = (deviceOrientationLandscape ? currentWidth / scaleFactor : currentHeight / scaleFactor)
        frame.origin = CGPoint()
        if deviceOrientationLandscape {
            frame.origin.x = length
        } else {
            frame.origin.y = length
        }
        frame.size = (deviceOrientationLandscape ? CGSize(width: imageViewLength, height: heigth) : CGSize(width: width, height: imageViewLength))
        
        resizeButtons(width, heigth)
    }
    
    
    
    func resizeButtons(width: CGFloat, _ heigth: CGFloat) {
        let x = (width < heigth ? bounds.width - buttonWidth - padding : padding)
        artistButton!.frame = CGRect(origin: CGPoint(x: x, y: padding), size: artistButton!.frame.size)
    }
    
    
    
    func initButtons(width: CGFloat, _ heigth: CGFloat) {
        let x = (width < heigth ? bounds.width - buttonWidth - padding : padding)
        artistButton = HexaButton(x, padding, buttonWidth)
        artistButton!.setMainImage(UIImage(named: users[Int(arc4random_uniform(4))]))
        artistButton!.addTarget(self, action: "userButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(artistButton!)
    }
    
    
    
    func userButtonPressed(button: UIButton) {
        let userDetailViewController = ArtistDetailViewController()
        userDetailViewController.homeViewController = parentViewController!
        parentViewController!.presentViewController(userDetailViewController, animated: true, completion: nil)
    }
    
    
    
    func hideStatistic() {
        UIView.animateWithDuration(0.2, animations: {
            self.artistButton!.alpha = 0
        })
    }
    
    
    
    func showStatistic() {
        UIView.animateWithDuration(0.2, animations: {
            self.artistButton!.alpha = 1
        })
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  ArtView.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 29.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

class ArtView: UIImageView {
    let users = ["ann.jpg", "gal.jpg", "rah.jpg", "ste.jpg"]
    
    let padding: CGFloat = 10
    
    let buttonWidth: CGFloat = 50
    var artistButton: HexaButton?
    var shareButton: UIButton?
    var parentViewController: UIViewController?

    init(_ art: Art, _ length: CGFloat, _ width: CGFloat, _ heigth: CGFloat, _ parentViewController: UIViewController, _ deviceOrientationLandscape: Bool) {
        super.init()
        self.parentViewController = parentViewController
        
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
        self.frame = frame
        image = art.image
        
        let singleTap = UITapGestureRecognizer(target: art, action: "tapDetected:")
        singleTap.numberOfTapsRequired = 1
        userInteractionEnabled = true
        addGestureRecognizer(singleTap)
        initButtons(width, heigth)
    }
    
    
    
    func initButtons(width: CGFloat, _ heigth: CGFloat) {
        let x = (width < heigth ? bounds.width - buttonWidth - padding : padding)
        artistButton = HexaButton(x, padding, buttonWidth)
        artistButton!.setMainImage(UIImage(named: users[Int(arc4random_uniform(4))]))
        artistButton!.addTarget(self, action: "userButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(artistButton!)
        
        shareButton = UIButton()
        shareButton!.setTitle("...", forState: UIControlState.Normal)
        shareButton!.titleLabel!.font = UIFont(name: "Superclarendon-Bold", size: 35)
        shareButton!.titleLabel!.textColor = UIColor.whiteColor()
        shareButton!.sizeToFit()
        let newSize = CGSize(width: shareButton!.frame.width + padding * 2, height: shareButton!.frame.height)
        shareButton!.frame.size = newSize
        shareButton!.frame = CGRect(origin: CGPoint(x: self.bounds.width - shareButton!.frame.width, y: self.bounds.height - shareButton!.frame.height), size: shareButton!.frame.size)
        shareButton!.addTarget(self, action: "shareButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(shareButton!)
    }
    
    
    
    func userButtonPressed(button: UIButton) {
        let userDetailViewController = ArtistDetailViewController()
        userDetailViewController.homeViewController = parentViewController!
        parentViewController!.presentViewController(userDetailViewController, animated: true, completion: nil)
    }
    
    
    
    func shareButtonPressed(button: UIButton) {
        shareTextImageAndURL(sharingText: "HHHHHHH", sharingImage: image, sharingURL: NSURL(string: "https://www.cocoacontrols.com/"))
    }
    
    
    
    func shareTextImageAndURL(#sharingText: String?, sharingImage: UIImage?, sharingURL: NSURL?) {
        var sharingItems = [AnyObject]()
        
        if let text = sharingText {
            sharingItems.append(text)
        }
        if let image = sharingImage {
            sharingItems.append(image)
        }
        if let url = sharingURL {
            sharingItems.append(url)
        }
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        if iOS8Delta {
            activityViewController.popoverPresentationController!.sourceView = shareButton
        }
        parentViewController!.presentViewController(activityViewController, animated: true, completion: nil)
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

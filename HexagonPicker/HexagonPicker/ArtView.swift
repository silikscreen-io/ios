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
    
    let buttonWidth: CGFloat = 40
    var userButton: HexaButton?
    var statisticLabel: UILabel?
    var parentViewController: UIViewController?

    init(_ art: Art, _ y: CGFloat,_ width: CGFloat, _ parentViewController: UIViewController) {
        super.init()
        self.parentViewController = parentViewController
        
        let imageSize = art.image!.size
        let imageWidth = imageSize.width
        let imageHeight = imageSize.height
        let scaleFactor = imageSize.width / width
        let imageViewHeight = imageHeight / scaleFactor
        frame.origin.y = y
        frame.size = CGSize(width: width, height: imageViewHeight)
        self.frame = frame
        image = art.image
        
        let singleTap = UITapGestureRecognizer(target: art, action: "tapDetected:")
        singleTap.numberOfTapsRequired = 1
        userInteractionEnabled = true
        addGestureRecognizer(singleTap)
        
        statisticLabel = UILabel(frame: bounds)
        statisticLabel!.frame.origin.x += padding
        statisticLabel!.frame.origin.y += padding
        statisticLabel!.frame.size.height = 20
        statisticLabel!.text = "Location: \(art.location!.latitude), \(art.location!.longitude)"
        statisticLabel!.textColor = UIColor.magentaColor()
        addSubview(statisticLabel!)
        userButton = HexaButton(width - buttonWidth - padding, padding, buttonWidth)
        userButton!.setMainImage(UIImage(named: users[Int(arc4random_uniform(4))]))
        userButton!.addTarget(self, action: "userButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(userButton!)
    }
    
    
    
    func userButtonPressed(button: UIButton) {
        let userDetailViewController = UserDetailViewController()
        userDetailViewController.homeViewController = parentViewController!
        parentViewController!.presentViewController(userDetailViewController, animated: true, completion: nil)
    }
    
    
    
    func hideStatistic() {
        UIView.animateWithDuration(0.2, animations: {
            self.statisticLabel!.alpha = 0
            self.userButton!.alpha = 0
        })
    }
    
    
    
    func showStatistic() {
        UIView.animateWithDuration(0.2, animations: {
            self.statisticLabel!.alpha = 1
            self.userButton!.alpha = 1
        })
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

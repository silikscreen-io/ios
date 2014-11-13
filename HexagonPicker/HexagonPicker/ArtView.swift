//
//  ArtView.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 29.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

let queue = dispatch_queue_create("com.example.MyQueue", nil)
let users = ["ann.jpg", "gal.jpg", "rah.jpg", "ste.png", "vad.jpg"]
var buttonsLoadedNumber = 0

class ArtView: UIImageView {
    
    let padding: CGFloat = 10
    
    let buttonWidth: CGFloat = 34
    var artistButton: HexaButton?
    var parentViewController: UIViewController?
    
    var likeViewBottom: UIImageView?
    
    var art: Art?
    
    init(_ art: Art, _ length: CGFloat, _ width: CGFloat, _ heigth: CGFloat, _ parentViewController: UIViewController, _ deviceOrientationLandscape: Bool) {
        super.init()
        self.parentViewController = parentViewController
        self.art = art
        
        let imageSize = art.image == nil ? art.size : art.image!.size
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
        dispatch_async(dispatch_get_main_queue(), {
            self.image = art.image
        })
        addGestureRecognizers()
        if buttonsLoadedNumber < MAX_NUMBER_OF_LOADED_IMAGES {
            initButtons(width, heigth)
            buttonsLoadedNumber++
        }
    }
    
    
    
    func update(art: Art, _ deviceOrientationLandscape: Bool) {
        self.art = art
        image = art.image
        addGestureRecognizers()
    }
    
    
    
    func addGestureRecognizers() {
        let singleTap = UITapGestureRecognizer()
        singleTap.addTarget(self.art!, action: "tapDetected:")
        singleTap.numberOfTapsRequired = 1
        userInteractionEnabled = true
        addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: "doubleTapDetected:")
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        singleTap.requireGestureRecognizerToFail(doubleTap)
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
        if artistButton == nil {
            return
        }
        let x = (width < heigth ? bounds.width - buttonWidth - padding : padding)
        artistButton!.frame = CGRect(origin: CGPoint(x: x, y: padding), size: artistButton!.frame.size)
    }
    
    
    
    func initButtons(width: CGFloat, _ heigth: CGFloat) {
//        dispatch_async(dispatch_get_main_queue(), {
            let x = (width < heigth ? self.bounds.width - self.buttonWidth - self.padding : self.padding)
            let button = HexaButton(x, self.padding, self.buttonWidth)
            self.artistButton = button
            self.artistButton!.setMainImage(UIImage(named: users[Int(arc4random_uniform(5))]))
            self.artistButton!.addTarget(self, action: "artistButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            self.addSubview(self.artistButton!)
//            println("Artist button added         : \(NSDate().timeIntervalSince1970)")
//        })
    }
    
    
    
    func addButton() {
        initButtons(parentViewController!.view.frame.width, parentViewController!.view.frame.height)
    }
    
    
    
    func removeButton() {
        if artistButton != nil {
            artistButton!.removeFromSuperview()
            artistButton = nil
        }
    }
    
    
    
    func artistButtonPressed(button: UIButton) {
        let artistDetailViewController = ArtistDetailViewController()
        artistDetailViewController.artist = art!.artist
        parentViewController!.presentViewController(artistDetailViewController, animated: true, completion: nil)
    }
    
    
    func doubleTapDetected(recognizer: UITapGestureRecognizer) {
        if let index = find(currentUser!.likes, art!) {
            currentUser!.likes.removeAtIndex(index)
            if likeViewBottom != nil {
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.likeViewBottom!.alpha = 0
                }, completion: { (finished) -> Void in
                    self.likeViewBottom!.removeFromSuperview()
                })
            }
        } else {
            currentUser!.likes.append(art!)
            let hexagon = UIImage(named: "hexagon")!
            let ratio = hexagon.size.width / hexagon.size.height
            likeViewBottom = UIImageView(frame: CGRectMake(padding, frame.height - padding - 30, 30 * ratio, 30))
            likeViewBottom!.image = hexagon
            addSubview(likeViewBottom!)
            likeViewBottom!.alpha = 0
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.likeViewBottom!.alpha = 1
            })
            let likeView = UIImageView(image: UIImage(named: "like")!)
            var likeFrame = likeView.frame
            likeFrame.origin.x = (frame.width - likeFrame.width) / 2
            likeFrame.origin.y = 50
            likeView.frame = likeFrame
            addSubview(likeView)
            likeView.alpha = 0
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                likeView.alpha = 1
                }) { (finished) -> Void in
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        likeView.alpha = 0.99
                        }) { (finished) -> Void in
                            UIView.animateWithDuration(0.3, animations: { () -> Void in
                                likeView.alpha = 0
                                }) { (finished) -> Void in
                                    likeView.removeFromSuperview()
                            }
                    }
            }
        }
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

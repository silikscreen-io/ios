//
//  User.swift
//  Silkscreen
//
//  Created by Vlasov Illia on 04.11.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

var currentUser: User?

class User: NSObject {
    
    var username: String?
    var fullName: String?
    var profilePicture: UIImage?
    var icon: UIImage?
   
    
    init(_ data: NSDictionary) {
        super.init()
        username = data["username"] as? String
        fullName = data["full_name"] as? String
        let pictureUrlString = data["profile_picture"] as String
        let imageData = NSData(contentsOfURL: NSURL(string: pictureUrlString)!)
        profilePicture = UIImage(data: imageData!)
        initIcon()
    }
    
    
    
    func initIcon() {
        var offset = CGPoint()
        var ratio: CGFloat?
        var delta: CGFloat?
        var destinationSize = CGSize(width: 100, height: 100)
        let imageSize = self.profilePicture!.size
        
        ratio = destinationSize.width / imageSize.width;
        if imageSize.width > imageSize.height {
            delta = ratio! * (imageSize.width - imageSize.height);
            offset = CGPointMake(delta! / 2, 0);
        } else {
            delta = ratio! * (imageSize.height - imageSize.width);
            offset = CGPointMake(0, delta! / 2);
        }
        var clipRect = CGRectMake(-offset.x, -offset.y, (ratio! * imageSize.width) + delta!, (ratio! * imageSize.height) + delta!);
        
        if UIScreen.mainScreen().respondsToSelector("scale") {
            UIGraphicsBeginImageContextWithOptions(destinationSize, true, 0.0)
        } else {
            UIGraphicsBeginImageContext(destinationSize);
        }
        UIRectClip(clipRect)
        self.profilePicture!.drawInRect(clipRect)
        self.icon = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
    }
    
}

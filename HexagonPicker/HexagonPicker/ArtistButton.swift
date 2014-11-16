//
//  ArtistButton.swift
//  Silkscreen
//
//  Created by Vlasov Illia on 16.11.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

class ArtistButton: HexaButton {
    
    var parentViewController: UIViewController?
    var artist: Artist?
    
    
    
    init(_ x: CGFloat, _ y: CGFloat, _ size: CGSize, _ artist: Artist, _ parentViewController: UIViewController) {
        super.init(frame: CGRect(origin: CGPoint(x: x, y: y), size: size))
        self.artist = artist
        self.parentViewController = parentViewController
        self.addTarget(self, action: "pressed", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    
    
    func pressed() {
        let artistDetailViewController = ArtistDetailViewController()
        artistDetailViewController.artist = artist
        parentViewController!.presentViewController(artistDetailViewController, animated: true, completion: nil)
    }

    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//
//  ArtView.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 29.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

class ArtView: UIImageView {
    
    let labelPadding: CGFloat = 10
    
    var statisticLabel: UILabel?

    init(_ art: Art, _ y: CGFloat,_ width: CGFloat) {
        super.init()
        
        
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
        statisticLabel!.frame.origin.x += labelPadding
        statisticLabel!.frame.origin.y += labelPadding
        statisticLabel!.frame.size.height = 20
        statisticLabel!.text = "Location: \(art.location!.latitude), \(art.location!.longitude)"
        statisticLabel!.textColor = UIColor.magentaColor()
        addSubview(statisticLabel!)
    }
    
    
    
    func hideStatistic() {
        UIView.animateWithDuration(0.2, animations: {
            self.statisticLabel!.alpha = 0
        })
    }
    
    
    
    func showStatistic() {
        UIView.animateWithDuration(0.2, animations: {
            self.statisticLabel!.alpha = 1
        })
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

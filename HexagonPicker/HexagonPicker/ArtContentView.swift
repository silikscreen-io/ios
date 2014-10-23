//
//  ArtContentView.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 23.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

class ArtContentView: UIVisualEffectView {
    class var CONTENT_ID: String { get { return "content" } }
    class var SOCIAL_ID: String { get { return "social" } }
    
    let buttonSize: CGSize = CGSize(width: 40, height: 40)
    let buttonsDescription = ["audio", "video", "email"]
    var buttons: [String: [UIButton]] = [ArtContentView.CONTENT_ID : [], ArtContentView.SOCIAL_ID : []]
    
    let topPadding = UIApplication.sharedApplication().statusBarFrame.size.height
    let xPadding: CGFloat = 10
    let yPadding: CGFloat = 5
    
    
    var descriptionLabel: UILabel!
    var lineViews: [UIView] = []
    
    
    init(_ backgroundView: UIView, _ frame: CGRect, _ displayed: Bool) {
        super.init(effect: UIBlurEffect(style: .Light))
        self.frame = frame
        hidden = !displayed
        alpha = hidden ? 0 : 1
        backgroundView.addSubview(self)
    }
    
    
    
    func show(displayed: Bool) {
        let alpha: CGFloat = displayed ? 1 : 0
        UIView.animateWithDuration(0.4, animations: { self.alpha = alpha })
        if self.hidden && displayed{
            self.hidden = !displayed
        }
    }
    
    
    func addDescription(description: String) {
        descriptionLabel = UILabel()
        descriptionLabel.text = description
        alignDescription()
        addSubview(descriptionLabel)
        addLine(descriptionLabel.frame.origin.y + descriptionLabel.frame.height + yPadding)
    }
    
    
    
    func alignDescription() {
        descriptionLabel.frame = CGRect(origin: CGPoint(x: bounds.origin.x + xPadding, y: bounds.origin.y + yPadding + topPadding), size: CGSize(width: bounds.width - 2 * xPadding, height: bounds.height - 2 * yPadding))
        descriptionLabel.textAlignment = NSTextAlignment.Center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.sizeToFit()
        if descriptionLabel.frame.width < bounds.width - 2 * xPadding {
            descriptionLabel.frame.origin.x = (bounds.width - descriptionLabel.frame.width) / 2
        }
    }
    
    
    
    func addLine(position: CGFloat) {
        let lineView = UIView()
        setLinePosition(lineView, position)
        lineView.backgroundColor = UIColor.blackColor()
        addSubview(lineView)
        lineViews.append(lineView)
    }
    
    
    
    func setLinePosition(line: UIView, _ position: CGFloat) {
        line.frame = CGRect(origin: CGPoint(x: bounds.origin.x, y: position), size: CGSize(width: bounds.width, height: 2))
    }
    
    
    
    func addButton(type: String) {
        var yPadding = bounds.origin.y + self.yPadding + topPadding
        var frame = CGRect(origin: CGPoint(x: bounds.origin.x + xPadding, y: yPadding), size: buttonSize)
        let index = Int(arc4random_uniform(2))
        let imageName = buttonsDescription[index]
        var button = UIButton(frame: frame)
        button.setImage(UIImage(named: imageName + "_b.png"), forState: UIControlState.Normal)
        button.setImage(UIImage(named: imageName + "_w.png"), forState: UIControlState.Highlighted)
        addSubview(button)
        buttons[type]!.append(button)
        
        if type == ArtContentView.CONTENT_ID {
            if lineViews.count > 0 {
                yPadding = lineViews[0].frame.origin.y + self.yPadding
            }
            updateButtons(type, yPadding)
        } else {
        }
    }
    
    
    
    func updateButtons(type: String, _ yPadding: CGFloat) {
        let buttonsCount = CGFloat(buttons[type]!.count)
        var buttonsXPadding = (bounds.width - buttonsCount * buttonSize.width) / (buttonsCount + 1)
        var buttonX = buttonsXPadding
        for index in 0...Int(buttonsCount - 1) {
            let button = buttons[type]![index]
            button.frame.origin.x = buttonX
            button.frame.origin.y = yPadding
            buttonX += buttonsXPadding + buttonSize.width
        }
    }
    
    
    
    func updateToFrame(frame: CGRect) {
        self.frame = frame
        updateSubviews()
    }
    
    
    
    func updateSubviews() {
        var yPadding = bounds.origin.y + self.yPadding + topPadding
        if descriptionLabel != nil {
            alignDescription()
            setLinePosition(lineViews[0], descriptionLabel.frame.origin.y + descriptionLabel.frame.height + yPadding)
            yPadding = lineViews[0].frame.origin.y + self.yPadding
        }
        updateButtons(ArtContentView.CONTENT_ID, yPadding)
    }
    
    

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//
//  ArtShareMenuView.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 28.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

class ArtShareMenuView: UIView {
    
    let buttonsDescription = ["audio", "video", "email"]

    let menuHeight: CGFloat = 240
    let cancelButtonHeight: CGFloat = 30
    let scrollViewHeight: CGFloat = 80
    
    var baseFrame: CGRect?
    var fakeView: UIView?
    var toolbar: UIToolbar!
    
    var topScrollView: UIScrollView?
    var middleScrollView: UIScrollView?
    var bottomScrollView: UIScrollView?
    
    var panRecognizer: UIPanGestureRecognizer?
    var panY: CGFloat?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    
    init(_ parentView: UIView) {
        super.init()
        initPan()
        
        baseFrame = parentView.frame
        
        fakeView = UIView(frame: baseFrame!)

        initToolbar()
        initToolbarButtonCancel()
        initLines()
        initScrollViews()
        
        self.frame = CGRect(origin: CGPoint(), size: CGSize(width: baseFrame!.width, height: fakeView!.frame.height + toolbar!.frame.height))
        
        parentView.addSubview(self)
        addSubview(fakeView!)
        addSubview(toolbar!)
        hidden = true
    }
    
    
    
    func initPan() {
        userInteractionEnabled = true
        panRecognizer = UIPanGestureRecognizer(target: self, action: "panRecognized:")
        addGestureRecognizer(panRecognizer!)
    }
    
    
    
    func panRecognized(panRecognizer: UIPanGestureRecognizer) {
        let currentY = panRecognizer.locationInView(toolbar).y
        if panY == nil {
            panY = currentY
        } else {
            if currentY > panY {
                hide()
                println("panRecognized Hide")
                panY = nil
                removeGestureRecognizer(panRecognizer)
            }
        }
        if ((panRecognizer.state == UIGestureRecognizerState.Ended) || (panRecognizer.state == UIGestureRecognizerState.Cancelled)) {
            panY = nil
        }
    }
    
    
    
    func initToolbar() {
        var toolbarFrame = baseFrame!
        toolbarFrame.origin.y = toolbarFrame.height
        toolbarFrame.size.height = menuHeight + cancelButtonHeight
        toolbar = UIToolbar(frame: toolbarFrame)
    }
    
    
    
    func initToolbarButtonCancel() {
        var toolbarFrame = toolbar!.frame
        var button = UIButton(frame: CGRect(x: 0, y: toolbarFrame.height - cancelButtonHeight, width: toolbarFrame.width, height: cancelButtonHeight))
        button.addTarget(self, action: "cancelPressed", forControlEvents: UIControlEvents.TouchUpInside)
        button.setTitle("Cancel", forState: UIControlState.Normal)
        toolbar.addSubview(button)
    }
    
    
    
    func initLines() {
        addLine(menuHeight / 3)
        addLine(menuHeight * 2 / 3)
    }
    
    
    
    func addLine(position: CGFloat) {
        let lineView = UIView()
        lineView.frame = CGRect(origin: CGPoint(x: 0, y: position), size: CGSize(width: toolbar!.frame.width, height: 1))
        lineView.backgroundColor = UIColor.blackColor()
        toolbar!.addSubview(lineView)
    }
    
    
    
    func initScrollViews() {
        let scrollViewWidth = toolbar.frame.width
        let scrollViewSize = CGSize(width: scrollViewWidth, height: scrollViewHeight)
        topScrollView = UIScrollView()
        initScrollView(&topScrollView!, 0, scrollViewSize)
        
        middleScrollView = UIScrollView()
        initScrollView(&middleScrollView!, scrollViewHeight, scrollViewSize)
        
        bottomScrollView = UIScrollView()
        initScrollView(&bottomScrollView!, scrollViewHeight * 2, scrollViewSize)
        addButtons()
    }
    
    
    
    func addButtons() {
        let yPadding: CGFloat = 5
        let xPadding: CGFloat = 5
        let buttonWidth = scrollViewHeight - yPadding - xPadding
        let buttonSize = CGSize(width: buttonWidth, height: buttonWidth)
        
        var frame = CGRect(origin: CGPoint(x: xPadding, y: yPadding), size: buttonSize)
        
        let index = Int(arc4random_uniform(3))
        let imageName = buttonsDescription[index]
        var button = UIButton(frame: frame)
        button.setImage(UIImage(named: imageName + "_b.png"), forState: UIControlState.Normal)
        button.setImage(UIImage(named: imageName + "_w.png"), forState: UIControlState.Highlighted)
        topScrollView!.addSubview(button)
        
        var contentSize: CGFloat = 0
        for buttonIndex in 0...10 {
            frame = CGRect(origin: CGPoint(x: xPadding * (1 + CGFloat(buttonIndex)) + buttonWidth * CGFloat(buttonIndex), y: yPadding), size: buttonSize)
            
            let index = Int(arc4random_uniform(3))
            let imageName = buttonsDescription[index]
            var button = UIButton(frame: frame)
            button.setImage(UIImage(named: imageName + "_b.png"), forState: UIControlState.Normal)
            button.setImage(UIImage(named: imageName + "_w.png"), forState: UIControlState.Highlighted)
            middleScrollView!.addSubview(button)
        }
        contentSize = frame.origin.x + frame.width
        middleScrollView!.contentSize = CGSize(width: contentSize + xPadding, height: scrollViewHeight)
    }
    
    
    
    func initScrollView(inout scrollView: UIScrollView, _ y: CGFloat, _ scrollViewSize: CGSize) {
        scrollView.frame = CGRect(origin: CGPoint(x: 0, y: y), size: scrollViewSize)
        scrollView.contentSize = scrollViewSize
        scrollView.showsHorizontalScrollIndicator = false
        toolbar!.addSubview(scrollView)
    }
    
    
    
    func cancelPressed() {
        hide()
    }
    
    
    
    func updateFrame(frame: CGRect) {
        baseFrame = frame
        var newFrame = frame
        newFrame.size.height += 330
        self.frame = newFrame
    }
    
    
    
    func show() {
        hidden = false
        UIView.animateWithDuration(0.2, animations: {
            self.frame.origin.y -= self.toolbar!.frame.height
            }) { (Bool) -> Void in
                self.addGestureRecognizer(self.panRecognizer!)
        }
    }
    
    
    
    func hide() {
        UIView.animateWithDuration(0.2, animations: {
            self.frame.origin.y += self.toolbar!.frame.height
            }) { (Bool) -> Void in
                self.hidden = true
        }
    }

    
    
    func update(frame: CGRect) {
        baseFrame = frame
        fakeView!.frame = baseFrame!
        var toolbarFrame = baseFrame!
        toolbarFrame.origin.y = toolbarFrame.height
        toolbarFrame.size.height = menuHeight + cancelButtonHeight
        toolbar!.frame = toolbarFrame
        let toolbarWidth = toolbar!.frame.width
        for view in toolbar!.subviews as [UIView] {
            view.frame.size.width = toolbarWidth
        }
    }
    
    
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        if (CGRectContainsPoint(fakeView!.frame, point)) {
            hide()
        }
        return true
    }

    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

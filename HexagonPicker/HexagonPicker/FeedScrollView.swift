//
//  FeedScrollView.swift
//  HexagonPicker
//
//  Created by Vlasov Illia on 24.10.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

protocol FeedScrollViewDelegate {
    func swipeUp()
    func swipeDown()
}

class FeedScrollView: UIScrollView {
    let verticalSpeedDragMax = 4
    var startTouchPositionY: CGFloat?
    
    var feedDelegate: FeedScrollViewDelegate?
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        startTouchPositionY = (touches.anyObject() as UITouch).locationInView(self).y
    }
    
    
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        var currentPositionY = (touches.anyObject() as UITouch).locationInView(self).y
        var speedY = fabs(Double(currentPositionY - self.startTouchPositionY!))
        if currentPositionY < self.startTouchPositionY {
            if speedY > 8 {
                feedDelegate!.swipeUp()
            }
        } else {
            if speedY > 20 {
                feedDelegate!.swipeDown()
            }
        }
    }
}
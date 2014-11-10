//
//  TransitionAnimator.swift
//  Silkscreen
//
//  Created by Vlasov Illia on 10.11.14.
//  Copyright (c) 2014 vaisoft. All rights reserved.
//

import UIKit

class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var presenting = true
    
    
    
    init(_ presenting: Bool = true) {
        super.init()
        self.presenting = presenting
    }
    
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.5
    }
    
    
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        var endFrame = fromViewController!.view.frame
        var startFrame = fromViewController!.view.frame
        if self.presenting {
            startFrame.origin.y = -startFrame.height
            toViewController!.view.frame = startFrame
            let inView = transitionContext.containerView()
            inView.addSubview(toViewController!.view)
            UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
                toViewController!.view.frame = endFrame
                }) { (finished) -> Void in
                    transitionContext.completeTransition(true)
            }
        } else {
            endFrame.origin.y = -startFrame.height
            fromViewController!.view.frame = startFrame
            UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
                fromViewController!.view.frame = endFrame
                }) { (finished) -> Void in
                    transitionContext.completeTransition(true)
            }
        }
    }
   
}

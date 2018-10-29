//
//  PushAnimator.swift
//  MaCherie
//
//  Created by Leon Li on 2018/6/15.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

import UIKit

class PushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        transitionContext.containerView.addSubview(toView)
        
        toView.frame = fromView.frame
        toView.frame.origin.x += fromView.frame.width
//        toView.alpha = 0
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseOut,
            animations: {
                toView.frame = fromView.frame
//                toView.alpha = 1
                
                fromView.frame.origin.x -= fromView.frame.width
//                fromView.alpha = 0
            },
            completion: { finished in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}

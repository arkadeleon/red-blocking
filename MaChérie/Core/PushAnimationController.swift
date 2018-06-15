//
//  PushAnimationController.swift
//  HuaBan-iOS
//
//  Created by Leon Li on 19/12/2017.
//  Copyright © 2017 Feiguo. All rights reserved.
//

import UIKit

class PushAnimationController: NSObject {
    enum Direction: Int {
        case top
        case left
        case bottom
        case right
    }
    
    private var direction: Direction
    
    init(direction: Direction) {
        self.direction = direction
        super.init()
    }
}

extension PushAnimationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from) else {
            return
        }
        
        let fromViewControllerInitialFrame = transitionContext.initialFrame(for: fromViewController)
        var fromViewControllerFinalFrame = fromViewControllerInitialFrame
        
        switch direction {
        case .top:
            fromViewControllerFinalFrame.origin.y += fromViewControllerFinalFrame.width
        case .left:
            fromViewControllerFinalFrame.origin.x += fromViewControllerFinalFrame.width
        case .bottom:
            fromViewControllerFinalFrame.origin.y -= fromViewControllerFinalFrame.width
        case .right:
            fromViewControllerFinalFrame.origin.x -= fromViewControllerFinalFrame.width
        }
        
        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let toViewControllerFinalFrame = transitionContext.finalFrame(for: toViewController)
        var toViewControllerInitialFrame = toViewControllerFinalFrame
        
        switch direction {
        case .top:
            toViewControllerInitialFrame.origin.y -= toViewControllerInitialFrame.width
        case .left:
            toViewControllerInitialFrame.origin.x -= toViewControllerInitialFrame.width
        case .bottom:
            toViewControllerInitialFrame.origin.y += toViewControllerInitialFrame.width
        case .right:
            toViewControllerInitialFrame.origin.x += toViewControllerInitialFrame.width
        }
        
        toViewController.view.frame = toViewControllerInitialFrame
        transitionContext.containerView.addSubview(toViewController.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
            fromViewController.view.frame = fromViewControllerFinalFrame
            toViewController.view.frame = toViewControllerFinalFrame
        }) { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

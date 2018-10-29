//
//  PopInteractor.swift
//  MaCherie
//
//  Created by Leon Li on 2018/6/15.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

import UIKit

class PopInteractor: UIPercentDrivenInteractiveTransition {
    var navigationController: UINavigationController
    var shouldCompleteTransition = false
    var transitionInProgress = false
    
    init?(attachTo viewController : UIViewController) {
        if let navigationController = viewController.navigationController {
            self.navigationController = navigationController
            super.init()
            setupBackGesture(view: viewController.view)
        } else {
            return nil
        }
    }
    
    private func setupBackGesture(view : UIView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleBackGesture(_:)))
        view.addGestureRecognizer(pan)
    }
    
    @objc private func handleBackGesture(_ gesture : UIPanGestureRecognizer) {
        let viewTranslation = gesture.translation(in: gesture.view?.superview)
        guard viewTranslation.x > 0 else {
            cancel()
            return
        }
        let progress = viewTranslation.x / navigationController.view.frame.width
        
        switch gesture.state {
        case .began:
            transitionInProgress = true
            navigationController.popViewController(animated: true)
            break
        case .changed:
            shouldCompleteTransition = progress > 0.1
            update(progress)
            break
        case .cancelled:
            transitionInProgress = false
            cancel()
            break
        case .ended:
            transitionInProgress = false
            shouldCompleteTransition ? finish() : cancel()
            break
        default:
            return
        }
    }
}

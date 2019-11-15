//
//  AppDelegate.swift
//  MaCherie
//
//  Created by Leon Li on 2018/6/14.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var popInteractor: PopInteractor?
    
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let splitViewController = window!.rootViewController as! UISplitViewController
        splitViewController.delegate = self
        (splitViewController.viewControllers[0] as! UINavigationController).delegate = self
        (splitViewController.viewControllers[1] as! UINavigationController).delegate = self

        UserDefaults.standard.register(defaults: [
            Player1PassiveHitboxHiddenKey : false,
            Player1OtherVulnerabilityHitboxHiddenKey : false,
            Player1ActiveHitboxHiddenKey : false,
            Player1ThrowHitboxHiddenKey : false,
            Player1ThrowableHitboxHiddenKey : false,
            Player1PushHitboxHiddenKey : false,
            Player2PassiveHitboxHiddenKey : true,
            Player2OtherVulnerabilityHitboxHiddenKey : true,
            Player2ActiveHitboxHiddenKey : true,
            Player2ThrowHitboxHiddenKey : true,
            Player2ThrowableHitboxHiddenKey : true,
            Player2PushHitboxHiddenKey : true,
            PreferredPassiveHitboxRGBColorKey : 0x0000FF,
            PreferredOtherVulnerabilityHitboxRGBColorKey : 0x007FFF,
            PreferredActiveHitboxRGBColorKey : 0xFF0000,
            PreferredThrowHitboxRGBColorKey : 0xFF7F00,
            PreferredThrowableHitboxRGBColorKey : 0x00FF00,
            PreferredPushHitboxRGBColorKey : 0x7F00FF,
            PreferredFramesPerSecondKey : 30
        ])
        
        return true
    }
}

extension AppDelegate: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        let detailViewController = (secondaryViewController as! UINavigationController).topViewController as! CharacterMovesViewController
        if detailViewController.sections.count == 0 {
            return true
        } else {
            return false
        }
    }
}

extension AppDelegate: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            popInteractor = PopInteractor(attachTo: toVC)
            return PushAnimator()
        case .pop:
            return PopAnimator()
        case .none:
            return nil
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let popInteractor = popInteractor, popInteractor.transitionInProgress {
            return popInteractor
        } else {
            return nil
        }
    }
}

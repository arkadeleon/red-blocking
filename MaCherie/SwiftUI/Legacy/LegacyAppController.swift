//
//  LegacyAppController.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import UIKit

@MainActor
final class LegacyAppController: NSObject {
    static let shared = LegacyAppController()

    private var popInteractor: PopInteractor?

    func makeRootViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        guard let rootViewController = storyboard.instantiateInitialViewController(),
              let splitViewController = rootViewController as? UISplitViewController else {
            fatalError("Expected Main.storyboard to load a UISplitViewController root.")
        }

        configure(splitViewController)
        return splitViewController
    }

    func configure(_ rootViewController: UIViewController) {
        guard let splitViewController = rootViewController as? UISplitViewController else {
            return
        }

        splitViewController.delegate = self
        splitViewController.preferredDisplayMode = .oneBesideSecondary

        guard splitViewController.viewControllers.count >= 2,
              let primaryNavigationController = splitViewController.viewControllers[0] as? UINavigationController,
              let secondaryNavigationController = splitViewController.viewControllers[1] as? UINavigationController else {
            return
        }

        primaryNavigationController.delegate = self
        secondaryNavigationController.delegate = self
    }
}

extension LegacyAppController: UISplitViewControllerDelegate {
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController
    ) -> Bool {
        let detailViewController = (secondaryViewController as! UINavigationController).topViewController as! CharacterMovesViewController
        return detailViewController.sections.isEmpty
    }
}

extension LegacyAppController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            popInteractor = PopInteractor(attachTo: toVC)
            return PushAnimator()
        case .pop:
            return PopAnimator()
        case .none:
            return nil
        @unknown default:
            assertionFailure("Unhandled navigation operation: \(operation.rawValue)")
            return nil
        }
    }

    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        guard let popInteractor, popInteractor.transitionInProgress else {
            return nil
        }

        return popInteractor
    }
}

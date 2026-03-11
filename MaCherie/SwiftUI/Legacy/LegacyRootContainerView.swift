//
//  LegacyRootContainerView.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI
import UIKit

struct LegacyRootContainerView: UIViewControllerRepresentable {
    let controller: LegacyAppController

    func makeUIViewController(context: Context) -> UIViewController {
        controller.makeRootViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        controller.configure(uiViewController)
    }
}

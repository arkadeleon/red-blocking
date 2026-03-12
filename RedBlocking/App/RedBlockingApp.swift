//
//  RedBlockingApp.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

@main
struct RedBlockingApp: App {
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RedBlockingRootView()
                .environment(appModel)
        }
    }
}

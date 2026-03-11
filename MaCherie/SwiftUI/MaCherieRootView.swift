//
//  MaCherieRootView.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MaCherieRootView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        LegacyRootContainerView(controller: appModel.legacyAppController)
            .ignoresSafeArea()
    }
}

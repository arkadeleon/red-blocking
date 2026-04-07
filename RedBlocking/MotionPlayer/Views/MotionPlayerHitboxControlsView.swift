//
//  MotionPlayerHitboxControlsView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MotionPlayerHitboxControlsView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        @Bindable var visibility = appModel.settings.hitboxVisibility

        VStack(alignment: .leading, spacing: 16) {
            Text("Hitbox")
                .redBlockingSectionTag(prominent: true)

            MotionPlayerHitboxVisibilityGroupView(
                title: "Player 1",
                startsExpanded: true,
                passiveColorRGB: appModel.settings.hitboxColors.passiveRGB,
                passiveVisible: $visibility.player1PassiveVisible,
                otherVulnerabilityColorRGB: appModel.settings.hitboxColors.otherVulnerabilityRGB,
                otherVulnerabilityVisible: $visibility.player1OtherVulnerabilityVisible,
                activeColorRGB: appModel.settings.hitboxColors.activeRGB,
                activeVisible: $visibility.player1ActiveVisible,
                throwColorRGB: appModel.settings.hitboxColors.throwRGB,
                throwVisible: $visibility.player1ThrowVisible,
                throwableColorRGB: appModel.settings.hitboxColors.throwableRGB,
                throwableVisible: $visibility.player1ThrowableVisible,
                pushColorRGB: appModel.settings.hitboxColors.pushRGB,
                pushVisible: $visibility.player1PushVisible
            )

            MotionPlayerHitboxVisibilityGroupView(
                title: "Player 2",
                startsExpanded: false,
                passiveColorRGB: appModel.settings.hitboxColors.passiveRGB,
                passiveVisible: $visibility.player2PassiveVisible,
                otherVulnerabilityColorRGB: appModel.settings.hitboxColors.otherVulnerabilityRGB,
                otherVulnerabilityVisible: $visibility.player2OtherVulnerabilityVisible,
                activeColorRGB: appModel.settings.hitboxColors.activeRGB,
                activeVisible: $visibility.player2ActiveVisible,
                throwColorRGB: appModel.settings.hitboxColors.throwRGB,
                throwVisible: $visibility.player2ThrowVisible,
                throwableColorRGB: appModel.settings.hitboxColors.throwableRGB,
                throwableVisible: $visibility.player2ThrowableVisible,
                pushColorRGB: appModel.settings.hitboxColors.pushRGB,
                pushVisible: $visibility.player2PushVisible
            )
        }
        .padding(16)
        .redBlockingPanel(cornerRadius: 22)
    }
}

#Preview("Motion Player Hitbox Controls") {
    let appModel = PreviewAppModel.rootNavigation()

    return MotionPlayerHitboxControlsView()
        .environment(appModel)
        .padding()
        .background(Color.rbCoal)
}

//
//  MotionCanvasView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MotionCanvasView: View {
    let motionFrame: MotionFrame
    let hitboxVisibilitySettings: HitboxVisibilitySettings
    let hitboxColorSettings: HitboxColorSettings

    var body: some View {
        let configuration = MotionCanvasConfiguration(
            hitboxVisibilitySettings: hitboxVisibilitySettings,
            hitboxColorSettings: hitboxColorSettings
        )
        let renderer = MotionCanvasRenderer(configuration: configuration)

        Canvas(opaque: false, rendersAsynchronously: true) { context, size in
            renderer.render(motionFrame: motionFrame, in: &context, size: size)
        }
        .aspectRatio(MotionCanvasRenderer.aspectRatio, contentMode: .fit)
        .background(Color.rbCanvas, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

//
//  MotionPlayerSpeedControlsView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/4/4.
//

import SwiftUI

struct MotionPlayerSpeedControlsView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Binding private var framesPerSecond: Int
    @State private var showsSpeedControls = false

    init(framesPerSecond: Binding<Int>) {
        _framesPerSecond = framesPerSecond
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: toggleSpeedControls) {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text("Speed")
                            .redBlockingSectionTag()

                        Text(speedSummary)
                            .font(.subheadline.weight(.medium))
                            .redBlockingText(.secondary)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .contentTransition(reduceMotion ? .identity : .numericText())

                        Spacer(minLength: 12)

                        chevron
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 12) {
                            Text("Speed")
                                .redBlockingSectionTag()

                            Spacer(minLength: 12)

                            chevron
                        }

                        Text(speedSummary)
                            .font(.subheadline.weight(.medium))
                            .redBlockingText(.secondary)
                            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
                            .fixedSize(horizontal: false, vertical: true)
                            .contentTransition(reduceMotion ? .identity : .numericText())
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .redBlockingControlSurface(cornerRadius: 18)
                .contentShape(Rectangle())
            }
            .buttonStyle(RedBlockingPressableButtonStyle())
            .accessibilityValue(showsSpeedControls ? "Expanded" : "Collapsed")
            .accessibilityHint(showsSpeedControls ? "Collapses the speed controls." : "Expands the speed controls.")

            if showsSpeedControls {
                MotionPlayerFPSEditorView(framesPerSecond: $framesPerSecond)
                    .transition(.opacity.combined(with: .scale(scale: 0.985, anchor: .top)))
            }
        }
    }

    private var speedSummary: String {
        if framesPerSecond == 0 {
            return "0 FPS"
        }

        return "\(framesPerSecond) FPS"
    }

    private var chevron: some View {
        Image(systemName: "chevron.down")
            .font(.caption.weight(.bold))
            .redBlockingText(.accentSoft)
            .rotationEffect(.degrees(showsSpeedControls ? -180 : 0))
    }

    private func toggleSpeedControls() {
        if reduceMotion {
            showsSpeedControls.toggle()
        } else {
            withAnimation(.snappy(duration: 0.26, extraBounce: 0)) {
                showsSpeedControls.toggle()
            }
        }
    }
}

#Preview("Speed Controls") {
    @Previewable @State var framesPerSecond = 30

    return MotionPlayerSpeedControlsView(framesPerSecond: $framesPerSecond)
        .padding()
        .background(Color.rbCoal)
}

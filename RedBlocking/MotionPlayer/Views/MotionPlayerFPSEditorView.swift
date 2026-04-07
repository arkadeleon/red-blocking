//
//  MotionPlayerFPSEditorView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/4/4.
//

import SwiftUI

struct MotionPlayerFPSEditorView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Binding private var framesPerSecond: Int

    init(framesPerSecond: Binding<Int>) {
        _framesPerSecond = framesPerSecond
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: 12) {
                label
                    .fixedSize(horizontal: true, vertical: false)

                Spacer(minLength: 8)

                HStack(spacing: 10) {
                    field(alignment: .trailing)
                        .frame(width: compactFieldWidth)

                    stepper
                }
                .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .redBlockingControlSurface(cornerRadius: 18)

            VStack(alignment: .leading, spacing: 12) {
                label

                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .center, spacing: 10) {
                        field(alignment: .leading)
                        stepper
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        field(alignment: .leading)
                        stepper
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .redBlockingControlSurface(cornerRadius: 18)
        }
    }

    private var label: some View {
        Text("FPS")
            .font(.subheadline.weight(.medium))
            .redBlockingText(.secondary)
    }

    private func field(alignment: TextAlignment) -> some View {
        TextField("Frames Per Second", value: $framesPerSecond, format: .number)
            .textFieldStyle(.plain)
            .multilineTextAlignment(alignment)
            .keyboardType(.numberPad)
            .padding(.horizontal, 10)
            .frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 48 : 40)
            .redBlockingControlSurface(cornerRadius: 14)
            .accessibilityLabel("Frames Per Second")
    }

    private var stepper: some View {
        Stepper("Frames Per Second", value: $framesPerSecond, in: PlaybackSettings.supportedFPSRange)
            .labelsHidden()
            .accessibilityLabel("Frames Per Second")
            .fixedSize(horizontal: true, vertical: false)
    }

    private var compactFieldWidth: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 104 : 84
    }
}

#Preview("Motion Player FPS Editor") {
    @Previewable @State var framesPerSecond = 30

    return MotionPlayerFPSEditorView(framesPerSecond: $framesPerSecond)
        .padding()
        .background(Color.rbCoal)
}

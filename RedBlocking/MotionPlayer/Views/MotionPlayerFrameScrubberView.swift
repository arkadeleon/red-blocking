//
//  MotionPlayerFrameScrubberView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/4/4.
//

import SwiftUI

struct MotionPlayerFrameScrubberView: View {
    let currentFrameIndex: Int
    let totalFrames: Int
    let onScrubbingChanged: (Bool) -> Void
    let onSeek: (Int) -> Void

    @Binding private var scrubbedFrame: Double
    @Binding private var isScrubbing: Bool

    private let frameNumberFormat = IntegerFormatStyle<Int>.number
        .grouping(.never)
        .precision(.integerLength(3...))

    init(
        currentFrameIndex: Int,
        totalFrames: Int,
        scrubbedFrame: Binding<Double>,
        isScrubbing: Binding<Bool>,
        onScrubbingChanged: @escaping (Bool) -> Void,
        onSeek: @escaping (Int) -> Void
    ) {
        self.currentFrameIndex = currentFrameIndex
        self.totalFrames = totalFrames
        self.onScrubbingChanged = onScrubbingChanged
        self.onSeek = onSeek
        _scrubbedFrame = scrubbedFrame
        _isScrubbing = isScrubbing
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text("Frame Position")
                        .font(.subheadline.weight(.medium))
                        .redBlockingText(.secondary)

                    Spacer(minLength: 12)

                    Text("\(formattedFrame(displayedFrameNumber)) / \(formattedFrame(totalFrames))")
                        .font(.headline.monospacedDigit().weight(.semibold))
                        .redBlockingText(.primary)
                }

                if totalFrames > 1 {
                    Slider(
                        value: $scrubbedFrame,
                        in: 0...Double(totalFrames - 1),
                        step: 1,
                        onEditingChanged: onScrubbingChanged
                    )
                    .accessibilityLabel("Frame Position")
                    .accessibilityValue("Frame \(formattedFrame(displayedFrameNumber)) of \(formattedFrame(totalFrames))")
                    .onChange(of: scrubbedFrame) { _, newValue in
                        guard isScrubbing else {
                            return
                        }

                        onSeek(Int(newValue))
                    }

                    HStack {
                        Text(formattedFrame(1))
                        Spacer()
                        Text(formattedFrame(totalFrames))
                    }
                    .font(.caption.monospacedDigit())
                    .redBlockingText(.secondary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .redBlockingControlSurface(cornerRadius: 18, highlighted: true)
        }
    }

    private var displayedFrameNumber: Int {
        guard totalFrames > 0 else {
            return 0
        }

        return min(max(currentFrameIndex + 1, 1), totalFrames)
    }

    private func formattedFrame(_ frame: Int) -> String {
        frame.formatted(frameNumberFormat)
    }
}

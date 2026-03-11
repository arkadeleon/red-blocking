//
//  MotionCanvasRenderer.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import CoreGraphics
import SwiftUI

struct MotionCanvasRenderer {
    static let frameSize = CGSize(width: 384, height: 224)
    static let aspectRatio = frameSize.width / frameSize.height

    let configuration: MotionCanvasConfiguration

    func render(
        motionFrame: MotionFrame,
        in context: inout GraphicsContext,
        size: CGSize
    ) {
        guard size.width > 0, size.height > 0 else {
            return
        }

        let canvasRect = CGRect(origin: .zero, size: size)
        let scaleX = size.width / Self.frameSize.width
        let scaleY = size.height / Self.frameSize.height

        context.withCGContext { cgContext in
            drawFrameImage(
                motionFrame.resource.cgImage,
                in: cgContext,
                canvasRect: canvasRect
            )

            if configuration.player1PassiveVisible {
                drawHitboxes(
                    motionFrame.player1.hitboxes.passive,
                    hitboxesToDraw: motionFrame.player1.hitboxes.passiveToDraw,
                    rgb: configuration.passiveRGB,
                    scaleX: scaleX,
                    scaleY: scaleY,
                    in: cgContext
                )
            }

            if configuration.player1OtherVulnerabilityVisible {
                drawHitboxes(
                    motionFrame.player1.hitboxes.otherVulnerability,
                    hitboxesToDraw: motionFrame.player1.hitboxes.otherVulnerabilityToDraw,
                    rgb: configuration.otherVulnerabilityRGB,
                    scaleX: scaleX,
                    scaleY: scaleY,
                    in: cgContext
                )
            }

            if configuration.player1ActiveVisible {
                drawHitboxes(
                    motionFrame.player1.hitboxes.active,
                    hitboxesToDraw: motionFrame.player1.hitboxes.activeToDraw,
                    rgb: configuration.activeRGB,
                    scaleX: scaleX,
                    scaleY: scaleY,
                    in: cgContext
                )
            }

            if configuration.player1ThrowVisible {
                drawHitboxes(
                    motionFrame.player1.hitboxes.throw,
                    hitboxesToDraw: motionFrame.player1.hitboxes.throwToDraw,
                    rgb: configuration.throwRGB,
                    scaleX: scaleX,
                    scaleY: scaleY,
                    in: cgContext
                )
            }

            if configuration.player1ThrowableVisible {
                drawHitboxes(
                    motionFrame.player1.hitboxes.throwable,
                    hitboxesToDraw: motionFrame.player1.hitboxes.throwableToDraw,
                    rgb: configuration.throwableRGB,
                    scaleX: scaleX,
                    scaleY: scaleY,
                    in: cgContext
                )
            }

            if configuration.player1PushVisible {
                drawHitboxes(
                    motionFrame.player1.hitboxes.push,
                    hitboxesToDraw: motionFrame.player1.hitboxes.pushToDraw,
                    rgb: configuration.pushRGB,
                    scaleX: scaleX,
                    scaleY: scaleY,
                    in: cgContext
                )
            }

            if configuration.player2PassiveVisible {
                drawHitboxes(
                    motionFrame.player2.hitboxes.passive,
                    hitboxesToDraw: motionFrame.player2.hitboxes.passiveToDraw,
                    rgb: configuration.passiveRGB,
                    scaleX: scaleX,
                    scaleY: scaleY,
                    in: cgContext
                )
            }

            if configuration.player2OtherVulnerabilityVisible {
                drawHitboxes(
                    motionFrame.player2.hitboxes.otherVulnerability,
                    hitboxesToDraw: motionFrame.player2.hitboxes.otherVulnerabilityToDraw,
                    rgb: configuration.otherVulnerabilityRGB,
                    scaleX: scaleX,
                    scaleY: scaleY,
                    in: cgContext
                )
            }

            if configuration.player2ActiveVisible {
                drawHitboxes(
                    motionFrame.player2.hitboxes.active,
                    hitboxesToDraw: motionFrame.player2.hitboxes.activeToDraw,
                    rgb: configuration.activeRGB,
                    scaleX: scaleX,
                    scaleY: scaleY,
                    in: cgContext
                )
            }

            if configuration.player2ThrowVisible {
                drawHitboxes(
                    motionFrame.player2.hitboxes.throw,
                    hitboxesToDraw: motionFrame.player2.hitboxes.throwToDraw,
                    rgb: configuration.throwRGB,
                    scaleX: scaleX,
                    scaleY: scaleY,
                    in: cgContext
                )
            }

            if configuration.player2ThrowableVisible {
                drawHitboxes(
                    motionFrame.player2.hitboxes.throwable,
                    hitboxesToDraw: motionFrame.player2.hitboxes.throwableToDraw,
                    rgb: configuration.throwableRGB,
                    scaleX: scaleX,
                    scaleY: scaleY,
                    in: cgContext
                )
            }

            if configuration.player2PushVisible {
                drawHitboxes(
                    motionFrame.player2.hitboxes.push,
                    hitboxesToDraw: motionFrame.player2.hitboxes.pushToDraw,
                    rgb: configuration.pushRGB,
                    scaleX: scaleX,
                    scaleY: scaleY,
                    in: cgContext
                )
            }
        }
    }

    private func drawFrameImage(
        _ image: CGImage?,
        in context: CGContext,
        canvasRect: CGRect
    ) {
        guard let image else {
            return
        }

        context.saveGState()
        context.interpolationQuality = .none
        context.translateBy(x: 0, y: canvasRect.height)
        context.scaleBy(x: 1, y: -1)
        context.draw(image, in: canvasRect)
        context.restoreGState()
    }

    private func drawHitboxes(
        _ hitboxes: [String],
        hitboxesToDraw: [[Int]],
        rgb: Int,
        scaleX: CGFloat,
        scaleY: CGFloat,
        in context: CGContext
    ) {
        let strokeWidth = max(min(scaleX, scaleY), 1)
        let fillColor = makeColor(rgb: rgb, alpha: 0.3)
        let strokeColor = makeColor(rgb: rgb, alpha: 1)

        for (hitbox, hitboxToDraw) in zip(hitboxes, hitboxesToDraw) {
            guard hitbox != "0,0,0,0", hitboxToDraw.count >= 4 else {
                continue
            }

            let rect = normalizedRect(
                right: CGFloat(hitboxToDraw[0]) * scaleX,
                left: CGFloat(hitboxToDraw[1]) * scaleX,
                top: CGFloat(hitboxToDraw[2]) * scaleY,
                bottom: CGFloat(hitboxToDraw[3]) * scaleY
            )

            guard rect.isNull == false, rect.isEmpty == false else {
                continue
            }

            context.setFillColor(fillColor)
            context.fill(rect)

            context.setStrokeColor(strokeColor)
            context.setLineWidth(strokeWidth)
            context.stroke(rect)
        }
    }

    private func normalizedRect(
        right: CGFloat,
        left: CGFloat,
        top: CGFloat,
        bottom: CGFloat
    ) -> CGRect {
        let minX = min(left, right)
        let maxX = max(left, right)
        let minY = min(top, bottom)
        let maxY = max(top, bottom)

        return CGRect(
            x: minX,
            y: minY,
            width: maxX - minX,
            height: maxY - minY
        )
    }

    private func makeColor(rgb: Int, alpha: CGFloat) -> CGColor {
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let blue = CGFloat(rgb & 0x0000FF) / 255

        return CGColor(
            colorSpace: CGColorSpaceCreateDeviceRGB(),
            components: [red, green, blue, alpha]
        ) ?? CGColor(gray: 1, alpha: alpha)
    }
}

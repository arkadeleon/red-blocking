//
//  MotionPlayerLayer.swift
//  MaCherie
//
//  Created by Leon Li on 2018/6/14.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

import QuartzCore
import UIKit

class MotionPlayerLayer: CALayer {
    let frameWidth: CGFloat = 384
    let frameHeight: CGFloat = 224

    let axeLength: CGFloat = 7
    let axeColor = UIColor.white

    let hitboxVisibilitySettings: HitboxVisibilitySettings
    let hitboxColorSettings: HitboxColorSettings

    var motionFrame: MotionFrame? {
        didSet {
            setNeedsDisplay()
        }
    }

    override init() {
        hitboxVisibilitySettings = AppSettings.standard.hitboxVisibility
        hitboxColorSettings = AppSettings.standard.hitboxColors
        super.init()
        needsDisplayOnBoundsChange = true
    }

    init(
        hitboxVisibilitySettings: HitboxVisibilitySettings,
        hitboxColorSettings: HitboxColorSettings
    ) {
        self.hitboxVisibilitySettings = hitboxVisibilitySettings
        self.hitboxColorSettings = hitboxColorSettings
        super.init()
        needsDisplayOnBoundsChange = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(in ctx: CGContext) {
        guard let frame = motionFrame else {
            return
        }

        let boundingBox = ctx.boundingBoxOfClipPath

        if let image = frame.resource.cgImage {
            ctx.saveGState()
            ctx.translateBy(x: 0, y: boundingBox.height)
            ctx.scaleBy(x: 1, y: -1)
            ctx.draw(image, in: boundingBox)
            ctx.restoreGState()
        }

        let sx = boundingBox.width / frameWidth
        let sy = boundingBox.height / frameHeight
        ctx.scaleBy(x: sx, y: sy)

        if hitboxVisibilitySettings.player1PassiveVisible {
            drawHitboxes(
                hitboxes: frame.player1.hitboxes.passive,
                hitboxesToDraw: frame.player1.hitboxes.passiveToDraw,
                with: UIColor(rgb: hitboxColorSettings.passiveRGB, alpha: 1),
                in: ctx
            )
        }

        if hitboxVisibilitySettings.player1OtherVulnerabilityVisible {
            drawHitboxes(
                hitboxes: frame.player1.hitboxes.otherVulnerability,
                hitboxesToDraw: frame.player1.hitboxes.otherVulnerabilityToDraw,
                with: UIColor(rgb: hitboxColorSettings.otherVulnerabilityRGB, alpha: 1),
                in: ctx
            )
        }

        if hitboxVisibilitySettings.player1ActiveVisible {
            drawHitboxes(
                hitboxes: frame.player1.hitboxes.active,
                hitboxesToDraw: frame.player1.hitboxes.activeToDraw,
                with: UIColor(rgb: hitboxColorSettings.activeRGB, alpha: 1),
                in: ctx
            )
        }

        if hitboxVisibilitySettings.player1ThrowVisible {
            drawHitboxes(
                hitboxes: frame.player1.hitboxes.throw,
                hitboxesToDraw: frame.player1.hitboxes.throwToDraw,
                with: UIColor(rgb: hitboxColorSettings.throwRGB, alpha: 1),
                in: ctx
            )
        }

        if hitboxVisibilitySettings.player1ThrowableVisible {
            drawHitboxes(
                hitboxes: frame.player1.hitboxes.throwable,
                hitboxesToDraw: frame.player1.hitboxes.throwableToDraw,
                with: UIColor(rgb: hitboxColorSettings.throwableRGB, alpha: 1),
                in: ctx
            )
        }

        if hitboxVisibilitySettings.player1PushVisible {
            drawHitboxes(
                hitboxes: frame.player1.hitboxes.push,
                hitboxesToDraw: frame.player1.hitboxes.pushToDraw,
                with: UIColor(rgb: hitboxColorSettings.pushRGB, alpha: 1),
                in: ctx
            )
        }

        if hitboxVisibilitySettings.player2PassiveVisible {
            drawHitboxes(
                hitboxes: frame.player2.hitboxes.passive,
                hitboxesToDraw: frame.player2.hitboxes.passiveToDraw,
                with: UIColor(rgb: hitboxColorSettings.passiveRGB, alpha: 1),
                in: ctx
            )
        }

        if hitboxVisibilitySettings.player2OtherVulnerabilityVisible {
            drawHitboxes(
                hitboxes: frame.player2.hitboxes.otherVulnerability,
                hitboxesToDraw: frame.player2.hitboxes.otherVulnerabilityToDraw,
                with: UIColor(rgb: hitboxColorSettings.otherVulnerabilityRGB, alpha: 1),
                in: ctx
            )
        }

        if hitboxVisibilitySettings.player2ActiveVisible {
            drawHitboxes(
                hitboxes: frame.player2.hitboxes.active,
                hitboxesToDraw: frame.player2.hitboxes.activeToDraw,
                with: UIColor(rgb: hitboxColorSettings.activeRGB, alpha: 1),
                in: ctx
            )
        }

        if hitboxVisibilitySettings.player2ThrowVisible {
            drawHitboxes(
                hitboxes: frame.player2.hitboxes.throw,
                hitboxesToDraw: frame.player2.hitboxes.throwToDraw,
                with: UIColor(rgb: hitboxColorSettings.throwRGB, alpha: 1),
                in: ctx
            )
        }

        if hitboxVisibilitySettings.player2ThrowableVisible {
            drawHitboxes(
                hitboxes: frame.player2.hitboxes.throwable,
                hitboxesToDraw: frame.player2.hitboxes.throwableToDraw,
                with: UIColor(rgb: hitboxColorSettings.throwableRGB, alpha: 1),
                in: ctx
            )
        }

        if hitboxVisibilitySettings.player2PushVisible {
            drawHitboxes(
                hitboxes: frame.player2.hitboxes.push,
                hitboxesToDraw: frame.player2.hitboxes.pushToDraw,
                with: UIColor(rgb: hitboxColorSettings.pushRGB, alpha: 1),
                in: ctx
            )
        }
    }

    private func drawHitboxes(hitboxes: [String], hitboxesToDraw: [[Int]], with color: UIColor, in ctx: CGContext) {
        let count = hitboxesToDraw.count
        for i in 0..<count {
            let hitboxToDraw = hitboxesToDraw[i]
            let hitbox = hitboxes[i]

            if hitbox != "0,0,0,0" {
                let rect = normalizedRect(
                    top: hitboxToDraw[2],
                    left: hitboxToDraw[1],
                    bottom: hitboxToDraw[3],
                    right: hitboxToDraw[0]
                )

                if rect.isNull == false, rect.isEmpty == false {
                    drawHitbox(rect, with: color, in: ctx)
                }
            }
        }
    }

    private func drawHitbox(_ rect: CGRect, with color: UIColor, in ctx: CGContext) {
        ctx.setFillColor(color.withAlphaComponent(0.3).cgColor)
        ctx.fill(rect)

        ctx.setStrokeColor(color.withAlphaComponent(1).cgColor)
        ctx.stroke(rect)
    }

    private func normalizedRect(top: Int, left: Int, bottom: Int, right: Int) -> CGRect {
        let minX = CGFloat(min(left, right))
        let maxX = CGFloat(max(left, right))
        let minY = CGFloat(min(top, bottom))
        let maxY = CGFloat(max(top, bottom))

        return CGRect(
            x: minX,
            y: minY,
            width: maxX - minX,
            height: maxY - minY
        )
    }

    private func drawAxe(x: CGFloat, y: CGFloat, in ctx: CGContext) {
        drawLine(x1: x - axeLength, y1: y, x2: x + axeLength, y2: y, with: axeColor, in: ctx)
        drawLine(x1: x, y1: y - axeLength, x2: x, y2: y + axeLength, with: axeColor, in: ctx)
    }

    private func drawLine(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat, with color: UIColor, in ctx: CGContext) {
        ctx.setLineWidth(1)
        ctx.setStrokeColor(color.cgColor)
        ctx.move(to: CGPoint(x: x1, y: y1))
        ctx.addLine(to: CGPoint(x: x2, y: y2))
    }
}

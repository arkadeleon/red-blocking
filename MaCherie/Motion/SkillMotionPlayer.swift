//
//  SkillMotionPlayer.swift
//  MaCherie
//
//  Created by Leon Li on 2018/6/14.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

import UIKit

class SkillMotionPlayer: UIView {
    let frameWidth: CGFloat = 384
    let frameHeight: CGFloat = 224
    
    let axeLength: CGFloat = 7
    let axeColor = UIColor.white
    
    let passiveHitboxColor = UIColor(red:0, green:0, blue:1, alpha:1)
    let otherVulnerabilityHitboxColor = UIColor(red:0, green:0.5, blue:1, alpha:1)
    let activeHitboxColor = UIColor(red:1, green:0, blue:0, alpha:1)
    let throwHitboxColor = UIColor(red:1, green:0.5, blue:0, alpha:1)
    let throwableHitboxColor = UIColor(red:0, green:1, blue:0, alpha:1)
    let pushHitboxColor = UIColor(red:0.5, green:0, blue:1, alpha:1)
    
    var motionFrame: MotionInfo.Frame?
    
    func drawFrame(_ frame: MotionInfo.Frame) {
        self.motionFrame = frame
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let frame = motionFrame else {
            return
        }
        
        frame.image?.draw(in: rect)
        
        let ctx = UIGraphicsGetCurrentContext()!
        
        ctx.saveGState()
        let sx = rect.width / frameWidth
        let sy = rect.height / frameHeight
        ctx.scaleBy(x: sx, y: sy)
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: Player1PassiveHitboxHiddenKey) {
            drawHitboxes(
                hitboxes: frame.player1.hitboxes.passive,
                hitboxesToDraw: frame.player1.hitboxes.passiveToDraw,
                with: passiveHitboxColor,
                in: ctx
            )
        }
        
        if userDefaults.bool(forKey: Player1OtherVulnerabilityHitboxHiddenKey) {
            drawHitboxes(
                hitboxes: frame.player1.hitboxes.otherVulnerability,
                hitboxesToDraw: frame.player1.hitboxes.otherVulnerabilityToDraw,
                with: otherVulnerabilityHitboxColor,
                in: ctx
            )
        }
        
        if userDefaults.bool(forKey: Player1ActiveHitboxHiddenKey) {
            drawHitboxes(
                hitboxes: frame.player1.hitboxes.active,
                hitboxesToDraw: frame.player1.hitboxes.activeToDraw,
                with: activeHitboxColor,
                in: ctx
            )
        }
        
        if userDefaults.bool(forKey: Player1ThrowHitboxHiddenKey) {
            drawHitboxes(
                hitboxes: frame.player1.hitboxes.throw,
                hitboxesToDraw: frame.player1.hitboxes.throwToDraw,
                with: throwHitboxColor,
                in: ctx
            )
        }
        
        if userDefaults.bool(forKey: Player1ThrowableHitboxHiddenKey) {
            drawHitboxes(
                hitboxes: frame.player1.hitboxes.throwable,
                hitboxesToDraw: frame.player1.hitboxes.throwableToDraw,
                with: throwableHitboxColor,
                in: ctx
            )
        }
        
        if userDefaults.bool(forKey: Player1PushHitboxHiddenKey) {
            drawHitboxes(
                hitboxes: frame.player1.hitboxes.push,
                hitboxesToDraw: frame.player1.hitboxes.pushToDraw,
                with: pushHitboxColor,
                in: ctx
            )
        }
        
        if userDefaults.bool(forKey: Player2PassiveHitboxHiddenKey) {
            drawHitboxes(
                hitboxes: frame.player2.hitboxes.passive,
                hitboxesToDraw: frame.player2.hitboxes.passiveToDraw,
                with: passiveHitboxColor,
                in: ctx
            )
        }
        
        if userDefaults.bool(forKey: Player2OtherVulnerabilityHitboxHiddenKey) {
            drawHitboxes(
                hitboxes: frame.player2.hitboxes.otherVulnerability,
                hitboxesToDraw: frame.player2.hitboxes.otherVulnerabilityToDraw,
                with: otherVulnerabilityHitboxColor,
                in: ctx
            )
        }
        
        if userDefaults.bool(forKey: Player2ActiveHitboxHiddenKey) {
            drawHitboxes(
                hitboxes: frame.player2.hitboxes.active,
                hitboxesToDraw: frame.player2.hitboxes.activeToDraw,
                with: activeHitboxColor,
                in: ctx
            )
        }
        
        if userDefaults.bool(forKey: Player2ThrowHitboxHiddenKey) {
            drawHitboxes(
                hitboxes: frame.player2.hitboxes.throw,
                hitboxesToDraw: frame.player2.hitboxes.throwToDraw,
                with: throwHitboxColor,
                in: ctx
            )
        }
        
        if userDefaults.bool(forKey: Player2ThrowableHitboxHiddenKey) {
            drawHitboxes(
                hitboxes: frame.player2.hitboxes.throwable,
                hitboxesToDraw: frame.player2.hitboxes.throwableToDraw,
                with: throwableHitboxColor,
                in: ctx
            )
        }
        
        if userDefaults.bool(forKey: Player2PushHitboxHiddenKey) {
            drawHitboxes(
                hitboxes: frame.player2.hitboxes.push,
                hitboxesToDraw: frame.player2.hitboxes.pushToDraw,
                with: pushHitboxColor,
                in: ctx
            )
        }
        
        ctx.restoreGState()
    }
    
    private func drawHitboxes(hitboxes: [String], hitboxesToDraw: [[Int]], with color: UIColor, in ctx: CGContext) {
        let count = hitboxesToDraw.count
        for i in 0..<count {
            let hitboxToDraw = hitboxesToDraw[i]
            let hitbox = hitboxes[i]
            
            if hitbox != "0,0,0,0" {
                let right = hitboxToDraw[0]
                let left = hitboxToDraw[1]
                let top = hitboxToDraw[2]
                let bottom = hitboxToDraw[3]
                drawHitbox(top: top, left: left, bottom: bottom, right: right, with: color, in: ctx)
            }
        }
    }
    
    private func drawHitbox(top: Int, left: Int, bottom: Int, right: Int, with color: UIColor, in ctx: CGContext) {
        let rect = CGRect(
            x: CGFloat(left),
            y: CGFloat(top),
            width: CGFloat(right - left),
            height: CGFloat(bottom - top)
        )
        
        ctx.setFillColor(color.withAlphaComponent(0.3).cgColor)
        ctx.fill(rect)
        
        ctx.setStrokeColor(color.withAlphaComponent(1).cgColor)
        ctx.stroke(rect)
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

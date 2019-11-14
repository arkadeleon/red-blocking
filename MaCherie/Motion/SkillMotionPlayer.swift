//
//  SkillMotionPlayer.swift
//  MaCherie
//
//  Created by Leon Li on 2018/6/14.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

import UIKit

let FRAME_WIDTH: CGFloat                    = 384
let FRAME_HEIGHT: CGFloat                   = 224
let AXE_LENGTH: CGFloat                     = 7
let PASSIVE_HITBOX_FILL_COLOR               = UIColor(red:0.0, green:0.0, blue:1.0, alpha:0.3)
let PASSIVE_HITBOX_STROKE_COLOR             = UIColor(red:0.0, green:0.0, blue:1.0, alpha:1.0)
let OTHER_VULNERABILITY_HITBOX_FILL_COLOR   = UIColor(red:0.0, green:0.5, blue:1.0, alpha:0.3)
let OTHER_VULNERABILITY_HITBOX_STROKE_COLOR = UIColor(red:0.0, green:0.5, blue:1.0, alpha:1.0)
let ACTIVE_HITBOX_FILL_COLOR                = UIColor(red:1.0, green:0.0, blue:0.0, alpha:0.3)
let ACTIVE_HITBOX_STROKE_COLOR              = UIColor(red:1.0, green:0.0, blue:0.0, alpha:1.0)
let THROW_HITBOX_FILL_COLOR                 = UIColor(red:1.0, green:0.5, blue:0.0, alpha:0.3)
let THROW_HITBOX_STROKE_COLOR               = UIColor(red:1.0, green:0.5, blue:0.0, alpha:1.0)
let THROWABLE_HITBOX_FILL_COLOR             = UIColor(red:0.0, green:1.0, blue:0.0, alpha:0.3)
let THROWABLE_HITBOX_STROKE_COLOR           = UIColor(red:0.0, green:1.0, blue:0.0, alpha:1.0)
let PUSH_HITBOX_FILL_COLOR                  = UIColor(red:0.5, green:0.0, blue:1.0, alpha:0.3)
let PUSH_HITBOX_STROKE_COLOR                = UIColor(red:0.5, green:0.0, blue:1.0, alpha:1.0)
let AXE_COLOR                               = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)

class SkillMotionPlayer: UIView {
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
        
        let context = UIGraphicsGetCurrentContext()!
        
        context.saveGState()
        let sx = rect.width / FRAME_WIDTH
        let sy = rect.height / FRAME_HEIGHT
        context.scaleBy(x: sx, y: sy)
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: Player1PassiveHitboxHiddenKey) {
            drawHitboxes(
                frame.player1.hitboxes.passive,
                hitboxesToDraw: frame.player1.hitboxes.passiveToDraw,
                inContext: context,
                withFillColor: PASSIVE_HITBOX_FILL_COLOR.cgColor,
                strokeColor: PASSIVE_HITBOX_STROKE_COLOR.cgColor
            )
        }
        
        if userDefaults.bool(forKey: Player1OtherVulnerabilityHitboxHiddenKey) {
            drawHitboxes(
                frame.player1.hitboxes.otherVulnerability,
                hitboxesToDraw: frame.player1.hitboxes.otherVulnerabilityToDraw,
                inContext: context,
                withFillColor: OTHER_VULNERABILITY_HITBOX_FILL_COLOR.cgColor,
                strokeColor: OTHER_VULNERABILITY_HITBOX_STROKE_COLOR.cgColor
            )
        }
        
        if userDefaults.bool(forKey: Player1ActiveHitboxHiddenKey) {
            drawHitboxes(
                frame.player1.hitboxes.active,
                hitboxesToDraw: frame.player1.hitboxes.activeToDraw,
                inContext: context,
                withFillColor: ACTIVE_HITBOX_FILL_COLOR.cgColor,
                strokeColor: ACTIVE_HITBOX_STROKE_COLOR.cgColor
            )
        }
        
        if userDefaults.bool(forKey: Player1ThrowHitboxHiddenKey) {
            drawHitboxes(
                frame.player1.hitboxes.throw,
                hitboxesToDraw: frame.player1.hitboxes.throwToDraw,
                inContext: context,
                withFillColor: THROW_HITBOX_FILL_COLOR.cgColor,
                strokeColor: THROW_HITBOX_STROKE_COLOR.cgColor
            )
        }
        
        if userDefaults.bool(forKey: Player1ThrowableHitboxHiddenKey) {
            drawHitboxes(
                frame.player1.hitboxes.throwable,
                hitboxesToDraw: frame.player1.hitboxes.throwableToDraw,
                inContext: context,
                withFillColor: THROWABLE_HITBOX_FILL_COLOR.cgColor,
                strokeColor: THROWABLE_HITBOX_STROKE_COLOR.cgColor
            )
        }
        
        if userDefaults.bool(forKey: Player1PushHitboxHiddenKey) {
            drawHitboxes(
                frame.player1.hitboxes.push,
                hitboxesToDraw: frame.player1.hitboxes.pushToDraw,
                inContext: context,
                withFillColor: PUSH_HITBOX_FILL_COLOR.cgColor,
                strokeColor: PUSH_HITBOX_STROKE_COLOR.cgColor
            )
        }
        
        if userDefaults.bool(forKey: Player2PassiveHitboxHiddenKey) {
            drawHitboxes(
                frame.player2.hitboxes.passive,
                hitboxesToDraw: frame.player2.hitboxes.passiveToDraw,
                inContext: context,
                withFillColor: PASSIVE_HITBOX_FILL_COLOR.cgColor,
                strokeColor: PASSIVE_HITBOX_STROKE_COLOR.cgColor
            )
        }
        
        if userDefaults.bool(forKey: Player2OtherVulnerabilityHitboxHiddenKey) {
            drawHitboxes(
                frame.player2.hitboxes.otherVulnerability,
                hitboxesToDraw: frame.player2.hitboxes.otherVulnerabilityToDraw,
                inContext: context,
                withFillColor: OTHER_VULNERABILITY_HITBOX_FILL_COLOR.cgColor,
                strokeColor: OTHER_VULNERABILITY_HITBOX_STROKE_COLOR.cgColor
            )
        }
        
        if userDefaults.bool(forKey: Player2ActiveHitboxHiddenKey) {
            drawHitboxes(
                frame.player2.hitboxes.active,
                hitboxesToDraw: frame.player2.hitboxes.activeToDraw,
                inContext: context,
                withFillColor: ACTIVE_HITBOX_FILL_COLOR.cgColor,
                strokeColor: ACTIVE_HITBOX_STROKE_COLOR.cgColor
            )
        }
        
        if userDefaults.bool(forKey: Player2ThrowHitboxHiddenKey) {
            drawHitboxes(
                frame.player2.hitboxes.throw,
                hitboxesToDraw: frame.player2.hitboxes.throwToDraw,
                inContext: context,
                withFillColor: THROW_HITBOX_FILL_COLOR.cgColor,
                strokeColor: THROW_HITBOX_STROKE_COLOR.cgColor
            )
        }
        
        if userDefaults.bool(forKey: Player2ThrowableHitboxHiddenKey) {
            drawHitboxes(
                frame.player2.hitboxes.throwable,
                hitboxesToDraw: frame.player2.hitboxes.throwableToDraw,
                inContext: context,
                withFillColor: THROWABLE_HITBOX_FILL_COLOR.cgColor,
                strokeColor: THROWABLE_HITBOX_STROKE_COLOR.cgColor
            )
        }
        
        if userDefaults.bool(forKey: Player2PushHitboxHiddenKey) {
            drawHitboxes(
                frame.player2.hitboxes.push,
                hitboxesToDraw: frame.player2.hitboxes.pushToDraw,
                inContext: context,
                withFillColor: PUSH_HITBOX_FILL_COLOR.cgColor,
                strokeColor: PUSH_HITBOX_STROKE_COLOR.cgColor
            )
        }
        
        context.restoreGState()
    }
    
    func drawHitboxes(_ hitboxes: [String], hitboxesToDraw: [[Int]], inContext context: CGContext, withFillColor fillColor: CGColor, strokeColor: CGColor) {
        let count = hitboxesToDraw.count
        for i in 0..<count {
            let hitboxToDraw = hitboxesToDraw[i]
            let hitbox = hitboxes[i]
            
            if hitbox != "0,0,0,0" {
                let right = hitboxToDraw[0]
                let left = hitboxToDraw[1]
                let top = hitboxToDraw[2]
                let bottom = hitboxToDraw[3]
                drawHitbox(top: top, left: left, bottom: bottom, right: right, inContext: context, withFillColor: fillColor, strokeColor: strokeColor)
            }
        }
    }
    
    func drawHitbox(top: Int, left: Int, bottom: Int, right: Int, inContext context: CGContext, withFillColor fillColor: CGColor, strokeColor: CGColor) {
        let rect = CGRect(
            x: CGFloat(left),
            y: CGFloat(top),
            width: CGFloat(right - left),
            height: CGFloat(bottom - top)
        )
        
        context.setFillColor(fillColor)
        context.fill(rect)
        
        context.setStrokeColor(strokeColor)
        context.stroke(rect)
    }
    
    func drawAxe(x: CGFloat, y: CGFloat, inContext context: CGContext) {
        drawLine(x1: x - AXE_LENGTH, y1: y, x2: x + AXE_LENGTH, y2: y, inContext: context, withColor: AXE_COLOR.cgColor)
        drawLine(x1: x, y1: y - AXE_LENGTH, x2: x, y2: y + AXE_LENGTH, inContext: context, withColor: AXE_COLOR.cgColor)
    }
    
    func drawLine(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat, inContext context: CGContext, withColor color: CGColor) {
        context.setLineWidth(1)
        context.setStrokeColor(color)
        context.move(to: CGPoint(x: x1, y: y1))
        context.addLine(to: CGPoint(x: x2, y: y2))
    }
}

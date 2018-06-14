//
//  SkillMotionPlayer.swift
//  i3rd
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
    var frameImage: UIImage?
    var frameInfo: NSDictionary?
    
    func drawFrameImage(_ frameImage: UIImage?, withFrameInfo frameInfo: NSDictionary?) {
        self.frameImage = frameImage
        self.frameInfo = frameInfo
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        frameImage?.draw(in: rect)
        
        let player1Info = frameInfo?["P1"] as? NSDictionary
        let player2Info = frameInfo?["P2"] as? NSDictionary
        let player1HitboxesInfo = player1Info?["hitboxes"] as? NSDictionary
        let player2HitboxesInfo = player2Info?["hitboxes"] as? NSDictionary
        
        let player1PassiveHitboxes = player1HitboxesInfo?["p_hb"] as? NSArray
        let player1PassiveHitboxesToDraw = player1HitboxesInfo?["p_hb_to_draw"] as? NSArray
        let player1OtherVulnerabilityHitboxes = player1HitboxesInfo?["v_hb"] as? NSArray
        let player1OtherVulnerabilityHitboxesToDraw = player1HitboxesInfo?["v_hb_to_draw"] as? NSArray
        let player1ActiveHitboxes = player1HitboxesInfo?["a_hb"] as? NSArray
        let player1ActiveHitboxesToDraw = player1HitboxesInfo?["a_hb_to_draw"] as? NSArray
        let player1ThrowHitboxes = player1HitboxesInfo?["t_hb"] as? NSArray
        let player1ThrowHitboxesToDraw = player1HitboxesInfo?["t_hb_to_draw"] as? NSArray
        let player1ThrowableHitboxes = player1HitboxesInfo?["ta_hb"] as? NSArray
        let player1ThrowableHitboxesToDraw = player1HitboxesInfo?["ta_hb_to_draw"] as? NSArray
        let player1PushHitboxes = player1HitboxesInfo?["pu_hb"] as? NSArray
        let player1PushHitboxesToDraw = player1HitboxesInfo?["pu_hb_to_draw"] as? NSArray
        
        let player2PassiveHitboxes = player2HitboxesInfo?["p_hb"] as? NSArray
        let player2PassiveHitboxesToDraw = player2HitboxesInfo?["p_hb_to_draw"] as? NSArray
        let player2OtherVulnerabilityHitboxes = player2HitboxesInfo?["v_hb"] as? NSArray
        let player2OtherVulnerabilityHitboxesToDraw = player2HitboxesInfo?["v_hb_to_draw"] as? NSArray
        let player2ActiveHitboxes = player2HitboxesInfo?["a_hb"] as? NSArray
        let player2ActiveHitboxesToDraw = player2HitboxesInfo?["a_hb_to_draw"] as? NSArray
        let player2ThrowHitboxes = player2HitboxesInfo?["t_hb"] as? NSArray
        let player2ThrowHitboxesToDraw = player2HitboxesInfo?["t_hb_to_draw"] as? NSArray
        let player2ThrowableHitboxes = player2HitboxesInfo?["ta_hb"] as? NSArray
        let player2ThrowableHitboxesToDraw = player2HitboxesInfo?["ta_hb_to_draw"] as? NSArray
        let player2PushHitboxes = player2HitboxesInfo?["pu_hb"] as? NSArray
        let player2PushHitboxesToDraw = player2HitboxesInfo?["pu_hb_to_draw"] as? NSArray
        
        let context = UIGraphicsGetCurrentContext()!
        
        context.saveGState()
        let sx = rect.width / FRAME_WIDTH
        let sy = rect.height / FRAME_HEIGHT
        context.scaleBy(x: sx, y: sy)
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: Player1PassiveHitboxHiddenKey) == false {
            drawHitboxes(player1PassiveHitboxes, hitboxesToDraw:player1PassiveHitboxesToDraw, inContext:context, withFillColor:PASSIVE_HITBOX_FILL_COLOR.cgColor, strokeColor:PASSIVE_HITBOX_STROKE_COLOR.cgColor)
        }
        
        if userDefaults.bool(forKey: Player1OtherVulnerabilityHitboxHiddenKey) == false {
            drawHitboxes(player1OtherVulnerabilityHitboxes, hitboxesToDraw:player1OtherVulnerabilityHitboxesToDraw, inContext:context, withFillColor:OTHER_VULNERABILITY_HITBOX_FILL_COLOR.cgColor, strokeColor:OTHER_VULNERABILITY_HITBOX_STROKE_COLOR.cgColor)
        }
        
        if userDefaults.bool(forKey: Player1ActiveHitboxHiddenKey) == false {
            drawHitboxes(player1ActiveHitboxes, hitboxesToDraw:player1ActiveHitboxesToDraw, inContext:context, withFillColor:ACTIVE_HITBOX_FILL_COLOR.cgColor, strokeColor:ACTIVE_HITBOX_STROKE_COLOR.cgColor)
        }
        
        if userDefaults.bool(forKey: Player1ThrowHitboxHiddenKey) == false {
            drawHitboxes(player1ThrowHitboxes, hitboxesToDraw:player1ThrowHitboxesToDraw, inContext:context, withFillColor:THROW_HITBOX_FILL_COLOR.cgColor, strokeColor:THROW_HITBOX_STROKE_COLOR.cgColor)
        }
        
        if userDefaults.bool(forKey: Player1ThrowableHitboxHiddenKey) == false {
            drawHitboxes(player1ThrowableHitboxes, hitboxesToDraw:player1ThrowableHitboxesToDraw, inContext:context, withFillColor:THROWABLE_HITBOX_FILL_COLOR.cgColor, strokeColor:THROWABLE_HITBOX_STROKE_COLOR.cgColor)
        }
        
        if userDefaults.bool(forKey: Player1PushHitboxHiddenKey) == false {
            drawHitboxes(player1PushHitboxes, hitboxesToDraw:player1PushHitboxesToDraw, inContext:context, withFillColor:PUSH_HITBOX_FILL_COLOR.cgColor, strokeColor:PUSH_HITBOX_STROKE_COLOR.cgColor)
        }
        
        if userDefaults.bool(forKey: Player2PassiveHitboxHiddenKey) == false {
            drawHitboxes(player2PassiveHitboxes, hitboxesToDraw:player2PassiveHitboxesToDraw, inContext:context, withFillColor:PASSIVE_HITBOX_FILL_COLOR.cgColor, strokeColor:PASSIVE_HITBOX_STROKE_COLOR.cgColor)
        }
        
        if userDefaults.bool(forKey: Player2OtherVulnerabilityHitboxHiddenKey) == false {
            drawHitboxes(player2OtherVulnerabilityHitboxes, hitboxesToDraw:player2OtherVulnerabilityHitboxesToDraw, inContext:context, withFillColor:OTHER_VULNERABILITY_HITBOX_FILL_COLOR.cgColor, strokeColor:OTHER_VULNERABILITY_HITBOX_STROKE_COLOR.cgColor)
        }
        
        if userDefaults.bool(forKey: Player2ActiveHitboxHiddenKey) == false {
            drawHitboxes(player2ActiveHitboxes, hitboxesToDraw:player2ActiveHitboxesToDraw, inContext:context, withFillColor:ACTIVE_HITBOX_FILL_COLOR.cgColor, strokeColor:ACTIVE_HITBOX_STROKE_COLOR.cgColor)
        }
        
        if userDefaults.bool(forKey: Player2ThrowHitboxHiddenKey) == false {
            drawHitboxes(player2ThrowHitboxes, hitboxesToDraw:player2ThrowHitboxesToDraw, inContext:context, withFillColor:THROW_HITBOX_FILL_COLOR.cgColor, strokeColor:THROW_HITBOX_STROKE_COLOR.cgColor)
        }
        
        if userDefaults.bool(forKey: Player2ThrowableHitboxHiddenKey) == false {
            drawHitboxes(player2ThrowableHitboxes, hitboxesToDraw:player2ThrowableHitboxesToDraw, inContext:context, withFillColor:THROWABLE_HITBOX_FILL_COLOR.cgColor, strokeColor:THROWABLE_HITBOX_STROKE_COLOR.cgColor)
        }
        
        if userDefaults.bool(forKey: Player2PushHitboxHiddenKey) == false {
            drawHitboxes(player2PushHitboxes, hitboxesToDraw:player2PushHitboxesToDraw, inContext:context, withFillColor:PUSH_HITBOX_FILL_COLOR.cgColor, strokeColor:PUSH_HITBOX_STROKE_COLOR.cgColor)
        }
        
        context.restoreGState()
    }
    
    func drawHitboxes(_ hitboxes: NSArray?, hitboxesToDraw: NSArray?, inContext context: CGContext, withFillColor fillColor: CGColor, strokeColor: CGColor) {
        let count = hitboxesToDraw?.count ?? 0
        for i in 0..<count {
            let hitboxToDraw = hitboxesToDraw![i] as! NSArray
            let hitbox = hitboxes![i] as! String
            
            if hitbox != "0,0,0,0" {
                let right = hitboxToDraw[0] as! CGFloat
                let left = hitboxToDraw[1] as! CGFloat
                let top = hitboxToDraw[2] as! CGFloat
                let bottom = hitboxToDraw[3] as! CGFloat
                drawHitbox(top: top, left: left, bottom: bottom, right: right, inContext: context, withFillColor: fillColor, strokeColor: strokeColor)
            }
        }
    }
    
    func drawHitbox(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat, inContext context: CGContext, withFillColor fillColor: CGColor, strokeColor: CGColor) {
        let rect = CGRect(x: left, y: top, width: right - left, height: bottom - top)
        
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

//
//  FramesPlayer.m
//  i3rd
//
//  Created by pp on 12-7-1.
//  Copyright (c) 2012年 studiopp. All rights reserved.
//

#import "SkillMotionPlayer.h"
#import "ApplicationDataManager.h"

#define FRAME_WIDTH                                 384.0
#define FRAME_HEIGHT                                224.0
#define AXE_LENGTH                                  7.0
#define PASSIVE_HITBOX_FILL_COLOR                   [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.3]
#define PASSIVE_HITBOX_STROKE_COLOR                 [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0]
#define OTHER_VULNERABILITY_HITBOX_FILL_COLOR       [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:0.3]
#define OTHER_VULNERABILITY_HITBOX_STROKE_COLOR     [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0]
#define ACTIVE_HITBOX_FILL_COLOR                    [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.3]
#define ACTIVE_HITBOX_STROKE_COLOR                  [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]
#define THROW_HITBOX_FILL_COLOR                     [UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:0.3]
#define THROW_HITBOX_STROKE_COLOR                   [UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0]
#define THROWABLE_HITBOX_FILL_COLOR                 [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.3]
#define THROWABLE_HITBOX_STROKE_COLOR               [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0]
#define PUSH_HITBOX_FILL_COLOR                      [UIColor colorWithRed:0.5 green:0.0 blue:1.0 alpha:0.3]
#define PUSH_HITBOX_STROKE_COLOR                    [UIColor colorWithRed:0.5 green:0.0 blue:1.0 alpha:1.0]
#define AXE_COLOR                                   [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]

@interface SkillMotionPlayer ()

@property (strong, nonatomic) UIImage *frameImage;
@property (strong, nonatomic) NSDictionary *frameInfo;

- (void)drawHitboxes:(NSArray *)hitboxes hitboxesToDraw:(NSArray *)hitboxesToDraw inContext:(CGContextRef)context withFillColor:(CGColorRef)fillColor strokeColor:(CGColorRef)strokeColor;
- (void)drawHitboxTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right inContext:(CGContextRef)context withFillColor:(CGColorRef)fillColor strokeColor:(CGColorRef)strokeColor;
- (void)drawAxeX:(CGFloat)x y:(CGFloat)y inContext:(CGContextRef)context;
- (void)drawLineX1:(CGFloat)x1 y1:(CGFloat)y1 x2:(CGFloat)x2 y2:(CGFloat)y2 inContext:(CGContextRef)context withColor:(CGColorRef)color;

@end

@implementation SkillMotionPlayer

@synthesize frameImage = _frameImage;
@synthesize frameInfo = _frameInfo;

- (void)drawFrameImage:(UIImage *)frameImage withFrameInfo:(NSDictionary *)frameInfo
{
    self.frameImage = frameImage;
    self.frameInfo = frameInfo;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [self.frameImage drawInRect:rect];
    
    NSDictionary *player1Info = [self.frameInfo objectForKey:@"P1"];
    NSDictionary *player2Info = [self.frameInfo objectForKey:@"P2"];
    NSDictionary *player1HitboxesInfo = [player1Info objectForKey:@"hitboxes"];
    NSDictionary *player2HitboxesInfo = [player2Info objectForKey:@"hitboxes"];
    
    NSArray *player1PassiveHitboxes = [player1HitboxesInfo objectForKey:@"p_hb"];
    NSArray *player1PassiveHitboxesToDraw = [player1HitboxesInfo objectForKey:@"p_hb_to_draw"];
    NSArray *player1OtherVulnerabilityHitboxes = [player1HitboxesInfo objectForKey:@"v_hb"];
    NSArray *player1OtherVulnerabilityHitboxesToDraw = [player1HitboxesInfo objectForKey:@"v_hb_to_draw"];
    NSArray *player1ActiveHitboxes = [player1HitboxesInfo objectForKey:@"a_hb"];
    NSArray *player1ActiveHitboxesToDraw = [player1HitboxesInfo objectForKey:@"a_hb_to_draw"];
    NSArray *player1ThrowHitboxes = [player1HitboxesInfo objectForKey:@"t_hb"];
    NSArray *player1ThrowHitboxesToDraw = [player1HitboxesInfo objectForKey:@"t_hb_to_draw"];
    NSArray *player1ThrowableHitboxes = [player1HitboxesInfo objectForKey:@"ta_hb"];
    NSArray *player1ThrowableHitboxesToDraw = [player1HitboxesInfo objectForKey:@"ta_hb_to_draw"];
    NSArray *player1PushHitboxes = [player1HitboxesInfo objectForKey:@"pu_hb"];
    NSArray *player1PushHitboxesToDraw = [player1HitboxesInfo objectForKey:@"pu_hb_to_draw"];
    
    NSArray *player2PassiveHitboxes = [player2HitboxesInfo objectForKey:@"p_hb"];
    NSArray *player2PassiveHitboxesToDraw = [player2HitboxesInfo objectForKey:@"p_hb_to_draw"];
    NSArray *player2OtherVulnerabilityHitboxes = [player2HitboxesInfo objectForKey:@"v_hb"];
    NSArray *player2OtherVulnerabilityHitboxesToDraw = [player2HitboxesInfo objectForKey:@"v_hb_to_draw"];
    NSArray *player2ActiveHitboxes = [player2HitboxesInfo objectForKey:@"a_hb"];
    NSArray *player2ActiveHitboxesToDraw = [player2HitboxesInfo objectForKey:@"a_hb_to_draw"];
    NSArray *player2ThrowHitboxes = [player2HitboxesInfo objectForKey:@"t_hb"];
    NSArray *player2ThrowHitboxesToDraw = [player2HitboxesInfo objectForKey:@"t_hb_to_draw"];
    NSArray *player2ThrowableHitboxes = [player2HitboxesInfo objectForKey:@"ta_hb"];
    NSArray *player2ThrowableHitboxesToDraw = [player2HitboxesInfo objectForKey:@"ta_hb_to_draw"];
    NSArray *player2PushHitboxes = [player2HitboxesInfo objectForKey:@"pu_hb"];
    NSArray *player2PushHitboxesToDraw = [player2HitboxesInfo objectForKey:@"pu_hb_to_draw"];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGFloat sx = rect.size.width / FRAME_WIDTH;
    CGFloat sy = rect.size.height / FRAME_HEIGHT;
    CGContextScaleCTM(context, sx, sy);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults boolForKey:Player1PassiveHitboxHiddenKey] == NO) {
        [self drawHitboxes:player1PassiveHitboxes hitboxesToDraw:player1PassiveHitboxesToDraw inContext:context withFillColor:PASSIVE_HITBOX_FILL_COLOR.CGColor strokeColor:PASSIVE_HITBOX_STROKE_COLOR.CGColor];
    }
    
    if ([userDefaults boolForKey:Player1OtherVulnerabilityHitboxHiddenKey] == NO) {
        [self drawHitboxes:player1OtherVulnerabilityHitboxes hitboxesToDraw:player1OtherVulnerabilityHitboxesToDraw inContext:context withFillColor:OTHER_VULNERABILITY_HITBOX_FILL_COLOR.CGColor strokeColor:OTHER_VULNERABILITY_HITBOX_STROKE_COLOR.CGColor];
    }
    
    if ([userDefaults boolForKey:Player1ActiveHitboxHiddenKey] == NO) {
        [self drawHitboxes:player1ActiveHitboxes hitboxesToDraw:player1ActiveHitboxesToDraw inContext:context withFillColor:ACTIVE_HITBOX_FILL_COLOR.CGColor strokeColor:ACTIVE_HITBOX_STROKE_COLOR.CGColor];
    }
    
    if ([userDefaults boolForKey:Player1ThrowHitboxHiddenKey] == NO) {
        [self drawHitboxes:player1ThrowHitboxes hitboxesToDraw:player1ThrowHitboxesToDraw inContext:context withFillColor:THROW_HITBOX_FILL_COLOR.CGColor strokeColor:THROW_HITBOX_STROKE_COLOR.CGColor];
    }
    
    if ([userDefaults boolForKey:Player1ThrowableHitboxHiddenKey] == NO) {
        [self drawHitboxes:player1ThrowableHitboxes hitboxesToDraw:player1ThrowableHitboxesToDraw inContext:context withFillColor:THROWABLE_HITBOX_FILL_COLOR.CGColor strokeColor:THROWABLE_HITBOX_STROKE_COLOR.CGColor];
    }
    
    if ([userDefaults boolForKey:Player1PushHitboxHiddenKey] == NO) {
        [self drawHitboxes:player1PushHitboxes hitboxesToDraw:player1PushHitboxesToDraw inContext:context withFillColor:PUSH_HITBOX_FILL_COLOR.CGColor strokeColor:PUSH_HITBOX_STROKE_COLOR.CGColor];
    }
    
    if ([userDefaults boolForKey:Player2PassiveHitboxHiddenKey] == NO) {
        [self drawHitboxes:player2PassiveHitboxes hitboxesToDraw:player2PassiveHitboxesToDraw inContext:context withFillColor:PASSIVE_HITBOX_FILL_COLOR.CGColor strokeColor:PASSIVE_HITBOX_STROKE_COLOR.CGColor];
    }
    
    if ([userDefaults boolForKey:Player2OtherVulnerabilityHitboxHiddenKey] == NO) {
        [self drawHitboxes:player2OtherVulnerabilityHitboxes hitboxesToDraw:player2OtherVulnerabilityHitboxesToDraw inContext:context withFillColor:OTHER_VULNERABILITY_HITBOX_FILL_COLOR.CGColor strokeColor:OTHER_VULNERABILITY_HITBOX_STROKE_COLOR.CGColor];
    }
    
    if ([userDefaults boolForKey:Player2ActiveHitboxHiddenKey] == NO) {
        [self drawHitboxes:player2ActiveHitboxes hitboxesToDraw:player2ActiveHitboxesToDraw inContext:context withFillColor:ACTIVE_HITBOX_FILL_COLOR.CGColor strokeColor:ACTIVE_HITBOX_STROKE_COLOR.CGColor];
    }
    
    if ([userDefaults boolForKey:Player2ThrowHitboxHiddenKey] == NO) {
        [self drawHitboxes:player2ThrowHitboxes hitboxesToDraw:player2ThrowHitboxesToDraw inContext:context withFillColor:THROW_HITBOX_FILL_COLOR.CGColor strokeColor:THROW_HITBOX_STROKE_COLOR.CGColor];
    }
    
    if ([userDefaults boolForKey:Player2ThrowableHitboxHiddenKey] == NO) {
        [self drawHitboxes:player2ThrowableHitboxes hitboxesToDraw:player2ThrowableHitboxesToDraw inContext:context withFillColor:THROWABLE_HITBOX_FILL_COLOR.CGColor strokeColor:THROWABLE_HITBOX_STROKE_COLOR.CGColor];
    }
    
    if ([userDefaults boolForKey:Player2PushHitboxHiddenKey] == NO) {
        [self drawHitboxes:player2PushHitboxes hitboxesToDraw:player2PushHitboxesToDraw inContext:context withFillColor:PUSH_HITBOX_FILL_COLOR.CGColor strokeColor:PUSH_HITBOX_STROKE_COLOR.CGColor];
    }
    
    CGContextRestoreGState(context);
}

- (void)drawHitboxes:(NSArray *)hitboxes hitboxesToDraw:(NSArray *)hitboxesToDraw inContext:(CGContextRef)context withFillColor:(CGColorRef)fillColor strokeColor:(CGColorRef)strokeColor
{
    NSUInteger count = [hitboxesToDraw count];
    for (int i = 0; i < count; i++) {
        NSArray *hitboxToDraw = [hitboxesToDraw objectAtIndex:i];
        NSString *hitbox = [hitboxes objectAtIndex:i];
        
        if (![hitbox isEqualToString:@"0,0,0,0"]) {
            CGFloat right = [[hitboxToDraw objectAtIndex:0] floatValue];
            CGFloat left = [[hitboxToDraw objectAtIndex:1] floatValue];
            CGFloat top = [[hitboxToDraw objectAtIndex:2] floatValue];
            CGFloat bottom = [[hitboxToDraw objectAtIndex:3] floatValue];
            [self drawHitboxTop:top left:left bottom:bottom right:right inContext:context withFillColor:fillColor strokeColor:strokeColor];
        }
    }
}

- (void)drawHitboxTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right inContext:(CGContextRef)context withFillColor:(CGColorRef)fillColor strokeColor:(CGColorRef)strokeColor
{
    CGRect rect = CGRectMake(left, top, right - left, bottom - top);
    
    CGContextSetFillColorWithColor(context, fillColor);
    CGContextFillRect(context, rect);
    
    CGContextSetStrokeColorWithColor(context, strokeColor);
    CGContextStrokeRect(context, rect);
}

- (void)drawAxeX:(CGFloat)x y:(CGFloat)y inContext:(CGContextRef)context
{
    [self drawLineX1:x - AXE_LENGTH y1:y x2:x + AXE_LENGTH y2:y inContext:context withColor:AXE_COLOR.CGColor];
    [self drawLineX1:x y1:y - AXE_LENGTH x2:x y2:y + AXE_LENGTH inContext:context withColor:AXE_COLOR.CGColor];
}

- (void)drawLineX1:(CGFloat)x1 y1:(CGFloat)y1 x2:(CGFloat)x2 y2:(CGFloat)y2 inContext:(CGContextRef)context withColor:(CGColorRef)color
{
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, color);
    CGContextMoveToPoint(context, x1, y1);
    CGContextAddLineToPoint(context, x2, y2);
}

@end

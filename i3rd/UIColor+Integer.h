
@interface UIColor (Integer)

+ (UIColor *)colorWithRGB:(NSInteger)rgb alpha:(CGFloat)alpha;
- (BOOL)getRGB:(NSInteger *)rgb alpha:(CGFloat *)alpha;

@end


#import "UIColor+Integer.h"

@implementation UIColor (Integer)

+ (UIColor *)colorWithRGB:(NSInteger)rgb alpha:(CGFloat)alpha
{
    CGFloat red = 1.0 * ((rgb & 0xFF0000) >> 16) / 0xFF;
    CGFloat green = 1.0 * ((rgb & 0x00FF00) >> 8) / 0xFF;
    CGFloat blue = 1.0 * (rgb & 0x0000FF) / 0xFF;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (BOOL)getRGB:(NSInteger *)rgb alpha:(CGFloat *)alpha
{
    CGFloat red, green, blue;
    BOOL compatiable = [self getRed:&red green:&green blue:&blue alpha:alpha];
    if (compatiable == YES && rgb) {
        NSInteger redi = red * 0xFF;
        NSInteger greeni = green * 0xFF;
        NSInteger bluei = blue * 0xFF;
        *rgb = (redi << 16) | (greeni << 8) | bluei;
    }
    return compatiable;
}

@end

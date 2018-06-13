
#import "PropertyListBasedTableViewCell.h"

@implementation PropertyListBasedTableViewCell

//- (void)updateConstraints
//{
//    [super updateConstraints];
//    
//    self.spacingBetweenLeftLabelAndRightLabel.constant = [self.leftLabel.text length] > 0 && [self.rightLabel.text length] > 0 ? 8.0 : 0.0;
//}

- (BOOL)canBeSelected
{
    return YES;
}

@end


extern const CGFloat PropertyListBasedTableViewCellContentInsetX;
extern const CGFloat PropertyListBasedTableViewCellContentInsetY;

@interface PropertyListBasedTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *leftImageView;
@property (nonatomic, weak) IBOutlet UILabel *leftLabel;
@property (nonatomic, weak) IBOutlet UILabel *rightLabel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *spacingBetweenLeftImageViewAndLeftLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *spacingBetweenLeftLabelAndRightLabel;

- (BOOL)canBeSelected;

@end


#import "PropertyListBasedViewController.h"

NSString *const PropertyListBasedViewControllerSectionsKey = @"Sections";
NSString *const PropertyListBasedViewControllerSectionTitleKey = @"SectionTitle";
NSString *const PropertyListBasedViewControllerRowsKey = @"Rows";
NSString *const PropertyListBasedViewControllerRowImageKey = @"RowImage";
NSString *const PropertyListBasedViewControllerRowTitleKey = @"RowTitle";
NSString *const PropertyListBasedViewControllerRowDetailKey = @"RowDetail";
NSString *const PropertyListBasedViewControllerNextKey = @"Next";
NSString *const PropertyListBasedViewControllerPresentedKey = @"Presented";

@implementation PropertyListBasedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"PropertyListBasedTableViewCell" bundle:nil] forCellReuseIdentifier:@"PropertyListBasedTableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)configureCell:(PropertyListBasedTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *sectionInfo = [self.sections objectAtIndex:indexPath.section];
    NSArray *rows = [sectionInfo objectForKey:PropertyListBasedViewControllerRowsKey];
    NSDictionary *rowInfo = [rows objectAtIndex:indexPath.row];
    NSString *rowImage = [rowInfo objectForKey:PropertyListBasedViewControllerRowImageKey];
    NSString *rowTitle = [rowInfo objectForKey:PropertyListBasedViewControllerRowTitleKey];
    NSString *rowDetail = [rowInfo objectForKey:PropertyListBasedViewControllerRowDetailKey];
    id next = [rowInfo objectForKey:PropertyListBasedViewControllerNextKey];
    id presented = [rowInfo objectForKey:PropertyListBasedViewControllerPresentedKey];
    
    if (next) {
        
    } else if (presented) {
        
    } else {
        
    }
    
    cell.leftImageView.image = [UIImage imageNamed:rowImage];
    cell.leftLabel.text = rowTitle;
    cell.rightLabel.text = rowDetail;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *sectionInfo = [self.sections objectAtIndex:section];
    NSString *sectionTitle = [sectionInfo objectForKey:PropertyListBasedViewControllerSectionTitleKey];
    return sectionTitle;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *sectionInfo = [self.sections objectAtIndex:section];
    NSArray *rows = [sectionInfo objectForKey:PropertyListBasedViewControllerRowsKey];
    return [rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PropertyListBasedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PropertyListBasedTableViewCell" forIndexPath:indexPath];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    return cell;
}

#pragma mark - Table View Delegate

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static PropertyListBasedTableViewCell *cell = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        cell = [[[UINib nibWithNibName:@"Cell" bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
//    });
//    
//    CGRect cellFrame = cell.frame;
//    cellFrame.size.width = tableView.frame.size.width;
//    cell.frame = cell.frame;
//    
//    [self configureCell:cell forRowAtIndexPath:indexPath];
//    [cell setNeedsLayout];
//    [cell layoutIfNeeded];
//    
//    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//    return size.height + 1.0;
//}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PropertyListBasedTableViewCell *cell = (PropertyListBasedTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell canBeSelected]) {
        return indexPath;
    }
    return nil;
}

#pragma mark - Data Source Model Association

- (NSString *)modelIdentifierForElementAtIndexPath:(NSIndexPath *)indexPath inView:(UIView *)view
{
    return nil;
}

- (NSIndexPath *)indexPathForElementWithModelIdentifier:(NSString *)identifier inView:(UIView *)view
{
    NSArray *components = [identifier componentsSeparatedByString:@", "];
    NSInteger section = [components[0] integerValue];
    NSInteger row = [components[1] integerValue];
    return [NSIndexPath indexPathForRow:section inSection:row];
}

@end

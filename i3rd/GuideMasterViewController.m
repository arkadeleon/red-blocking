
#import "GuideMasterViewController.h"
#import "GuideDetailViewController.h"

NSString *const GuideMasterViewControllerNextBackgroundImageKey = @"NextBackgroundImage";

@interface GuideMasterViewController ()

@property (strong, nonatomic) UIImageView *bodyView;

- (IBAction)moreViewControllerUnwound:(UIStoryboardSegue *)segue;

- (void)displayDetailViewController:(GuideDetailViewController *)detailViewController withSelectedIndexPath:(NSIndexPath *)indexPath;

@end

@implementation GuideMasterViewController

- (UIImageView *)bodyView
{
    if (_bodyView == nil) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
            CGFloat navigationBarHeight = self.navigationController.navigationBar.bounds.size.height;
            CGRect bodyViewFrame = UIEdgeInsetsInsetRect(self.navigationController.view.bounds, UIEdgeInsetsMake(statusBarHeight + navigationBarHeight, 0.0, 0.0, 0.0));
            _bodyView = [[UIImageView alloc] initWithFrame:bodyViewFrame];
            _bodyView.contentMode = UIViewContentModeScaleAspectFit;
            _bodyView.backgroundColor = [UIColor whiteColor];
            [self.navigationController.view insertSubview:_bodyView atIndex:0];
        } else {
            UINavigationController *detailNavigationController = self.splitViewController.viewControllers[1];
            CGFloat navigationBarHeight = detailNavigationController.navigationBar.bounds.size.height;
            CGRect bodyViewFrame = UIEdgeInsetsInsetRect(detailNavigationController.view.bounds, UIEdgeInsetsMake(navigationBarHeight, 0.0, 0.0, 0.0));
            _bodyView = [[UIImageView alloc] initWithFrame:bodyViewFrame];
            _bodyView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            _bodyView.contentMode = UIViewContentModeScaleAspectFit;
            _bodyView.backgroundColor = [UIColor whiteColor];
            [detailNavigationController.view insertSubview:_bodyView atIndex:0];
        }
    }
    return _bodyView;
}

#pragma mark - Lifecycle

- (IBAction)moreViewControllerUnwound:(UIStoryboardSegue *)segue
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"攻略";

    NSURL *propertyListURL = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"Guide.plist"];
    NSDictionary *propertyListInfo = [NSDictionary dictionaryWithContentsOfURL:propertyListURL];
    self.sections = [propertyListInfo objectForKey:PropertyListBasedViewControllerSectionsKey];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        
        UINavigationController *detailNavigationController = self.splitViewController.viewControllers[1];
        GuideDetailViewController *detailViewController = (GuideDetailViewController *)detailNavigationController.topViewController;

        [self displayDetailViewController:detailViewController withSelectedIndexPath:indexPath];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *sectionInfo = [self.sections objectAtIndex:indexPath.section];
        NSArray *rows = [sectionInfo objectForKey:PropertyListBasedViewControllerRowsKey];
        NSDictionary *rowInfo = [rows objectAtIndex:indexPath.row];
        NSString *rowTitle = [rowInfo objectForKey:PropertyListBasedViewControllerRowTitleKey];
        NSString *next = [rowInfo objectForKey:PropertyListBasedViewControllerNextKey];
        NSString *nextBackgroundImage = [rowInfo objectForKey:GuideMasterViewControllerNextBackgroundImageKey];
        
        NSURL *detailPropertyListURL = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:next];
        NSDictionary *detailPropertyListInfo = [NSDictionary dictionaryWithContentsOfURL:detailPropertyListURL];
        NSArray *detailSections = [detailPropertyListInfo objectForKey:PropertyListBasedViewControllerSectionsKey];
        
        GuideDetailViewController *detailViewController = (GuideDetailViewController *)[segue.destinationViewController topViewController];
        detailViewController.title = rowTitle;
        detailViewController.sections = detailSections;
    }
}

- (void)displayDetailViewController:(GuideDetailViewController *)detailViewController withSelectedIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *sectionInfo = [self.sections objectAtIndex:indexPath.section];
    NSArray *rows = [sectionInfo objectForKey:PropertyListBasedViewControllerRowsKey];
    NSDictionary *rowInfo = [rows objectAtIndex:indexPath.row];
    NSString *rowTitle = [rowInfo objectForKey:PropertyListBasedViewControllerRowTitleKey];
    NSString *next = [rowInfo objectForKey:PropertyListBasedViewControllerNextKey];
    NSString *nextBackgroundImage = [rowInfo objectForKey:GuideMasterViewControllerNextBackgroundImageKey];
    
    NSURL *detailPropertyListURL = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:next];
    NSDictionary *detailPropertyListInfo = [NSDictionary dictionaryWithContentsOfURL:detailPropertyListURL];
    NSArray *detailSections = [detailPropertyListInfo objectForKey:PropertyListBasedViewControllerSectionsKey];
    
    detailViewController.title = rowTitle;
    detailViewController.sections = detailSections;
    
//    self.bodyView.image = [UIImage imageNamed:nextBackgroundImage];
}

#pragma mark - State Restoration

#define GuideMasterViewControllerSelectedIndexPathKey @"SelectedIndexPath"

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:[self.tableView indexPathForSelectedRow] forKey:GuideMasterViewControllerSelectedIndexPathKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    NSIndexPath *selectedIndexPath = [coder decodeObjectForKey:GuideMasterViewControllerSelectedIndexPathKey];
    if (selectedIndexPath) {
        [self.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
        
        NSDictionary *sectionInfo = [self.sections objectAtIndex:selectedIndexPath.section];
        NSArray *rows = [sectionInfo objectForKey:PropertyListBasedViewControllerRowsKey];
        NSDictionary *rowInfo = [rows objectAtIndex:selectedIndexPath.row];
        NSString *nextBackgroundImage = [rowInfo objectForKey:GuideMasterViewControllerNextBackgroundImageKey];
        self.bodyView.image = [UIImage imageNamed:nextBackgroundImage];
    }
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && [[tableView cellForRowAtIndexPath:indexPath] isSelected]) {
        UINavigationController *detailNavigationController = self.splitViewController.viewControllers[1];
        [detailNavigationController popToRootViewControllerAnimated:YES];
        return nil;
    } else {
        return indexPath;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self performSegueWithIdentifier:@"ShowDetail" sender:nil];
    } else {
        UINavigationController *detailNavigationController = self.splitViewController.viewControllers[1];
        [detailNavigationController popToRootViewControllerAnimated:NO];
        GuideDetailViewController *detailViewController = (GuideDetailViewController *)detailNavigationController.topViewController;
        [self displayDetailViewController:detailViewController withSelectedIndexPath:indexPath];
        detailViewController.tableView.contentOffset = CGPointZero;
        [detailViewController.tableView reloadData];
        [detailViewController.tableView flashScrollIndicators];
    }
}

@end

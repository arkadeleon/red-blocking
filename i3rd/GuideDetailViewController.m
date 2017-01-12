
#import "GuideDetailViewController.h"

NSString *const GuideDetailViewControllerCharacterCodeKey = @"CharacterCode";
NSString *const GuideDetailViewControllerSkillCodeKey = @"SkillCode";
NSString *const GuideDetailViewControllerSkillNameKey = @"SkillName";
NSString *const GuideDetailViewControllerViewControllerKey = @"ViewController";
NSString *const GuideDetailViewControllerPresentSkillMotionPlayerViewControllerSegue = @"PresentSkillMotionPlayerViewController";

@interface GuideDetailViewController ()

@end

@implementation GuideDetailViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    UIView *tableViewBackgroundView = [[UIView alloc] initWithFrame:self.tableView.bounds];
//    tableViewBackgroundView.backgroundColor = [UIColor clearColor];
//    self.tableView.backgroundView = tableViewBackgroundView;
//    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:GuideDetailViewControllerPresentSkillMotionPlayerViewControllerSegue]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *sectionInfo = [self.sections objectAtIndex:indexPath.section];
        NSArray *rows = [sectionInfo objectForKey:PropertyListBasedViewControllerRowsKey];
        NSDictionary *rowInfo = [rows objectAtIndex:indexPath.row];
        NSDictionary *presented = [rowInfo objectForKey:PropertyListBasedViewControllerPresentedKey];
        
        SkillMotionPlayerViewController *player = (SkillMotionPlayerViewController *)[segue.destinationViewController topViewController];
        player.delegate = self;
        player.characterCode = [presented objectForKey:GuideDetailViewControllerCharacterCodeKey];
        player.skillCode = [presented objectForKey:GuideDetailViewControllerSkillCodeKey];
        player.title = [presented objectForKey:GuideDetailViewControllerSkillNameKey];
    }
}

#pragma mark - State Restoration

#define GuideDetailViewControllerTitleKey @"Title"
#define GuideDetailViewControllerSelectedIndexPathKey @"SelectedIndexPath"

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:self.title forKey:GuideDetailViewControllerTitleKey];
    [coder encodeObject:self.sections forKey:PropertyListBasedViewControllerSectionsKey];
    [coder encodeObject:[self.tableView indexPathForSelectedRow] forKey:GuideDetailViewControllerSelectedIndexPathKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    self.title = [coder decodeObjectForKey:GuideDetailViewControllerTitleKey];
    self.sections = [coder decodeObjectForKey:PropertyListBasedViewControllerSectionsKey];
    NSIndexPath *selectedIndexPath = [coder decodeObjectForKey:GuideDetailViewControllerSelectedIndexPathKey];
    [self.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *sectionInfo = [self.sections objectAtIndex:indexPath.section];
    NSArray *rows = [sectionInfo objectForKey:PropertyListBasedViewControllerRowsKey];
    NSDictionary *rowInfo = [rows objectAtIndex:indexPath.row];
    NSString *rowTitle = [rowInfo objectForKey:PropertyListBasedViewControllerRowTitleKey];
    id next = [rowInfo objectForKey:PropertyListBasedViewControllerNextKey];
    NSDictionary *presented = [rowInfo objectForKey:PropertyListBasedViewControllerPresentedKey];
    
    if (next) {
        NSDictionary *propertyListInfo;
        if ([next isKindOfClass:[NSString class]]) {
            NSURL *propertyListURL = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:next];
            propertyListInfo = [[NSDictionary alloc] initWithContentsOfURL:propertyListURL];
        } else {
            propertyListInfo = next;
        }
        NSArray *nextSectionsInfo = [propertyListInfo objectForKey:PropertyListBasedViewControllerSectionsKey];
        
        GuideDetailViewController *nextViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GuideDetailViewController"];
        nextViewController.title = rowTitle;
        nextViewController.sections = nextSectionsInfo;
        [self.navigationController pushViewController:nextViewController animated:YES];
    } else if (presented) {
        NSString *presentedViewControllerName = [presented objectForKey:GuideDetailViewControllerViewControllerKey];
        if ([presentedViewControllerName isEqualToString:@"FramesPlayerViewController"]) {
            [self performSegueWithIdentifier:GuideDetailViewControllerPresentSkillMotionPlayerViewControllerSegue sender:self];
        }
    }
}

#pragma mark - Skill Motion Player View Controller Delegate

- (void)willDismissSkillMotionPlayerViewController:(SkillMotionPlayerViewController *)skillMotionPlayerViewController
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }
}

@end

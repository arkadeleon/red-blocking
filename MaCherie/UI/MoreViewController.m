
#import "MoreViewController.h"
#import "MaCherie-Swift.h"

const NSInteger FeedbackCellSection = 0;
const NSInteger FeedbackCellRow = 0;
const NSInteger DeleteDocumentsAndDataCellSection = 1;
const NSInteger DeleteDocumentsAndDataCellRow = 0;

const NSInteger DeleteDocumentsAndDataViewTag = 1000;

@interface MoreViewController ()

- (BOOL)deleteDocumentsAndData;

@end

@implementation MoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (BOOL)deleteDocumentsAndData
{
    DownloadManager *downloadManager = DownloadManager.shared;
    NSURL *framesDataPath = [[downloadManager localBaseURL] URLByAppendingPathComponent:@"motions"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager removeItemAtURL:framesDataPath error:nil];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == FeedbackCellSection && indexPath.row == FeedbackCellRow) {
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        mailComposeViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        mailComposeViewController.mailComposeDelegate = self;
        mailComposeViewController.restorationIdentifier = NSStringFromClass([MFMailComposeViewController class]);
        [mailComposeViewController setSubject:@"About MaCherie"];
        [mailComposeViewController setToRecipients:@[@"david1988929@163.com"]];
        [self presentViewController:mailComposeViewController animated:YES completion:NULL];
    } else if (indexPath.section == DeleteDocumentsAndDataCellSection && indexPath.row == DeleteDocumentsAndDataCellRow) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"您确定要清除缓存吗？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"清除缓存" otherButtonTitles:nil];
            actionSheet.tag = DeleteDocumentsAndDataViewTag;
            [actionSheet showFromTabBar:self.tabBarController.tabBar];
        } else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"清除缓存" message:@"您确定要清除缓存吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"清除", nil];
            alertView.tag = DeleteDocumentsAndDataViewTag;
            [alertView show];
        }
    }
}

#pragma mark - Mail Compose View Controller Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        }
    }];
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == DeleteDocumentsAndDataViewTag) {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            [self deleteDocumentsAndData];
        }
    }
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == DeleteDocumentsAndDataViewTag) {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [self deleteDocumentsAndData];
        }
    }
}

@end

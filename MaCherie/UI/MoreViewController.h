
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface MoreViewController : UITableViewController <MFMailComposeViewControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
{
    BOOL _aboutApplicationExpanded;
}

@property (nonatomic, weak) IBOutlet UILabel *remainingNetworkTrafficLabel;

@end

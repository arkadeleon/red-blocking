
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UISplitViewControllerDelegate>

@property (nonatomic, strong) UIWindow *window;

+ (AppDelegate *)sharedDelegate;

@end


#import "AppDelegate.h"
#import "ApplicationDataManager.h"

@implementation AppDelegate

+ (AppDelegate *)sharedDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - Application Delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    splitViewController.delegate = self;
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{Player1PassiveHitboxHiddenKey : @NO, Player1OtherVulnerabilityHitboxHiddenKey : @NO, Player1ActiveHitboxHiddenKey : @NO, Player1ThrowHitboxHiddenKey : @NO, Player1ThrowableHitboxHiddenKey : @NO, Player1PushHitboxHiddenKey : @NO, Player2PassiveHitboxHiddenKey : @YES, Player2OtherVulnerabilityHitboxHiddenKey : @YES, Player2ActiveHitboxHiddenKey : @YES, Player2ThrowHitboxHiddenKey : @YES, Player2ThrowableHitboxHiddenKey : @YES, Player2PushHitboxHiddenKey : @YES, PreferredPassiveHitboxRGBColorKey : @0x0000FF, PreferredOtherVulnerabilityHitboxRGBColorKey : @0x007FFF, PreferredActiveHitboxRGBColorKey : @0xFF0000, PreferredThrowHitboxRGBColorKey : @0xFF7F00, PreferredThrowableHitboxRGBColorKey : @0x00FF00, PreferredPushHitboxRGBColorKey : @0x7F00FF, PreferredFramesPerSecondKey : @30}];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:ApplicationStateRestorationVersionKey];
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *applicationStateRestorationVersion = [[NSUserDefaults standardUserDefaults] stringForKey:ApplicationStateRestorationVersionKey];
    return [applicationStateRestorationVersion isEqualToString:version];
}

#pragma mark - Split View Controller Delegate

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    GuideDetailViewController *detailViewController = (GuideDetailViewController *)(((UINavigationController *)secondaryViewController).topViewController);
    if (detailViewController.sections == nil) {
        return YES;
    }
    return NO;
}

@end

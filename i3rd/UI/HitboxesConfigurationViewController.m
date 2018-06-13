
#import "HitboxesConfigurationViewController.h"
#import "UIColor+Integer.h"
#import "ApplicationDataManager.h"

NSString *const HitboxesConfigurationViewControllerTableViewCellIdentifier = @"HitboxesConfigurationTableViewCell";

@interface HitboxesConfigurationViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *playerControl;
@property (weak, nonatomic) IBOutlet UISwitch *passiveHitboxesSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *otherVulnerabilityHitboxesSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *activeHitboxesSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *throwHitboxesSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *throwableHitboxesSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *pushHitboxesSwitch;

- (IBAction)playerChanged:(id)sender;
- (IBAction)dismiss:(id)sender;
- (IBAction)switchValueChanged:(id)sender;

@end

@implementation HitboxesConfigurationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self playerChanged:self.playerControl];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.passiveHitboxesSwitch.onTintColor = [UIColor colorWithRGB:[userDefaults integerForKey:PreferredPassiveHitboxRGBColorKey] alpha:0.5];
    self.otherVulnerabilityHitboxesSwitch.onTintColor = [UIColor colorWithRGB:[userDefaults integerForKey:PreferredOtherVulnerabilityHitboxRGBColorKey] alpha:0.5];
    self.activeHitboxesSwitch.onTintColor = [UIColor colorWithRGB:[userDefaults integerForKey:PreferredActiveHitboxRGBColorKey] alpha:0.5];
    self.throwHitboxesSwitch.onTintColor = [UIColor colorWithRGB:[userDefaults integerForKey:PreferredThrowHitboxRGBColorKey] alpha:0.5];
    self.throwableHitboxesSwitch.onTintColor = [UIColor colorWithRGB:[userDefaults integerForKey:PreferredThrowableHitboxRGBColorKey] alpha:0.5];
    self.pushHitboxesSwitch.onTintColor = [UIColor colorWithRGB:[userDefaults integerForKey:PreferredPushHitboxRGBColorKey] alpha:0.5];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
}

#pragma mark - Action

- (IBAction)playerChanged:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    switch (self.playerControl.selectedSegmentIndex) {
        case 0:
            [self.passiveHitboxesSwitch setOn:![userDefaults boolForKey:Player1PassiveHitboxHiddenKey] animated:YES];
            [self.otherVulnerabilityHitboxesSwitch setOn:![userDefaults boolForKey:Player1OtherVulnerabilityHitboxHiddenKey] animated:YES];
            [self.activeHitboxesSwitch setOn:![userDefaults boolForKey:Player1ActiveHitboxHiddenKey] animated:YES];
            [self.throwHitboxesSwitch setOn:![userDefaults boolForKey:Player1ThrowHitboxHiddenKey] animated:YES];
            [self.throwableHitboxesSwitch setOn:![userDefaults boolForKey:Player1ThrowableHitboxHiddenKey] animated:YES];
            [self.pushHitboxesSwitch setOn:![userDefaults boolForKey:Player1PushHitboxHiddenKey] animated:YES];
            break;
        case 1:
            [self.passiveHitboxesSwitch setOn:![userDefaults boolForKey:Player2PassiveHitboxHiddenKey] animated:YES];
            [self.otherVulnerabilityHitboxesSwitch setOn:![userDefaults boolForKey:Player2OtherVulnerabilityHitboxHiddenKey] animated:YES];
            [self.activeHitboxesSwitch setOn:![userDefaults boolForKey:Player2ActiveHitboxHiddenKey] animated:YES];
            [self.throwHitboxesSwitch setOn:![userDefaults boolForKey:Player2ThrowHitboxHiddenKey] animated:YES];
            [self.throwableHitboxesSwitch setOn:![userDefaults boolForKey:Player2ThrowableHitboxHiddenKey] animated:YES];
            [self.pushHitboxesSwitch setOn:![userDefaults boolForKey:Player2PushHitboxHiddenKey] animated:YES];
            break;
        default:
            break;
    }
}

- (IBAction)dismiss:(id)sender
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (IBAction)switchValueChanged:(id)sender
{
    UISwitch *control = (UISwitch *)sender;
    NSInteger index = self.playerControl.selectedSegmentIndex * [self.tableView numberOfRowsInSection:0] + control.tag;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    switch (index) {
        case 1:
            [userDefaults setBool:!control.on forKey:Player1PassiveHitboxHiddenKey];
            break;
        case 2:
            [userDefaults setBool:!control.on forKey:Player1OtherVulnerabilityHitboxHiddenKey];
            break;
        case 3:
            [userDefaults setBool:!control.on forKey:Player1ActiveHitboxHiddenKey];
            break;
        case 4:
            [userDefaults setBool:!control.on forKey:Player1ThrowHitboxHiddenKey];
            break;
        case 5:
            [userDefaults setBool:!control.on forKey:Player1ThrowableHitboxHiddenKey];
            break;
        case 6:
            [userDefaults setBool:!control.on forKey:Player1PushHitboxHiddenKey];
            break;
        case 7:
            [userDefaults setBool:!control.on forKey:Player2PassiveHitboxHiddenKey];
            break;
        case 8:
            [userDefaults setBool:!control.on forKey:Player2OtherVulnerabilityHitboxHiddenKey];
            break;
        case 9:
            [userDefaults setBool:!control.on forKey:Player2ActiveHitboxHiddenKey];
            break;
        case 10:
            [userDefaults setBool:!control.on forKey:Player1ThrowHitboxHiddenKey];
            break;
        case 11:
            [userDefaults setBool:!control.on forKey:Player1ThrowableHitboxHiddenKey];
            break;
        case 12:
            [userDefaults setBool:!control.on forKey:Player2PushHitboxHiddenKey];
            break;
        default:
            break;
    }
}

@end

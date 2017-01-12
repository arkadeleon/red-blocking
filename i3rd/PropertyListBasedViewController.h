
extern NSString *const PropertyListBasedViewControllerSectionsKey;
extern NSString *const PropertyListBasedViewControllerSectionTitleKey;
extern NSString *const PropertyListBasedViewControllerRowsKey;
extern NSString *const PropertyListBasedViewControllerRowImageKey;
extern NSString *const PropertyListBasedViewControllerRowTitleKey;
extern NSString *const PropertyListBasedViewControllerRowDetailKey;
extern NSString *const PropertyListBasedViewControllerNextKey;
extern NSString *const PropertyListBasedViewControllerPresentedKey;

@interface PropertyListBasedViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIDataSourceModelAssociation>

@property (strong, nonatomic) NSArray *sections;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

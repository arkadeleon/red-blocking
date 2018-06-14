
#import <UIKit/UIKit.h>

@protocol DownloadManagerDelegate;

@interface DownloadManager : NSObject

@property (assign, nonatomic) id <DownloadManagerDelegate> delegate;

+ (DownloadManager *)defaultManager;
+ (NSOperationQueue *)sharedQueue;

- (NSString *)applicationDocumentsDirectory;
- (NSString *)dbankManualLinkBaseURL;

- (id)JSONObjectWithFileAtRelativePath:(NSString *)relativePath;
- (UIImage *)imageWithFileAtRelativePath:(NSString *)relativePath;

- (void)downloadJSONObjectWithFileAtRelativePath:(NSString *)relativePath;
- (void)downloadImageWithFileAtRelativePath:(NSString *)relativePath;

@end

@protocol DownloadManagerDelegate <NSObject>

- (void)downloadManager:(DownloadManager *)downloadManager didFinishDownloadingJSONObject:(id)jsonObject atRelativePath:(NSString *)relativePath;
- (void)downloadManager:(DownloadManager *)downloadManager didFailToDownloadJSONObjectAtRelativePath:(NSString *)relativePath;
- (void)downloadManager:(DownloadManager *)downloadManager didFinishDownloadingImage:(UIImage *)image atRelativePath:(NSString *)relativePath;
- (void)downloadManager:(DownloadManager *)downloadManager didFailToDownloadImageAtRelativePath:(NSString *)relativePath;

@end

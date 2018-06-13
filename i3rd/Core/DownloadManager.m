
#import "DownloadManager.h"

static DownloadManager *_downloadManager = nil;
static NSOperationQueue *_sharedQueue = nil;

@implementation DownloadManager

@synthesize delegate = _delegate;

+ (void)initialize
{
    if (self == [DownloadManager class]) {
        _sharedQueue = [[NSOperationQueue alloc] init];
        [_sharedQueue setMaxConcurrentOperationCount:3];
    }
}

+ (DownloadManager *)defaultManager
{
    if (_downloadManager == nil) {
        _downloadManager = [[DownloadManager alloc] init];
    }
    return _downloadManager;
}

+ (NSOperationQueue *)sharedQueue
{
    return _sharedQueue;
}

- (NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)dbankManualLinkBaseURL
{
    return @"https://leonandvane.date/apps/i3rd";
}

- (id)JSONObjectWithFileAtRelativePath:(NSString *)relativePath
{
    id jsonObject;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *absolutePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:relativePath];
    
    if ([fileManager fileExistsAtPath:absolutePath]) {
        NSData *jsonData = [NSData dataWithContentsOfFile:absolutePath];
        jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    }
    
    if (jsonObject == nil) {
        NSURL *url = [NSURL URLWithString:[self dbankManualLinkBaseURL]];
        url = [url URLByAppendingPathComponent:relativePath];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        if (responseData) {
            jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
            if (jsonObject) {
                [fileManager createDirectoryAtPath:[absolutePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
                [responseData writeToFile:absolutePath atomically:NO];
            }
        }
    }
    
    return jsonObject;
}

- (UIImage *)imageWithFileAtRelativePath:(NSString *)relativePath
{
    UIImage *image;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *absolutePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:relativePath];
    
    if ([fileManager fileExistsAtPath:absolutePath]) {
        NSData *imageData = [NSData dataWithContentsOfFile:absolutePath];
        image = [UIImage imageWithData:imageData];
    }
    
    if (image == nil) {
        NSURL *url = [NSURL URLWithString:[self dbankManualLinkBaseURL]];
        url = [url URLByAppendingPathComponent:relativePath];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        if (responseData) {
            image = [UIImage imageWithData:responseData];
            if (image) {
                [fileManager createDirectoryAtPath:[absolutePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
                [responseData writeToFile:absolutePath atomically:NO];
            }
        }
    }
    
    return image;
}

- (void)downloadJSONObjectWithFileAtRelativePath:(NSString *)relativePath
{
    [_sharedQueue addOperationWithBlock:^{
        id jsonObject = [self JSONObjectWithFileAtRelativePath:relativePath];
        if (jsonObject) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(downloadManager:didFinishDownloadingJSONObject:atRelativePath:)]) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.delegate downloadManager:self didFinishDownloadingJSONObject:jsonObject atRelativePath:relativePath];
                }];
            }
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(downloadManager:didFailToDownloadJSONObjectAtRelativePath:)]) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.delegate downloadManager:self didFailToDownloadJSONObjectAtRelativePath:relativePath];
                }];
            }
        }
    }];
}

- (void)downloadImageWithFileAtRelativePath:(NSString *)relativePath
{
    [_sharedQueue addOperationWithBlock:^{
        UIImage *image = [self imageWithFileAtRelativePath:relativePath];
        if (image) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(downloadManager:didFinishDownloadingImage:atRelativePath:)]) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.delegate downloadManager:self didFinishDownloadingImage:image atRelativePath:relativePath];
                }];
            }
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(downloadManager:didFailToDownloadImageAtRelativePath:)]) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.delegate downloadManager:self didFailToDownloadImageAtRelativePath:relativePath];
                }];
            }
        }
    }];
}

@end


#import "DownloadManager.h"

typedef enum SkillMotionPlaybackState {
    SkillMotionPlaybackStateStopped,
    SkillMotionPlaybackStatePlaying,
    SkillMotionPlaybackStatePaused,
    SkillMotionPlaybackStateInterrupted,
    SkillMotionPlaybackStateSeekingForward,
    SkillMotionPlaybackStateSeekingBackward
} SkillMotionPlaybackState;

@protocol SkillMotionPlayerViewControllerDelegate;

@interface SkillMotionPlayerViewController : UIViewController <DownloadManagerDelegate, UIAlertViewDelegate, UIPopoverPresentationControllerDelegate>
{
    NSTimer *_playTimer;
    NSTimer *_seekingForwardTimer;
    NSTimer *_seekingBackwardTimer;
    
    NSMutableDictionary *_frameImages;
    
    __weak UIPopoverPresentationController *_hitboxPopoverController;
}

@property (weak, nonatomic) id <SkillMotionPlayerViewControllerDelegate> delegate;
@property (strong, nonatomic) NSString *characterCode;
@property (strong, nonatomic) NSString *skillCode;

@property (readonly, assign, nonatomic) SkillMotionPlaybackState playbackState;
@property (readonly, assign, nonatomic) BOOL isPreparedToPlay;
@property (readonly, assign, nonatomic) NSUInteger numberOfFrames;
@property (assign, nonatomic) NSUInteger currentFrame;
@property (assign, nonatomic) NSUInteger currentFramesPerSecond;

- (void)play;
- (void)pause;
- (void)stop;

- (void)beginSeekingForward;
- (void)beginSeekingBackward;
- (void)endSeeking;

@end

@protocol SkillMotionPlayerViewControllerDelegate <NSObject>

- (void)willDismissSkillMotionPlayerViewController:(SkillMotionPlayerViewController *)skillMotionPlayerViewController;

@end

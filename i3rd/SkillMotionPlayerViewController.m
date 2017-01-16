//
//  FramesPlayerViewController.m
//  i3rd
//
//  Created by pp on 12-4-8.
//  Copyright (c) 2012年 studiopp. All rights reserved.
//

#import "SkillMotionPlayerViewController.h"
#import "SkillMotionPlayer.h"
#import "ApplicationDataManager.h"

@interface SkillMotionPlayerViewController ()

@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgressView;
@property (weak, nonatomic) IBOutlet UILabel *currentFrameLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalFrameLabel;
@property (weak, nonatomic) IBOutlet UITextField *fpsTextField;
@property (weak, nonatomic) IBOutlet SkillMotionPlayer *framesPlayer;
@property (weak, nonatomic) IBOutlet UISlider *progressControl;

@property (strong, nonatomic) NSDictionary *framesInfo;

@property (readwrite, assign, nonatomic) SkillMotionPlaybackState playbackState;
@property (readwrite, assign, nonatomic) BOOL isPreparedToPlay;
@property (readwrite, assign, nonatomic) NSUInteger numberOfFrames;

- (IBAction)progressControlDown:(id)sender;
- (IBAction)progressControlUp:(id)sender;
- (IBAction)progressControlSlided:(id)sender;
- (IBAction)dismiss:(id)sender;
- (IBAction)fpsChanged:(id)sender;
- (IBAction)playOrPause:(id)sender;
- (IBAction)presentHitboxPopoverController:(id)sender;
- (void)update;
- (IBAction)seekingForwardButtonTouchDown:(id)sender;
- (IBAction)seekingForwardButtonTouchUp:(id)sender;
- (IBAction)seekingBackwardButtonTouchDown:(id)sender;
- (IBAction)seekingBackwardButtonTouchUp:(id)sender;

- (void)prepareToPlay;

@end

@implementation SkillMotionPlayerViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    _frameImages = [[NSMutableDictionary alloc] init];
    
    self.playbackState = SkillMotionPlaybackStateStopped;
    
    [self prepareToPlay];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.isPreparedToPlay) {
        [self update];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.isPreparedToPlay == YES && self.playbackState == SkillMotionPlaybackStatePlaying) {
        [self play];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_playTimer invalidate];
    _playTimer = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if ([segue.identifier isEqualToString:@"PresentHitboxPopoverController"]) {
            _hitboxPopoverController = segue.destinationViewController.popoverPresentationController;
            _hitboxPopoverController.delegate = self;
        }
    }
}

#pragma mark - Action

- (IBAction)dismiss:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(willDismissSkillMotionPlayerViewController:)]) {
        [self.delegate willDismissSkillMotionPlayerViewController:self];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[DownloadManager defaultManager] setDelegate:nil];
        [[DownloadManager sharedQueue] cancelAllOperations];
        [_playTimer invalidate];
        [_seekingForwardTimer invalidate];
        [_seekingBackwardTimer invalidate];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

- (IBAction)progressControlDown:(id)sender
{
    [_playTimer invalidate];
    _playTimer = nil;
}

- (IBAction)progressControlUp:(id)sender
{
    if (self.playbackState == SkillMotionPlaybackStatePlaying) {
        [self play];
    }
}

- (IBAction)progressControlSlided:(id)sender
{
    self.currentFrame = self.progressControl.value;
    [self update];
}

- (IBAction)fpsChanged:(id)sender {
    self.currentFramesPerSecond = self.fpsTextField.text.integerValue;
    self.currentFramesPerSecond = MAX(self.currentFramesPerSecond, 0);
    self.currentFramesPerSecond = MIN(self.currentFramesPerSecond, 60);
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.currentFramesPerSecond forKey:PreferredFramesPerSecondKey];
    self.fpsTextField.text = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)self.currentFramesPerSecond];
    
    if (self.playbackState == SkillMotionPlaybackStatePlaying) {
        [_playTimer invalidate];
        _playTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / self.currentFramesPerSecond target:self selector:@selector(playTimerFired:) userInfo:nil repeats:YES];
    }
}

- (IBAction)playOrPause:(id)sender
{
    if (self.playbackState == SkillMotionPlaybackStatePlaying) {
        [self pause];
    } else {
        [self play];
    }
}

- (IBAction)presentHitboxPopoverController:(id)sender
{
    if (_hitboxPopoverController == nil) {
        [self performSegueWithIdentifier:@"PresentHitboxPopoverController" sender:sender];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self update];
    }
}

- (void)update
{
    NSString *key = [NSString stringWithFormat:@"motions/%@/%@/%@_%@_%03lu.png", self.characterCode, self.skillCode, self.characterCode, self.skillCode, (unsigned long)self.currentFrame];
    UIImage *frameImage = [_frameImages objectForKey:key];
    if ([frameImage class] == [NSNull class]) {
        frameImage = nil;
    }
    NSDictionary *frameInfo = [self.framesInfo objectForKey:[NSString stringWithFormat:@"%03lu", (unsigned long)self.currentFrame]];
    
    [self.framesPlayer drawFrameImage:frameImage withFrameInfo:frameInfo];
    self.currentFrameLabel.text = [[NSString alloc] initWithFormat:@"%03lu", (unsigned long)self.currentFrame];
    self.totalFrameLabel.text = [[NSString alloc] initWithFormat:@"%03lu", self.numberOfFrames - 1];
    self.progressControl.value = self.currentFrame;
}

- (IBAction)seekingForwardButtonTouchDown:(id)sender
{
    [self beginSeekingForward];
}

- (IBAction)seekingForwardButtonTouchUp:(id)sender
{
    [self endSeeking];
    
}

- (IBAction)seekingBackwardButtonTouchDown:(id)sender
{
    [self beginSeekingBackward];
}

- (IBAction)seekingBackwardButtonTouchUp:(id)sender
{
    [self endSeeking];
}

#pragma mark - Playback

- (void)prepareToPlay
{
    self.isPreparedToPlay = NO;
    
    self.downloadProgressView.progress = 0.0;
    
    self.currentFrame = 0;
    self.currentFramesPerSecond = [[NSUserDefaults standardUserDefaults] integerForKey:PreferredFramesPerSecondKey];
    self.fpsTextField.text = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)self.currentFramesPerSecond];
    
    self.progressControl.userInteractionEnabled = NO;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[DownloadManager defaultManager] setDelegate:self];
    
    NSString *jsonFilePath = [NSString stringWithFormat:@"motions/%@/%@/%@_%@.json", self.characterCode, self.skillCode, self.characterCode, self.skillCode];
    [[DownloadManager defaultManager] downloadJSONObjectWithFileAtRelativePath:jsonFilePath];
}

- (void)play
{
    if (self.isPreparedToPlay == YES) {
        self.playbackState = SkillMotionPlaybackStatePlaying;
        
        self.currentFrame = (self.currentFrame + 1) % self.numberOfFrames;
        [self update];
        
        if (_playTimer == nil) {
            _playTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / self.currentFramesPerSecond target:self selector:@selector(playTimerFired:) userInfo:nil repeats:YES];
        }
    }
}

- (void)pause
{
    if (self.isPreparedToPlay == YES) {
        self.playbackState = SkillMotionPlaybackStatePaused;
        
        [_playTimer invalidate];
        _playTimer = nil;
    }
}

- (void)stop
{
    if (self.isPreparedToPlay == YES) {
        self.playbackState = SkillMotionPlaybackStateStopped;
        
        [_playTimer invalidate];
        _playTimer = nil;
        
        self.currentFrame = 0;
    }
}

- (void)beginSeekingForward
{
    if (self.isPreparedToPlay == YES) {
        self.playbackState = SkillMotionPlaybackStateSeekingForward;
        
        [_playTimer invalidate];
        _playTimer = nil;
        
        self.currentFrame = (self.currentFrame + 1) % self.numberOfFrames;
        [self update];
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.8 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (self.playbackState == SkillMotionPlaybackStateSeekingForward) {
                self.currentFrame = (self.currentFrame + 1) % self.numberOfFrames;
                [self update];
                if (_seekingForwardTimer == nil) {
                    _seekingForwardTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / self.currentFramesPerSecond target:self selector:@selector(seekingForwardTimerFired:) userInfo:nil repeats:YES];
                }
            }
        });
    }
}

- (void)beginSeekingBackward
{
    if (self.isPreparedToPlay == YES) {
        self.playbackState = SkillMotionPlaybackStateSeekingBackward;
        
        [_playTimer invalidate];
        _playTimer = nil;
        
        self.currentFrame = (self.currentFrame - 1 + self.numberOfFrames) % self.numberOfFrames;
        [self update];
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.8 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (self.playbackState == SkillMotionPlaybackStateSeekingBackward) {
                self.currentFrame = (self.currentFrame - 1 + self.numberOfFrames) % self.numberOfFrames;
                [self update];
                if (_seekingBackwardTimer == nil) {
                    _seekingBackwardTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / self.currentFramesPerSecond target:self selector:@selector(seekingBackwardTimerFired:) userInfo:nil repeats:YES];
                }
            }
        });
    }
}

- (void)endSeeking
{
    if (self.isPreparedToPlay == YES) {
        self.playbackState = SkillMotionPlaybackStatePaused;
        
        [_seekingForwardTimer invalidate];
        _seekingForwardTimer = nil;
        
        [_seekingBackwardTimer invalidate];
        _seekingBackwardTimer = nil;
    }
}

#pragma mark - Timer

- (void)playTimerFired:(NSTimer *)timer
{
    self.currentFrame = (self.currentFrame + 1) % self.numberOfFrames;
    [self update];
}

- (void)seekingForwardTimerFired:(NSTimer *)timer
{
    self.currentFrame = (self.currentFrame + 1) % self.numberOfFrames;
    [self update];
}

- (void)seekingBackwardTimerFired:(NSTimer *)timer
{
    self.currentFrame = (self.currentFrame - 1 + self.numberOfFrames) % self.numberOfFrames;
    [self update];
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:true];
    return YES;
}

#pragma mark - Download Manager Delegate

- (void)downloadManager:(DownloadManager *)downloadManager didFinishDownloadingJSONObject:(id)jsonObject atRelativePath:(NSString *)relativePath
{
    self.framesInfo = jsonObject;
    self.numberOfFrames = [self.framesInfo count];
    
    self.currentFrameLabel.text = @"000";
    self.totalFrameLabel.text = [[NSString alloc] initWithFormat:@"%03lu", self.numberOfFrames - 1];
    self.progressControl.maximumValue = self.numberOfFrames - 1;
    
    for (int i = 0; i < self.numberOfFrames; i++) {
        NSString *imageFilePath = [NSString stringWithFormat:@"motions/%@/%@/%@_%@_%03d.png", self.characterCode, self.skillCode, self.characterCode, self.skillCode, i];
        [[DownloadManager defaultManager] downloadImageWithFileAtRelativePath:imageFilePath];
    }
}

- (void)downloadManager:(DownloadManager *)downloadManager didFailToDownloadJSONObjectAtRelativePath:(NSString *)relativePath
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"无法连接到服务器" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", @"重试", nil];
    [alertView show];
}

- (void)downloadManager:(DownloadManager *)downloadManager didFinishDownloadingImage:(UIImage *)image atRelativePath:(NSString *)relativePath
{
    [_frameImages setObject:image forKey:relativePath];
    NSUInteger numberOfImagesDownloaded = [_frameImages count];
    
    [self.downloadProgressView setProgress:1.0 * numberOfImagesDownloaded / self.numberOfFrames animated:YES];
    
    if (numberOfImagesDownloaded == self.numberOfFrames) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        self.downloadProgressView.hidden = YES;
        
        self.progressControl.userInteractionEnabled = YES;
        
        [self update];
        
        self.isPreparedToPlay = YES;
    }
}

- (void)downloadManager:(DownloadManager *)downloadManager didFailToDownloadImageAtRelativePath:(NSString *)relativePath
{
    [_frameImages setObject:[NSNull null] forKey:relativePath];
    NSUInteger numberOfImagesDownloaded = [_frameImages count];
    
    [self.downloadProgressView setProgress:1.0 * numberOfImagesDownloaded / self.numberOfFrames animated:YES];
    
    if (numberOfImagesDownloaded == self.numberOfFrames) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        self.downloadProgressView.hidden = YES;
        
        self.progressControl.userInteractionEnabled = YES;
        
        [self update];
        
        self.isPreparedToPlay = YES;
    }
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [self dismiss:nil];
    } else if (buttonIndex == alertView.firstOtherButtonIndex + 1) {
        [self prepareToPlay];
    }
}

#pragma mark - Popover Controller Delegate

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    [self update];
}

#pragma mark - Application Notification

- (void)applicationDidEnterBackground:(NSNotification *)note
{
    UIBackgroundTaskIdentifier backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskIdentifier];
    }];
}

@end

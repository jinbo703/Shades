//
//  HBRecorder.m
//  HBRecorder
//
//  Created by HilalB on 11/07/2016.
//  Copyright (c) 2016 HilalB. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SCTouchDetector.h"
#import "HBRecorder.h"
#import "SCImageDisplayerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SCSessionListViewController.h"
#import "SCRecordSessionManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "SCWatermarkOverlayView.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "HBTransition.h"


#define kVideoPreset AVCaptureSessionPresetHigh

////////////////////////////////////////////////////////////
// PRIVATE DEFINITION
/////////////////////

@interface HBRecorder () <SCAssetExportSessionDelegate> {
    UIImage *_photo;
    SCRecordSession *_recordSession;
    UIImageView *_ghostImageView;
    BOOL hasOrientaionLocked;
    
    int prevDuration;
    int pprevDuration;

    NSURL *_urlRecorded;
    
}

@property (strong, nonatomic) SCRecorderToolsView *focusView;

@end

////////////////////////////////////////////////////////////
// IMPLEMENTATION
/////////////////////

@implementation HBRecorder

#pragma mark - UIViewController

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#endif

#pragma mark - Left cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.capturePhotoButton.alpha = 0.0;
    
    prevDuration = 0;
    pprevDuration = 0;
    _currentRecord = 0;
    
    _ghostImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _ghostImageView.contentMode = UIViewContentModeScaleAspectFill;
    _ghostImageView.alpha = 0.2;
    _ghostImageView.userInteractionEnabled = NO;
    _ghostImageView.hidden = YES;
    
    [self.view insertSubview:_ghostImageView aboveSubview:self.previewView];
    
    [self.retakeButton addTarget:self action:@selector(handleRetakeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton addTarget:self action:@selector(handleStopButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.reverseCamera addTarget:self action:@selector(handleReverseCameraTapped:) forControlEvents:UIControlEventTouchUpInside];

    self.loadingView.hidden = YES;
    
    [self initRecorder];
    
    UIView *previewView = self.previewView;
    if ( self.focusView != nil ) {
        [self.focusView removeFromSuperview];
    }
    self.focusView = [[SCRecorderToolsView alloc] initWithFrame:previewView.bounds];
    self.focusView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [previewView addSubview:self.focusView];
    
    self.focusView.outsideFocusTargetImage = [self imageNamed:@"focus"];
    
    // Setup images for the Shutter Button
    UIImage *image;
    image = [self imageNamed:@"ShutterButtonStart"];
    self.recStartImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.recBtn setImage:self.recStartImage
                 forState:UIControlStateNormal];
    
    image = [self imageNamed:@"ShutterButtonStop"];
    self.recStopImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [self.recBtn setTintColor:[UIColor colorWithRed:255/255.
                                              green:255/255.
                                               blue:255/255.
                                              alpha:1.0]];
    self.outerImage1 = [self imageNamed:@"outer1"];
    self.outerImage2 = [self imageNamed:@"outer2"];
    self.outerImageView.image = self.outerImage1;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self prepareSession];
    
    self.navigationController.navigationBarHidden = YES;
    
}

- (void)initSession
{
    if (_recorder.session != nil)
    {
        [_recorder stopRunning];
    }
    SCRecordSession *session = [SCRecordSession recordSession];
    session.fileType = AVFileTypeQuickTimeMovie;
    
    _recorder.session = session;
    prevDuration = 0;
    pprevDuration = 0;
}

- (void)initRecorder
{
    _recorder = [SCRecorder recorder];
    _recorder.captureSessionPreset = [SCRecorderTools bestCaptureSessionPresetCompatibleWithAllDevices];
    
    if (_maxRecordDuration) {
        _recorder.maxRecordDuration = CMTimeMake(_maxRecordDuration, 1);
    }
    
    _recorder.fastRecordMethodEnabled = NO;
    _recorder.delegate = self;
    _recorder.autoSetVideoOrientation = YES; //YES causes bad orientation for video from camera roll
    
    _recorder.previewView = self.previewView;

    self.focusView.recorder = _recorder;
    
    _recorder.initializeSessionLazily = NO;
    
    NSError *error;
    if (![_recorder prepare:&error]) {
        NSLog(@"Prepare error: %@", error.localizedDescription);
    }
    
    if (_recorder.deviceHasFlash) {
        _flashModeButton.hidden = NO;
    } else {
        _flashModeButton.hidden = YES;
    }
    
    // audio recorder
    NSArray<NSString*> *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"sound.caf"];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    NSDictionary *recordSettings = [NSDictionary
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMin],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 2],
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0],
                                    AVSampleRateKey, nil];
}

-(UIImage*)imageNamed:(NSString*)imgName {
    
    NSBundle *bundle = [NSBundle bundleForClass:HBRecorder.class];
    
    return [UIImage imageNamed:imgName inBundle:bundle compatibleWithTraitCollection:nil];
    
}

- (void)recorder:(SCRecorder *)recorder didSkipVideoSampleBufferInSession:(SCRecordSession *)recordSession {
    NSLog(@"Skipped video buffer");
}

- (void)recorder:(SCRecorder *)recorder didReconfigureAudioInput:(NSError *)audioInputError {
    NSLog(@"Reconfigured audio input: %@", audioInputError);
}

- (void)recorder:(SCRecorder *)recorder didReconfigureVideoInput:(NSError *)videoInputError {
    NSLog(@"Reconfigured video input: %@", videoInputError);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [_recorder previewViewFrameChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_recorder startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_recorder stopRunning];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - Handle

- (void)showAlertViewWithTitle:(NSString*)title message:(NSString*) message {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)showVideo {
    [self performSegueWithIdentifier:@"Video" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[SCImageDisplayerViewController class]]) {
        SCImageDisplayerViewController *imageDisplayer = segue.destinationViewController;
        imageDisplayer.photo = _photo;
        _photo = nil;
    } else if ([segue.destinationViewController isKindOfClass:[SCSessionListViewController class]]) {
        SCSessionListViewController *sessionListVC = segue.destinationViewController;
        
        sessionListVC.recorder = _recorder;
    }
}

- (void)showPhoto:(UIImage *)photo {
    _photo = photo;
    [self performSegueWithIdentifier:@"Photo" sender:self];
}

- (void) handleReverseCameraTapped:(id)sender {
    [_recorder switchCaptureDevices];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *url = info[UIImagePickerControllerMediaURL];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    SCRecordSessionSegment *segment = [SCRecordSessionSegment segmentWithURL:url info:nil];
    
    [_recorder.session addSegment:segment];
    _recordSession = [SCRecordSession recordSession];
    [_recordSession addSegment:segment];
    
    [self showVideo];
}
- (void) handleStopButtonTapped:(id)sender {
    [_recorder pause:^{
        [self saveAndShowSession:_recorder.session];
    }];
}

- (void)saveAndShowSession:(SCRecordSession *)recordSession {
    [[SCRecordSessionManager sharedInstance] saveRecordSession:recordSession];
    
    _recordSession = recordSession;
    [self showVideo];
}

- (void)handleRetakeButtonTapped:(id)sender {
    SCRecordSession *recordSession = _recorder.session;
    
    if (recordSession != nil) {
        _recorder.session = nil;
        
        // If the recordSession was saved, we don't want to completely destroy it
        if ([[SCRecordSessionManager sharedInstance] isSaved:recordSession]) {
            [recordSession endSegmentWithInfo:nil completionHandler:nil];
        } else {
            [recordSession cancelSession:nil];
        }
    }
    
    [self prepareSession];
}

- (IBAction)switchCameraMode:(id)sender {
    if ([_recorder.captureSessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.capturePhotoButton.alpha = 0.0;
            self.recordView.alpha = 1.0;
            self.retakeButton.alpha = 1.0;
            self.stopButton.alpha = 1.0;
        } completion:^(BOOL finished) {
            _recorder.captureSessionPreset = kVideoPreset;
            [self.switchCameraModeButton setTitle:@"Switch Photo" forState:UIControlStateNormal];
            [self.flashModeButton setTitle:@"Flash : Off" forState:UIControlStateNormal];
            _recorder.flashMode = SCFlashModeOff;
        }];
    } else {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.recordView.alpha = 0.0;
            self.retakeButton.alpha = 0.0;
            self.stopButton.alpha = 0.0;
            self.capturePhotoButton.alpha = 1.0;
        } completion:^(BOOL finished) {
            _recorder.captureSessionPreset = AVCaptureSessionPresetPhoto;
            [self.switchCameraModeButton setTitle:@"Switch Video" forState:UIControlStateNormal];
            [self.flashModeButton setTitle:@"Flash : Auto" forState:UIControlStateNormal];
            _recorder.flashMode = SCFlashModeAuto;
        }];
    }
}

- (IBAction)switchFlash:(id)sender {
    
    [self switchFlashProc];
//    [self.flashModeButton setTitle:flashModeString forState:UIControlStateNormal];
}

- (bool) isFlashButtonOn {
    switch (_recorder.flashMode) {
        case SCFlashModeOff:
            return false;
            break;
        case SCFlashModeLight:
            return true;
            _recorder.flashMode = SCFlashModeOff;
            break;
        default:
            return true;
            break;
    }
}

- (void) switchFlashProc {
    NSString *flashModeString = nil;
    if ([_recorder.captureSessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
        switch (_recorder.flashMode) {
            case SCFlashModeAuto:
                flashModeString = @"Flash : Off";
                _recorder.flashMode = SCFlashModeOff;
                break;
            case SCFlashModeOff:
                flashModeString = @"Flash : On";
                _recorder.flashMode = SCFlashModeOn;
                break;
            case SCFlashModeOn:
                flashModeString = @"Flash : Light";
                _recorder.flashMode = SCFlashModeLight;
                break;
            case SCFlashModeLight:
                flashModeString = @"Flash : Auto";
                _recorder.flashMode = SCFlashModeAuto;
                break;
            default:
                break;
        }
    } else {
        switch (_recorder.flashMode) {
            case SCFlashModeOff:
                flashModeString = @"Flash : On";
                _recorder.flashMode = SCFlashModeLight;
                break;
            case SCFlashModeLight:
                flashModeString = @"Flash : Off";
                _recorder.flashMode = SCFlashModeOff;
                break;
            default:
                break;
        }
    }
}

- (void)prepareSession {
    if (_recorder.session == nil) {
        
        SCRecordSession *session = [SCRecordSession recordSession];
        session.fileType = AVFileTypeQuickTimeMovie;
        _recorder.session = session;
    }
    else {
    }
    
    [self updateTimeRecordedLabel];
    [self updateGhostImage];
}

- (void)recorder:(SCRecorder *)recorder didCompleteSession:(SCRecordSession *)recordSession {
    NSLog(@"didCompleteSession:");
//    [self saveAndShowSession:recordSession];
    [self stopRecordingVideo];
}

- (void)recorder:(SCRecorder *)recorder didInitializeAudioInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized audio in record session");
    } else {
        NSLog(@"Failed to initialize audio in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didInitializeVideoInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized video in record session");
    } else {
        NSLog(@"Failed to initialize video in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didBeginSegmentInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Began record segment: %@", error);
}

- (void)recorder:(SCRecorder *)recorder didCompleteSegment:(SCRecordSessionSegment *)segment inSession:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Completed record segment at %@: %@ (frameRate: %f)", segment.url, error, segment.frameRate);
    [self updateGhostImage];
    
    _urlRecorded = segment.url;
}

- (void)retakeShot
{
    self.currentRecord--;
    [_recorder.session removeLastSegment];
    prevDuration = pprevDuration;
}

- (void)updateTimeRecordedLabel {
    CMTime currentTime = kCMTimeZero;
    
    if (_recorder.session != nil) {
        currentTime = _recorder.session.duration;
    }
    
    self.timeRecordedLabel.text = [NSString stringWithFormat:@"%.02f", CMTimeGetSeconds(currentTime)];
    if (_currentRecord < _maxSegmentDurations.count ) {
        NSNumber* entry = (NSNumber*)[_maxSegmentDurations objectAtIndex:_currentRecord];
        int currentSegmentDuration = [entry intValue];
        self.lbRecDuration.text = [NSString stringWithFormat:@"%d", currentSegmentDuration - ((int)CMTimeGetSeconds(currentTime)-prevDuration)];
    }
}

- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBufferInSession:(SCRecordSession *)recordSession {
    [self updateTimeRecordedLabel];
    [self checkMaxSegmentDuration:recorder];
}

- (void)setMaxSegmentDurations:(NSMutableArray *)maxSegmentDurations {
    _maxSegmentDurations = [[NSMutableArray alloc] initWithArray:maxSegmentDurations];
}

-(void)checkMaxSegmentDuration:(SCRecorder *)recorder {
    if (_currentRecord > _maxSegmentDurations.count-1 ) {
        [_recorder stopRunning];
        return;
    }
    NSNumber* entry = (NSNumber*)[_maxSegmentDurations objectAtIndex:_currentRecord];
    int currentSegmentDuration = [entry intValue];
    if(currentSegmentDuration) {
        CMTime suggestedMaxSegmentDuration = CMTimeMake(currentSegmentDuration, 1);
        if (CMTIME_IS_VALID(suggestedMaxSegmentDuration)) {
            if (CMTIME_COMPARE_INLINE(recorder.session.currentSegmentDuration, >=, suggestedMaxSegmentDuration)) {
                [_recorder pause];
                _currentRecord++;
                NSLog(@"Current record id: %d", _currentRecord);
                pprevDuration = prevDuration;
                prevDuration = [self.timeRecordedLabel.text intValue];
                [self.recBtn setImage:self.recStartImage forState:UIControlStateNormal];
                if ( [self.delegate respondsToSelector:@selector(recorderUpdateProgress:)] )
                    [self.delegate recorderUpdateProgress:self];
                [self performSelector:@selector(updateDurationLabel) withObject:nil afterDelay:1.0];
            }
        }
    }
}

-(void)updateDurationLabel
{
    if (_currentRecord < _maxSegmentDurations.count ) {
        NSNumber* entry = (NSNumber*)[_maxSegmentDurations objectAtIndex:_currentRecord];
        int currentSegmentDuration = [entry intValue];
        self.lbRecDuration.text = [NSString stringWithFormat:@"%d", currentSegmentDuration];
    }
}

- (void)handleTouchDetected:(SCTouchDetector*)touchDetector {
    if (touchDetector.state == UIGestureRecognizerStateBegan) {
        _ghostImageView.hidden = YES;
        [_recorder record];
    } else if (touchDetector.state == UIGestureRecognizerStateEnded) {
        [_recorder pause];
    }
}

- (IBAction)capturePhoto:(id)sender {
    [_recorder capturePhoto:^(NSError *error, UIImage *image) {
        if (image != nil) {
            [self showPhoto:image];
        } else {
            [self showAlertViewWithTitle:@"Failed to capture photo" message:error.localizedDescription];
        }
    }];
}

- (void)updateGhostImage {
    UIImage *image = nil;
    
    if (_ghostModeButton.selected) {
        if (_recorder.session.segments.count > 0) {
            SCRecordSessionSegment *segment = [_recorder.session.segments lastObject];
            image = segment.lastImage;
        }
    }
    
    _ghostImageView.image = image;
    //    _ghostImageView.image = [_recorder snapshotOfLastAppendedVideoBuffer];
    _ghostImageView.hidden = !_ghostModeButton.selected;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)switchGhostMode:(id)sender {
    _ghostModeButton.selected = !_ghostModeButton.selected;
    _ghostImageView.hidden = !_ghostModeButton.selected;
    
    [self updateGhostImage];
}


- (IBAction)shutterButtonTapped:(UIButton *)sender {
    
    if ( _currentRecord > self.maxSegmentDurations.count-1 )
    {
        return;
    }
    
    if (!hasOrientaionLocked) {
        _recorder.autoSetVideoOrientation = NO;
        hasOrientaionLocked = YES;
        UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:currentOrientation] forKey:@"orientation"];
    }
    
    if (!_recorder.isRecording) {
        BOOL bRecordable = NO;
        if ( [self.delegate respondsToSelector:@selector(recorderBegin:)] )
            bRecordable = [self.delegate recorderBegin:self];
        if ( bRecordable == YES ) [_recorder record];
    }
}



- (IBAction)toolsButtonTapped:(UIButton *)sender {
    CGRect toolsFrame = self.toolsContainerView.frame;
    CGRect openToolsButtonFrame = self.openToolsButton.frame;
    
    if (toolsFrame.origin.y < 0) {
        sender.selected = YES;
        toolsFrame.origin.y = 0;
        openToolsButtonFrame.origin.y = toolsFrame.size.height + 15;
    } else {
        sender.selected = NO;
        toolsFrame.origin.y = -toolsFrame.size.height;
        openToolsButtonFrame.origin.y = 15;
    }
    
    [UIView animateWithDuration:0.15 animations:^{
        self.toolsContainerView.frame = toolsFrame;
        self.openToolsButton.frame = openToolsButtonFrame;
    }];
}
- (IBAction)closeCameraTapped:(id)sender {
    [self.delegate recorderDidCancel:self];
    
    self.navigationController.navigationBarHidden = NO;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) stopRecordingVideo
{
    [_recorder pause:^{
        [self saveSession:_recorder.session];
    }];
}

- (void)saveSession:(SCRecordSession *)recordSession
{
    [[SCRecordSessionManager sharedInstance] saveRecordSession:recordSession];
    _recordSession = recordSession;
    [self saveToCameraRoll];
}

- (void) saveToCameraRollWithWaterMark : (NSURL *)normal_outputUrl {
    SCAssetExportSession *exportSession = [[SCAssetExportSession alloc] initWithAsset:_recordSession.assetRepresentingSegments];
    
    exportSession.videoConfiguration.preset = SCPresetHighestQuality;
    exportSession.audioConfiguration.preset = SCPresetHighestQuality;
    exportSession.videoConfiguration.maxFrameRate = 30;
    
    if (self.movieName.length) {
        NSURL *path = [_recordSession.outputUrl URLByDeletingLastPathComponent];
        NSString *strPathWithoutName = [path absoluteString];
        NSString *newFilePathSring = [NSString stringWithFormat:@"%@%@_watermark.mov",strPathWithoutName,self.movieName];
        exportSession.outputUrl = [NSURL URLWithString:newFilePathSring];
    } else {
        exportSession.outputUrl = _recordSession.outputUrl;
    }
    
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.delegate = self;
    exportSession.contextType = SCContextTypeAuto;
    
    SCWatermarkOverlayView *overlay = [SCWatermarkOverlayView new];
    overlay.topTitle = @"Shades";
    overlay.bottomTitle = self.bottomTitle;
    overlay.date = _recordSession.date;
    exportSession.videoConfiguration.overlay = overlay;
    NSLog(@"Starting exporting");
    
    CFTimeInterval time = CACurrentMediaTime();
    __weak typeof(self) wSelf = self;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        __strong typeof(self) strongSelf = wSelf;
        
        if (!exportSession.cancelled) {
            NSLog(@"Completed compression in %fs", CACurrentMediaTime() - time);
        }
        
        NSError *error = exportSession.error;
        if (exportSession.cancelled) {
            NSLog(@"Export was cancelled");
        } else if (error == nil) {
            [self.delegate recorder:self didFinishPickingMediaWithUrl:normal_outputUrl watermarkUrl:exportSession.outputUrl ];
        } else {
            if (!exportSession.cancelled) {
                [[[UIAlertView alloc] initWithTitle:@"Failed to save" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }
    }];
}

- (void)saveToCameraRoll
{
    SCAssetExportSession *exportSession = [[SCAssetExportSession alloc] initWithAsset:_recordSession.assetRepresentingSegments];
    
    exportSession.videoConfiguration.preset = SCPresetHighestQuality;
    exportSession.audioConfiguration.preset = SCPresetHighestQuality;
    exportSession.videoConfiguration.maxFrameRate = 30;
    
    if (self.movieName.length) {
        NSURL *path = [_recordSession.outputUrl URLByDeletingLastPathComponent];
        NSString *strPathWithoutName = [path absoluteString];
        NSString *newFilePathSring = [NSString stringWithFormat:@"%@%@.mov",strPathWithoutName,self.movieName];
        exportSession.outputUrl = [NSURL URLWithString:newFilePathSring];
    } else {
        exportSession.outputUrl = _recordSession.outputUrl;
    }
    
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.delegate = self;
    exportSession.contextType = SCContextTypeAuto;

    CFTimeInterval time = CACurrentMediaTime();
    __weak typeof(self) wSelf = self;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        __strong typeof(self) strongSelf = wSelf;
        
        if (!exportSession.cancelled) {
            NSLog(@"Completed compression in %fs", CACurrentMediaTime() - time);
        }
        
        NSError *error = exportSession.error;
        if (exportSession.cancelled) {
            NSLog(@"Export was cancelled");
        } else if (error == nil) {
            [self saveToCameraRollWithWaterMark:exportSession.outputUrl];
        } else {
            if (!exportSession.cancelled) {
                [[[UIAlertView alloc] initWithTitle:@"Failed to save" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }
    }];
}

+ (void)saveVideo:(NSURL*)fromVideo withToUrl:(NSURL*)saveUrl
{
    NSError *err = nil;
    [[NSFileManager defaultManager] removeItemAtPath:saveUrl.absoluteString error:&err];

    NSData *data = [NSData dataWithContentsOfURL:fromVideo];
    if ( data != nil )
    {
        [data writeToURL:saveUrl atomically:YES];
    }
}

@end

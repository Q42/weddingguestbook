//
//  JTSelfieController.m
//  jtwedding
//
//  Created by Benjamin de Jager on 7/15/14.
//  Copyright (c) 2014 Q42. All rights reserved.
//

#import "JTSelfieController.h"


@interface JTSelfieController () <UIToolbarDelegate>

@end

@implementation JTSelfieController {
  GPUImageVideoCamera *_videoCamera;
  GPUImageFilter *_customFilter;
}

+ (instancetype)controllerWithDelegate:(id<JTTypeControllerDelegate>)delegate; {
  JTSelfieController *controller = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"JTSelfieController"];
  controller.delegate = delegate;
  return controller;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionFront];
  _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
  
//  _customFilter = [[GPUImageFilter alloc] init];
  _customFilter = [GPUImageFilter new];
//  GPUImageView *filteredVideoView = [[GPUImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, viewWidth, viewHeight)];
  _filteredVideoView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
  
  // Add the view somewhere so it's visible
  
  [_videoCamera addTarget:_customFilter];
  [_videoCamera addTarget:_filteredVideoView];
  
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (self.image == nil) {
    [_videoCamera startCameraCapture];
  }

}

- (void)reset {
  self.image = nil;
  [_videoCamera pauseCameraCapture];
}

- (IBAction)takeImage:(UIBarButtonItem *)sender {
  if ([sender.title isEqualToString:@"neem foto / сфотографировать"]) {

//    [_customFilter useNextFrameForImageCapture];
     self.image =     [_customFilter imageFromCurrentlyProcessedOutput];
    sender.title = @"opnieuw / снова";
    

    
//    UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
    [_videoCamera pauseCameraCapture];
    
    
        NSLog(@"image %@", self.image);
//    [self performSelector:@selector(capture) withObject:nil afterDelay:0.1];
  } else {
      sender.title = @"neem foto / сфотографировать";
    [_videoCamera resumeCameraCapture];
  }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
  [self.delegate typeControllerDidPressCancel];
}
- (IBAction)done:(id)sender {
  if (self.image == nil) {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops"
                                                        message:@"Take a picture first!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
    return;
  }
  
  [self.delegate typeControllerDidPressDone];
}


- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
  return UIBarPositionTopAttached;
}

@end

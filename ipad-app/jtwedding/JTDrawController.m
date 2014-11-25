//
//  JTViewController.m
//  jtwedding
//
//  Created by Benjamin de Jager on 7/8/14.
//  Copyright (c) 2014 Q42. All rights reserved.
//

#import "JTDrawController.h"
#import "DICanvasView.h"
//#import <JotTouchSDK/JotTouchSDK.h>


@interface JTDrawController () <UIPopoverControllerDelegate, UIBarPositioningDelegate>

@property (weak, nonatomic) IBOutlet DICanvasView *canvasView;

@end

@implementation JTDrawController {
  UIPopoverController *_popoverController;
  UIDatePicker *_datePicker;
}

+ (instancetype)controllerWithDelegate:(id<JTTypeControllerDelegate>)delegate; {
  JTDrawController *controller = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"JTDrawController"];
  controller.delegate = delegate;
  return controller;
}

- (IBAction)undo:(id)sender {
  [_canvasView undoLastDrawAction];
}

- (void)result:(UIDatePicker *)datePicker {
  
}

- (void)doneDatePickin {
  NSLog(@"picked a date");
  [_popoverController dismissPopoverAnimated:YES];
}


- (IBAction)saveResult:(id)sender {

  UIGraphicsBeginImageContext(_canvasView.bounds.size);
  [_canvasView.layer renderInContext:UIGraphicsGetCurrentContext()];
  
  UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
//  UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);  

  self.image = img;
}

- (IBAction)cancel:(id)sender {
  [self.delegate typeControllerDidPressCancel];
}

- (IBAction)done:(id)sender {
  [self saveResult:nil];
  [self.delegate typeControllerDidPressDone];
}

- (void)reset {
  [_canvasView resetAndDisplay];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  

//  [[JotStylusManager sharedInstance] enable];
//  [[JotStylusManager sharedInstance] registerView:_canvasView];
//  [[JotStylusManager sharedInstance] setPalmRejectorDelegate:_canvasView];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar{
  return UIBarPositionTopAttached;
}


@end

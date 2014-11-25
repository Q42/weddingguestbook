//
//  JTSelectTypeController.m
//  jtwedding
//
//  Created by Benjamin de Jager on 7/14/14.
//  Copyright (c) 2014 Q42. All rights reserved.
//

#import "JTSelectTypeController.h"
#import "JTDrawController.h"
#import "JTCalendarController.h"
#import "JTSelfieController.h"
#import "JTTypeController.h"
#import "JTTypeTypeController.h"
#import <FontAwesomeKit/FontAwesomeKit.h>

#import <AFNetworking/AFNetworking.h>

@interface JTSelectTypeController () <JTTypeControllerDelegate, UIPageViewControllerDataSource, JTCalendarControllerDelegate>

@end

@implementation JTSelectTypeController {
  UIPageViewController *_pageViewController;
  
  JTCalendarController *_calendarController;
//  JTDrawController *_drawController;
//  JTSelfieController *_selfieController;
  
  JTTypeController *_typeController;
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
  
  for (FUIButton *button in @[_selfieButton, _drawingButton, _textButton]) {
    button.buttonColor = [UIColor turquoiseColor];
    button.shadowColor = [UIColor greenSeaColor];
    button.shadowHeight = 6.0f;
    button.cornerRadius = 12.0f;
    button.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [button setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    button.titleLabel.text = @"";
    button.backgroundColor =[ UIColor clearColor];
  }
  
//      _drawingButton.titleLabel.attributedText =     [[FAKFontAwesome pencilSquareIconWithSize:50] attributedString];
  FAKIcon *icon = [FAKFontAwesome pencilIconWithSize:120];
  [icon addAttribute:NSForegroundColorAttributeName value:[UIColor cloudsColor]];
//  icon.drawingPositionAdjustment = UIOffsetMake(15, 2);
  [_drawingButton setImage:[icon imageWithSize:CGSizeMake(200, 150)] forState:UIControlStateNormal];
  
  FAKIcon *text = [FAKFontAwesome alignCenterIconWithSize:120];
  [text addAttribute:NSForegroundColorAttributeName value:[UIColor cloudsColor]];
  [_textButton setImage:[text imageWithSize:CGSizeMake(150, 150)] forState:UIControlStateNormal];
  
  FAKIcon *cam = [FAKFontAwesome cameraRetroIconWithSize:120];
  [cam addAttribute:NSForegroundColorAttributeName value:[UIColor cloudsColor]];
  [_selfieButton setImage:[cam imageWithSize:CGSizeMake(150, 150)] forState:UIControlStateNormal];
  
//  _drawController = [JTDrawController controllerWithDelegate:self];
  _calendarController = [JTCalendarController calendarControllerWithDelegate:self];
//  _selfieController = [JTSelfieController controllerWithDelegate:self];
  
  _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                        navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                      options:nil];
  _pageViewController.dataSource = self;
  for (UIScrollView *view in _pageViewController.view.subviews) {
    if ([view isKindOfClass:[UIScrollView class]]) {
      view.scrollEnabled = NO;
    }
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)launchSelfieController:(id)sender {

  _typeController = [JTSelfieController controllerWithDelegate:self];
  [_pageViewController setViewControllers:@[_typeController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
  [self presentViewController:_pageViewController animated:YES completion:nil];
  
}

- (IBAction)launchDrawController:(id)sender {

  _typeController = [JTDrawController controllerWithDelegate:self];
  [_pageViewController setViewControllers:@[_typeController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
  [self presentViewController:_pageViewController animated:YES completion:nil];
}

- (IBAction)launchTypeTextC1ontroller:(id)sender {

  _typeController = [JTTypeTypeController controllerWithDelegate:self];
  [_pageViewController setViewControllers:@[_typeController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
  [self presentViewController:_pageViewController animated:YES completion:nil];
  
}

#pragma mark DrawControllerDelegation

- (void)typeControllerDidPressCancel {
  [self dismissViewControllerAnimated:YES completion:nil];
  _typeController = nil;
  [_calendarController reset];
}

- (void)typeControllerDidPressDone {
  [_pageViewController setViewControllers:@[_calendarController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

#pragma mark calendar stuff

- (void)calenderControllerGoBack {
  [_pageViewController setViewControllers:@[_typeController] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}

- (void)calendarControllerDidPickDate:(NSDate *)date {
  NSLog(@"date! %@", date);
  
  NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%.f", [date timeIntervalSince1970]]];
  NSError *error = nil;
  [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
  
  NSString  *pngPath = [NSString stringWithFormat:@"%@/%@.png", path, [[NSUUID UUID] UUIDString]];
  NSData *imageData = UIImagePNGRepresentation(_typeController.image);
  [imageData writeToFile:pngPath atomically:YES];
  
  NSLog(@"%f", _typeController.image.size.width);
  
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  [manager GET:@"http://jaapennadia.appspot.com/api/uploadurl" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSString *uploadUrl = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    
    [manager POST:uploadUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
      [formData appendPartWithFileData:imageData name:@"file" fileName:[NSString stringWithFormat:@"%.f.png", [date timeIntervalSince1970]] mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
      NSLog(@"Success: %@", responseObject);
      
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      NSLog(@"Error: %@", error);
    }];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"fail %@", error);
  }];
  
  [self dismissViewControllerAnimated:YES completion:nil];
  
  
  [_calendarController reset];
  _typeController = nil;
}

#pragma mark PAgeviewcontrolelr shiz

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
  if ([viewController isKindOfClass:[JTCalendarController class]])
    return nil;
  return _calendarController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
  if ([viewController isKindOfClass:[JTCalendarController class]]) {
    return _typeController;
  }
  return nil;
}

@end

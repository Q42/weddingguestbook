//
//  JTCalendarController.m
//  jtwedding
//
//  Created by Benjamin de Jager on 7/15/14.
//  Copyright (c) 2014 Q42. All rights reserved.
//

#import "JTCalendarController.h"
#import "JTConfirmController.h"
#import <FlatUIKit/FlatUIKit.h>

@interface JTCalendarController () <PDTSimpleCalendarViewDelegate>

@end

@implementation JTCalendarController {
  PDTSimpleCalendarViewController *_simpleCalenderController;
  NSMutableDictionary *_takenDates;
  NSDate *_currentDate;
}

+ (JTCalendarController*)calendarControllerWithDelegate:(id)delegate {
  JTCalendarController *controller = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"JTCalendarController"];
  controller.delegate = delegate;
  return controller;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
      // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self reloadTakenDatesState];

  [[PDTSimpleCalendarViewCell appearance] setCircleSelectedColor:[UIColor colorFromHexCode:@"3E8CF0"]];
  
  _simpleCalenderController = self.childViewControllers.firstObject;
  _simpleCalenderController.delegate = self;
  
  _simpleCalenderController.firstDate = [NSDate dateWithTimeIntervalSince1970:1407024000];
  _simpleCalenderController.lastDate = [NSDate dateWithTimeIntervalSince1970:1437177600];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)reloadTakenDatesState {
  _takenDates = [NSMutableDictionary dictionary];
  
  NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
  NSArray *directories = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];;
  for (NSString *directory in directories) {
    _takenDates[directory] = @([[NSFileManager defaultManager] contentsOfDirectoryAtPath:[path stringByAppendingPathComponent:directory] error:nil].count);
  }
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar{
  return UIBarPositionTopAttached;
}
- (IBAction)back:(id)sender {
  [self.delegate calenderControllerGoBack];
}

- (IBAction)done:(id)sender {

  if (_currentDate == nil) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"selecteer een dag / Выберите день" delegate:nil cancelButtonTitle:@"Oke / в порядке" otherButtonTitles:nil];
    [alert show];
    return;
  }
  
  [self.delegate calendarControllerDidPickDate:_currentDate];
}

- (void)reset {
  [_simpleCalenderController setSelectedDate:nil];
  [self reloadTakenDatesState];
  
  _currentDate = nil;
  [_simpleCalenderController.collectionView reloadData];
  
}

#pragma mark Calendar View Delegate

- (UIColor *)simpleCalendarViewController:(PDTSimpleCalendarViewController *)controller circleColorForDate:(NSDate *)date {

  NSString *d = [NSString stringWithFormat:@"%.f", [date timeIntervalSince1970]];
  NSNumber *result = _takenDates[d];
  switch ([result integerValue]) {
    case 0:
      return [UIColor colorFromHexCode:@"6CD440"];
      break;
    case 1:
      return [UIColor colorFromHexCode:@"FF530D"];
    case 2:
      default:
      return [UIColor colorFromHexCode:@"FF0000"];
  }
}

- (void)simpleCalendarViewController:(PDTSimpleCalendarViewController *)controller didSelectDate:(NSDate *)date {
  _currentDate = date;
}

- (BOOL)simpleCalendarViewController:(PDTSimpleCalendarViewController *)controller shouldUseCustomColorsForDate:(NSDate *)date {
  return YES;
}

- (UIColor *)simpleCalendarViewController:(PDTSimpleCalendarViewController *)controller textColorForDate:(NSDate *)date {
  return [UIColor whiteColor];
}

@end
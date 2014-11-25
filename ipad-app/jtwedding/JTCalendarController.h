//
//  JTCalendarController.h
//  jtwedding
//
//  Created by Benjamin de Jager on 7/15/14.
//  Copyright (c) 2014 Q42. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PDTSimpleCalendar/PDTSimpleCalendar.h>

@protocol JTCalendarControllerDelegate <NSObject>

- (void)calendarControllerDidPickDate:(NSDate *)date;
- (void)calenderControllerGoBack;

@end

@interface JTCalendarController : UIViewController

@property (nonatomic, weak) id<JTCalendarControllerDelegate> delegate;

+ (JTCalendarController*)calendarControllerWithDelegate:(id)delegate;
- (void)reset;

@end

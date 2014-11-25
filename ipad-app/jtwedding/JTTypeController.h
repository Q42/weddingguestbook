//
//  JTTypeController.h
//  jtwedding
//
//  Created by Benjamin de Jager on 7/15/14.
//  Copyright (c) 2014 Q42. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JTTypeControllerDelegate <NSObject>

- (void)typeControllerDidPressCancel;
- (void)typeControllerDidPressDone;

@end

@interface JTTypeController : UIViewController

@property (nonatomic, weak) id<JTTypeControllerDelegate> delegate;
@property (nonatomic) UIImage *image;

+ (instancetype)controllerWithDelegate:(id<JTTypeControllerDelegate>)delegate;
- (void)reset;


@end

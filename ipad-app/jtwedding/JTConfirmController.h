//
//  JTConfirmController.h
//  jtwedding
//
//  Created by Benjamin de Jager on 7/15/14.
//  Copyright (c) 2014 Q42. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JTConfirmController : UIViewController

@property (nonatomic, weak) id delegate;

+ (JTConfirmController *)confirmControllerWithDelegate:(id)delegate;

@end

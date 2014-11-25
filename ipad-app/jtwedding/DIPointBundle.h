//
//  DIPointBundle.h
//  drawit
//
//  Created by Benjamin de Jager on 3/29/12.
//  Copyright (c) 2012 Chairborne Games. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DIPointBundle : NSObject

@property (nonatomic) CGPoint lastPoint;
@property (nonatomic) CGPoint midPoint1;
@property (nonatomic) CGPoint midPoint2;

+ (DIPointBundle*)pointBundleWithLastPoint:(CGPoint)lastPoint midPoint1:(CGPoint)midPoint1 andMidPoint2:(CGPoint)midPoint2;

@end

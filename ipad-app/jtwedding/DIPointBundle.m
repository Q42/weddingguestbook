//
//  DIPointBundle.m
//  drawit
//
//  Created by Benjamin de Jager on 3/29/12.
//  Copyright (c) 2012 Chairborne Games. All rights reserved.
//

#import "DIPointBundle.h"

@interface DIPointBundle ()
@end

@implementation DIPointBundle

@synthesize lastPoint = _lastPoint, midPoint1 = _midPoint1, midPoint2 = _midPoint2;

+ (DIPointBundle*)pointBundleWithLastPoint:(CGPoint)lastPoint midPoint1:(CGPoint)midPoint1 andMidPoint2:(CGPoint)midPoint2 {
  return [[DIPointBundle alloc] initWithLastPoint:lastPoint midPoint1:midPoint1 andMidPoint2:midPoint2];
}

- (id)initWithLastPoint:(CGPoint)lastPoint midPoint1:(CGPoint)midPoint1 andMidPoint2:(CGPoint)midPoint2 {
  if (self = [super init]) {
    _lastPoint = lastPoint;
    _midPoint1 = midPoint1;
    _midPoint2 = midPoint2;
  }              
  return self;
}

@end

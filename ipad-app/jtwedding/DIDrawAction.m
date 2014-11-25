//
//  DIDrawAction.m
//  drawit
//
//  Created by Benjamin de Jager on 3/29/12.
//  Copyright (c) 2012 Chairborne Games. All rights reserved.
//

#import "DIDrawAction.h"

@implementation DIDrawAction

@synthesize color = _color, timeStamp = _timeStamp, points = _points, lineWidth = _lineWidth;

+ (DIDrawAction *)action {
  return [[DIDrawAction alloc] init];
}

- (id)init {
  if (self = [super init]) {
    _points = [NSMutableArray array];
  }
  return self;
}

@end

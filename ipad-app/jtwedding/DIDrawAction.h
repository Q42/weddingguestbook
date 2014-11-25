//
//  DIDrawAction.h
//  drawit
//
//  Created by Benjamin de Jager on 3/29/12.
//  Copyright (c) 2012 Chairborne Games. All rights reserved.
//

#import "DIAction.h"

@interface DIDrawAction : DIAction

@property (nonatomic) UIColor *color;
@property (nonatomic) NSDate *timeStamp;
@property (nonatomic) NSMutableArray *points;
@property (nonatomic) NSNumber *lineWidth;

+ (DIDrawAction*)action;

@end

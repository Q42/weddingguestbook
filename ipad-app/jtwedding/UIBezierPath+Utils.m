//
//  UIBezierPath+Utils.m
//  drawit
//
//  Created by Benjamin de Jager on 5/8/12.
//  Copyright (c) 2012 Chairborne Games. All rights reserved.
//

#import "UIBezierPath+Utils.h"

@implementation UIBezierPath (Utils)

- (UIBezierPath *)tapTargetForPath:(UIBezierPath *)path {
  if (path == nil) {
    return nil;
  }
  
  CGPathRef tapTargetPath = CGPathCreateCopyByStrokingPath(path.CGPath, NULL, fmaxf(35.0f, path.lineWidth), path.lineCapStyle, path.lineJoinStyle, path.miterLimit);
  
  if (tapTargetPath == NULL) {
    return nil;
  }
  
  UIBezierPath *tapTarget = [UIBezierPath bezierPathWithCGPath:tapTargetPath];
  CGPathRelease(tapTargetPath);
  return tapTarget;
}


@end

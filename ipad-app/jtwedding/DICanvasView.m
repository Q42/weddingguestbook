//
//  DICanvasView.m
//  drawit
//
//  Created by Benjamin de Jager on 3/26/12.
//  Copyright (c) 2012 Chairborne Games. All rights reserved.
//

#import "DICanvasView.h"

#import "DIDrawAction.h"
#import "DIPointBundle.h"
#import "DIBezierPath.h"

#import "UIBezierPath+Utils.h"

#import <QuartzCore/QuartzCore.h>

#define randomFloat (double)arc4random()/0x100000000

@implementation DICanvasView {
  CGPoint _lastPoint;
  CGPoint _secondLastPoint;
  CGPoint _currentPoint;
  
  CGPoint _midPoint1;
  CGPoint _midPoint2;
  
  UIColor *_color;
  NSInteger _lineWidth;
  
  BOOL _startedDrawing; // bool to prevent the setneedsdisplay from drawing a dot at 0,0
  BOOL _shouldReset;
  BOOL _undoing;
  BOOL _erasing;
  
  UIImage *_canvasImage;
  
  NSMutableArray *_actionArray;
  DIDrawAction *_currentDrawAction;
  NSTimer *_drawTimer;
  
  NSMutableArray *_bezierPaths;
}

#pragma mark Initialisation

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self initialize];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    [self initialize];
  }
  return self;
}

- (void)initialize {
  self.userInteractionEnabled = YES;
  self.backgroundColor = [UIColor clearColor];
  
  _bezierPaths = [NSMutableArray array];
  _shouldReset = NO;
  _lineWidth = 10;
  _actionArray = [NSMutableArray array];
  [self changeColor];
}

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];
  
  if(_shouldReset) {
    _shouldReset = NO;
    
    [[UIColor clearColor] set];
    CGContextFillRect(UIGraphicsGetCurrentContext(), self.bounds);
  }
  
  if(!_startedDrawing)
    return;
  
  CGContextRef context = UIGraphicsGetCurrentContext(); 
  
  if (_undoing) {
    _undoing = NO;
    NSLog(@"stroking bezier");
    
    for (DIBezierPath *bezierPath in _bezierPaths) {
      [bezierPath.color setStroke];
      [bezierPath stroke];
    }
  } else {
    [self.layer renderInContext:context];
    
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, _lineWidth);
    CGContextSetStrokeColorWithColor(context, _color.CGColor);
    
    CGContextMoveToPoint(context, _midPoint1.x, _midPoint1.y);
    CGContextAddQuadCurveToPoint(context, _lastPoint.x, _lastPoint.y, _midPoint2.x, _midPoint2.y); 
    CGContextStrokePath(context); 
  }

}

#pragma mark Touch Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

  _startedDrawing = YES;
  
  UITouch *touch = [touches anyObject];
  _lastPoint = [touch previousLocationInView:self];
  _secondLastPoint = [touch previousLocationInView:self];
  _currentPoint = [touch locationInView:self];
  
  _currentDrawAction = [DIDrawAction action];  
  _currentDrawAction.lineWidth = [NSNumber numberWithInt:_lineWidth];
  _currentDrawAction.color = _color;
  
  [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {  
  
  UITouch *touch = [touches anyObject];
  
  _secondLastPoint = _lastPoint;
  _lastPoint = [touch previousLocationInView:self];
  _currentPoint = [touch locationInView:self];
  
  if (_erasing) {
//    NSLog(@"checking for erase hits");
    for (UIBezierPath *bezierPath in _bezierPaths) {
      if ([[bezierPath tapTargetForPath:bezierPath] containsPoint:_currentPoint]) {
        NSLog(@"contained in %@", bezierPath);
      }
    }
    return;
  }
  
  _midPoint1 = [self midPointBetweenPointA:_lastPoint andPointB:_secondLastPoint];
  _midPoint2 = [self midPointBetweenPointA:_currentPoint andPointB:_lastPoint];
  
  [_currentDrawAction.points addObject:[DIPointBundle pointBundleWithLastPoint:_lastPoint midPoint1:_midPoint1 andMidPoint2:_midPoint2]];  
  
  [self setNeedsDisplayForCalculatedRectWithLastPoint:_lastPoint midPoint1:_midPoint1 andMidPoint2:_midPoint2];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [_actionArray addObject:_currentDrawAction];
  _currentDrawAction = nil;
}

#pragma mark Private Methods

- (void)setNeedsDisplayForCalculatedRectWithLastPoint:(CGPoint)lastPoint midPoint1:(CGPoint)midPoint1 andMidPoint2:(CGPoint)midPoint2 {
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathMoveToPoint(path, NULL, midPoint1.x, midPoint1.y);
  CGPathAddQuadCurveToPoint(path, NULL, _lastPoint.x, _lastPoint.y, midPoint2.x, midPoint2.y);
  CGRect bounds = CGPathGetBoundingBox(path);
  CGPathRelease(path);
  
  CGRect drawBox = bounds;
  drawBox.origin.x -= _lineWidth * 2;
  drawBox.origin.y -= _lineWidth * 2;
  drawBox.size.width += _lineWidth * 4;
  drawBox.size.height += _lineWidth * 4;
  
  UIGraphicsBeginImageContext(drawBox.size);
  [self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIGraphicsEndImageContext();
  
  [self setNeedsDisplayInRect:drawBox];
}

- (void)undoLastDrawAction {
  [self undoDrawAction:[_actionArray lastObject]];
}

- (void)undoDrawAction:(DIDrawAction*)drawAction {
  [self reset];  
  
  [_actionArray removeObject:drawAction]; // remove draw action
  _startedDrawing = YES;  
  _undoing = YES;
  [self drawActionsWithEnumerator:[_actionArray objectEnumerator] animated:NO];
}

#pragma mark Public Methods

- (void)toggleEraser {
  _erasing = !_erasing;
}

- (void)resetAndDisplay {
  [self reset];
  [self setNeedsDisplay];
}

- (void)reset {
  [_bezierPaths removeAllObjects];
  
  _shouldReset = YES;
  _startedDrawing = NO;
}

- (void)play {
  [self resetAndDisplay];
  _startedDrawing = YES;
  [self drawActionsWithEnumerator:[_actionArray objectEnumerator] animated:YES];
}

- (void)clearSave {
  [self resetAndDisplay];
  [_actionArray removeAllObjects];
}

- (void)drawActionsWithEnumerator:(NSEnumerator*)actionEnumerator animated:(BOOL)animated {
  if ([_drawTimer isValid])
    [_drawTimer invalidate];
  
  DIDrawAction *drawAction = [actionEnumerator nextObject];
  if (!drawAction) {
    if (_undoing) {
      [self setNeedsDisplay];
    }
    NSLog(@"done");
    return;
  }
  _lineWidth = [drawAction.lineWidth intValue];
  _color = drawAction.color;
  
  NSLog(@"processing drawaction");  
  
  NSEnumerator *pointEnumerator = [drawAction.points objectEnumerator];
  __weak DICanvasView *canvasView = self;
  
  if (animated) {
//    _drawTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 block:^(NSTimeInterval time) {
//      
//      DIPointBundle *pointBundle = [pointEnumerator nextObject];
//      if (!pointBundle) {
//        [canvasView drawActionsWithEnumerator:actionEnumerator animated:animated];
//        return;
//      }    
//      
//      _lastPoint = pointBundle.lastPoint;
//      _midPoint1 = pointBundle.midPoint1;
//      _midPoint2 = pointBundle.midPoint2;
//      
//      [self setNeedsDisplayForCalculatedRectWithLastPoint:_lastPoint midPoint1:_midPoint1 andMidPoint2:_midPoint2];          
//      
//    } repeats:YES];      
  } else {
    
//    [self recursivePointDrawingWithPointEnumerator:pointEnumerator andActionEnumerator:actionEnumerator];
    
    NSLog(@"building bezier");
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    for (DIPointBundle *pointBundle in drawAction.points) {
      CGPathMoveToPoint(pathRef, NULL, pointBundle.midPoint1.x, pointBundle.midPoint1.y);
      CGPathAddQuadCurveToPoint(pathRef, NULL, pointBundle.lastPoint.x, pointBundle.lastPoint.y, pointBundle.midPoint2.x, pointBundle.midPoint2.y);
    }

    DIBezierPath *bezierPath = [[DIBezierPath alloc] init];
    bezierPath.CGPath = pathRef;
    [bezierPath setLineWidth:_lineWidth];
    [bezierPath setLineCapStyle:kCGLineCapRound];
    bezierPath.color = drawAction.color;
    [_bezierPaths addObject:bezierPath];
    
    [self drawActionsWithEnumerator:actionEnumerator animated:animated];
  }
  
}



//- (void)recursivePointDrawingWithPointEnumerator:(NSEnumerator*)pointEnumerator andActionEnumerator:(NSEnumerator*)actionEnumerator {
//  DIPointBundle *pointBundle = [pointEnumerator nextObject];
//  if (!pointBundle) {
//    [self drawActionsWithEnumerator:actionEnumerator animated:NO];
//    return;
//  }    
//  
//  _lastPoint = pointBundle.lastPoint;
//  _midPoint1 = pointBundle.midPoint1;
//  _midPoint2 = pointBundle.midPoint2;
//  
//  [self setNeedsDisplayForCalculatedRectWithLastPoint:_lastPoint midPoint1:_midPoint1 andMidPoint2:_midPoint2];            
//  [self recursivePointDrawingWithPointEnumerator:pointEnumerator andActionEnumerator:actionEnumerator];  
//}

- (void)changeLineWidth {
  if (_lineWidth == 10) {
    _lineWidth = 20;
  } else if (_lineWidth == 20) {
    _lineWidth = 30;
  } else if (_lineWidth == 30) {
    _lineWidth = 10;
  }
}

- (void)changeColor {
  _color = [UIColor blackColor];//[UIColor colorWithRed:randomFloat green:randomFloat blue:randomFloat alpha:1.0];
}

- (void)changeClearColor {
  _color = [UIColor clearColor];
}

#pragma mark Helper Functions

- (CGPoint)midPointBetweenPointA:(CGPoint)pointA andPointB:(CGPoint)pointB {
  return CGPointMake((pointA.x + pointB.x) * 0.5, (pointA.y + pointB.y) * 0.5);
}

- (CGFloat)distanceBetweenPointA:(CGPoint)pointA andPointB:(CGPoint)pointB {
  CGFloat dx = pointB.x - pointA.x;
  CGFloat dy = pointB.y - pointA.y;
  return sqrt(dx*dx + dy*dy );  
}

#pragma mark - PalmRejectionDelegate

-(void)jotStylusTouchBegan:(NSSet*)jotTouches{
  // a Jot stylus has begun to draw on the screen
  NSLog(@"touch began");
}
-(void)jotStylusTouchMoved:(NSSet*)jotTouches{
  // a Jot stylus is moving on the screen
}
-(void)jotStylusTouchEnded:(NSSet*)jotTouches{
  // a Jot stylus has ended normally on the screen
}
-(void)jotStylusTouchCancelled:(NSSet*)jotTouches{
  // a stylus event has been cancelled on the screen
}
-(void)jotSuggestsToDisableGestures{
  // the Jot Touch SDK has determined that the user’s palm is likely
  // resting on the screen or the user is actively drawing with the
  // Jot stylus, and we recommend to disable any other gestures
  // that might be attached to that UIView, such as a pinch-to-zoom
  // gesture
}
-(void)jotSuggestsToEnableGestures{
  // The user’s palm has lifted and drawing has stopped, so it is
  // safe to re-enable any other gestures on the UIView
}

@end

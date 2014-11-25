//
//  DICanvasView.h
//  drawit
//
//  Created by Benjamin de Jager on 3/26/12.
//  Copyright (c) 2012 Chairborne Games. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICanvasView : UIView

- (void)reset;
- (void)resetAndDisplay;
- (void)play;
- (void)clearSave;

- (void)changeLineWidth;
- (void)changeColor;
- (void)undoLastDrawAction;
- (void)toggleEraser;
- (void)changeClearColor;

@end
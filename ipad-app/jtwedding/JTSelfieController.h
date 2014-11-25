//
//  JTSelfieController.h
//  jtwedding
//
//  Created by Benjamin de Jager on 7/15/14.
//  Copyright (c) 2014 Q42. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTTypeController.h"
#import <GPUImage/GPUImage.h>

@interface JTSelfieController : JTTypeController

@property (nonatomic) IBOutlet GPUImageView *filteredVideoView;

@end

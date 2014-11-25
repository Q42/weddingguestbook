//
//  JTTypeTypeController.m
//  jtwedding
//
//  Created by Benjamin de Jager on 7/15/14.
//  Copyright (c) 2014 Q42. All rights reserved.
//

#import "JTTypeTypeController.h"

@interface JTTypeTypeController () <UIToolbarDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation JTTypeTypeController

+ (instancetype)controllerWithDelegate:(id<JTTypeControllerDelegate>)delegate; {
  JTTypeTypeController *controller = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"JTTypeTypeController"];
  controller.delegate = delegate;
  return controller;
}

- (IBAction)cancel:(id)sender {
  [self.delegate typeControllerDidPressCancel];
}

- (IBAction)done:(id)sender {
  [[UITextView appearance] setTintColor:[UIColor whiteColor]];
  
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  
  [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
  NSDictionary *attributes = @{ NSFontAttributeName: _textView.font, NSParagraphStyleAttributeName : paragraphStyle };
  
  CGRect size = [_textView.text boundingRectWithSize:CGSizeMake(_textView.frame.size.width, _textView.frame.size.height)
                               options:NSStringDrawingUsesLineFragmentOrigin
                            attributes:attributes context:nil];
  size.size.width = _textView.frame.size.width;
  size.size.height =  size.size.height + _textView.font.pointSize;
  UIGraphicsBeginImageContext(size.size);
  [_textView.layer renderInContext:UIGraphicsGetCurrentContext()];
  
  UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
//  UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
  
  self.image = img;
  
  [self.delegate typeControllerDidPressDone];
}

- (void)reset {
  _textView.text = @"";
  
  [[UITextView appearance] setTintColor:[UIColor blueColor]];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [_textView becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[UITextView appearance] setTintColor:[UIColor blueColor]];

}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
  return UIBarPositionTopAttached;
}

@end

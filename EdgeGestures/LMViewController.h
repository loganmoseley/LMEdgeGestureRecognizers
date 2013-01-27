//
//  LMViewController.h
//  EdgeGestures
//
//  Created by Logan Moseley on 1/27/13.
//  Copyright (c) 2013 Logan Moseley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIView *mainView;
@property (nonatomic, strong) IBOutlet UIView *utilityView;

@property (nonatomic) CGFloat utilityAnimationDuration;

@end

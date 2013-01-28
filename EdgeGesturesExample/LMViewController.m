//
//  LMViewController.m
//  EdgeGestures
//
//  Created by Logan Moseley on 1/27/13.
//  Copyright (c) 2013 Logan Moseley. All rights reserved.
//

#import "LMViewController.h"
#import "LMEdgePanGestureRecognizer.h"

@interface LMViewController ()

@property (nonatomic, getter = isUtilityOpen) BOOL utilityOpen;
@property (nonatomic, weak) LMEdgePanGestureRecognizer *mainViewEdgePanRecognizer;
@property (nonatomic, weak) UITapGestureRecognizer *mainViewTapRecognizer;

@end

@implementation LMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.utilityAnimationDuration = 0.2;
    
    LMEdgePanGestureRecognizer *edgePan = [[LMEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMainViewBottomEdgePan:)];
    [edgePan setEdge:LMEdgePanGestureRecognizerEdgeBottom];
    [self.mainView addGestureRecognizer:edgePan];
    self.mainViewEdgePanRecognizer = edgePan;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMainViewTapped:)];
    [tap setEnabled:NO];
    [self.mainView addGestureRecognizer:tap];
    self.mainViewTapRecognizer = tap;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"did receive memory warning");
}

- (void)setUtilityOpen:(BOOL)utilityOpen
{
    [self willChangeValueForKey:@"tabBarOpen"];
    _utilityOpen = utilityOpen;
    if (utilityOpen) {
        [self openUtility];
    } else {
        [self closeUtility];
    }
    [self didChangeValueForKey:@"tabBarOpen"];
}

- (IBAction)openUtility
{
    CGFloat currentTranslation = self.mainView.transform.ty;
    CGFloat maxTranslation = CGRectGetHeight(self.utilityView.frame);
    CGFloat distanceToTarget = fabsf(currentTranslation + maxTranslation);
    CGFloat maxDuration = self.utilityAnimationDuration;
    CGFloat duration = MIN(fabsf(distanceToTarget/maxTranslation), 1.0) * maxDuration;
    [UIView animateWithDuration:duration
                          delay:0.
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.mainView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.utilityView.frame));
                     }
                     completion:^(BOOL finished) {
                         self.mainViewEdgePanRecognizer.touchMargin = CGRectGetHeight(self.mainViewEdgePanRecognizer.view.frame);
                         self.mainViewTapRecognizer.enabled = YES;
                     }];
}

- (IBAction)closeUtility
{
    [UIView animateWithDuration:self.utilityAnimationDuration
                          delay:0.
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.mainView.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                         self.mainViewEdgePanRecognizer.touchMargin = 20.;
                         self.mainViewTapRecognizer.enabled = NO;
                     }];
}

- (void)handleMainViewBottomEdgePan:(LMEdgePanGestureRecognizer *)recognizer
{
    CGFloat kRevealHeight = CGRectGetHeight(self.utilityView.frame);
    CGAffineTransform initialTransform;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        initialTransform = self.mainView.transform;
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint initialTranslation = CGPointMake(initialTransform.tx, initialTransform.ty);
        CGPoint translation = [recognizer translationInView:recognizer.view];
        CGPoint viewTranslation = CGPointMake(translation.x+initialTranslation.x, translation.y+initialTranslation.y);
        
        CGAffineTransform transform;
        
        // the pan is going up
        if (viewTranslation.y <= 0) {
            CGFloat d;
            CGFloat extra;
            
            d = MAX(viewTranslation.y, -kRevealHeight);
            extra = -kRevealHeight - viewTranslation.y;
            
            if (extra > 0)
            {
                CGFloat extraMax = CGRectGetHeight(recognizer.view.bounds) - kRevealHeight;
                CGFloat damped = extra/extraMax*kRevealHeight;
                d -= damped;
            }
            
            transform = CGAffineTransformMakeTranslation(0, d);
        }
        
        // the pan is going down
        else {
            CGFloat scale = translation.y / CGRectGetHeight(recognizer.view.bounds) * 0.1;
            transform = CGAffineTransformMakeScale(1., 1. + scale);
            transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(0, translation.y/20.));
        }
        
        self.mainView.transform = transform;
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        BOOL shouldOpen = NO;
        CGPoint velocity = [recognizer velocityInView:recognizer.view];
        CGPoint translation = [recognizer translationInView:recognizer.view];
        
        if (self.isUtilityOpen) {
            shouldOpen = -translation.y > CGRectGetHeight(self.utilityView.frame)*2./3.;
        } else {
            shouldOpen |= -velocity.y    > recognizer.touchMargin * 5.0;
            shouldOpen |= -translation.y > recognizer.touchMargin;
        }
        
        [self setUtilityOpen:shouldOpen];
    }
}

- (void)handleMainViewTapped:(UITapGestureRecognizer *)recognizer
{
    [self setUtilityOpen:NO];
}


@end

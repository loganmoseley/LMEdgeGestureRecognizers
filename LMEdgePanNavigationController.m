//
//  LMEdgePanNavigationController.m
//  NavEdgeGesture
//
//  Created by Logan Moseley on 3/4/13.
//  Copyright (c) 2013 Logan Moseley. All rights reserved.
//

#import "LMEdgePanNavigationController.h"
#import "LMEdgePanGestureRecognizer.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat kLeftPanTouchMargin = 20.;
static CGFloat kBackTransitionMinDuration = 0.1;
static CGFloat kBackTransitionOptDuration = 0.2;
static CGFloat kBackTransitionMaxDuration = 0.4;
static CGFloat kFastPanVelocity = 250.;

float fclampf(float x, float min, float max) {
	if (min > max)
		return fmaxf(max, fminf(x, min));
	else // expected
		return fmaxf(min, fminf(x, max));
}

@interface LMEdgePanNavigationController ()
@property (nonatomic, weak) LMEdgePanGestureRecognizer *leftEdgePanRecognizer;
@property (nonatomic, strong) UIImageView *backView;
@end

@implementation LMEdgePanNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];    
    [self.view setGestureRecognizers:nil];
    
    CGRect backFrame = self.view.frame;
    backFrame.origin.x -= CGRectGetWidth(backFrame);
    UIImageView *backView = [[UIImageView alloc] initWithFrame:backFrame];
    self.backView = backView;
    [self.backView setContentMode:UIViewContentModeScaleAspectFill];
    [self.backView setClipsToBounds:YES];
    [self.backView setImage:nil];
    [self.backView setBackgroundColor:[UIColor colorWithWhite:0.99 alpha:1.0]];

    LMEdgePanGestureRecognizer *leftEdgePan = [[LMEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMainViewLeftEdgePan:)];
    [leftEdgePan setEdge:LMEdgePanGestureRecognizerEdgeLeft];
    [leftEdgePan setTouchMargin:kLeftPanTouchMargin];
    [leftEdgePan setDelegate:self];
    [self.view addGestureRecognizer:leftEdgePan];
    self.leftEdgePanRecognizer = leftEdgePan;
}

#pragma mark -Left

- (void)handleMainViewLeftEdgePan:(LMEdgePanGestureRecognizer *)recognizer
{
    UIView *panningView = self.topViewController.view;
    static CGAffineTransform initialTransform;
    static BOOL canGoBack = NO;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        initialTransform = panningView.transform;
        canGoBack = self.viewControllers.count > 1;
        [self prepareBackView];
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGFloat damper = canGoBack ? 1. : 0.1;
        
        CGPoint initialTranslation = CGPointMake(initialTransform.tx, initialTransform.ty);
        CGPoint translation = [recognizer translationInView:recognizer.view];
        CGPoint targetTranslation = CGPointMake(translation.x+initialTranslation.x, translation.y+initialTranslation.y);
        CGFloat x = fclampf(targetTranslation.x, 0, CGRectGetWidth(recognizer.view.frame) - 5);
        CGAffineTransform transform = CGAffineTransformMakeTranslation(x*damper, 0);
        panningView.transform = transform;
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        CGPoint currentTranslation = CGPointMake(panningView.transform.tx, panningView.transform.ty);
        CGPoint currentVelocity = [recognizer velocityInView:recognizer.view];
        
        BOOL should = NO;
        if (fabsf(currentVelocity.x) > kFastPanVelocity)
        {
            should = (currentVelocity.x > 0);
        }
        else // not fast enough, test position
        {
            CGFloat viewCenterX = CGRectGetWidth([self.backView superview].frame)/2.;
            should = (currentTranslation.x >= viewCenterX);
        }
        
        // override for root vc
        
        should &= (self.viewControllers.count > 1);
        
        // transition
        
        if (should) // go back
        {
            CGFloat remaining = CGRectGetWidth([self.backView superview].frame) - currentTranslation.x;
            CGFloat duration = 0.0;
            if (currentVelocity.x > kFastPanVelocity)
            {
                duration = remaining / currentVelocity.x;
                duration = fclampf(duration, kBackTransitionMinDuration, kBackTransitionMaxDuration);
            }
            else
            {
                duration = kBackTransitionOptDuration;
            }
            
            [UIView animateWithDuration:duration
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 CGAffineTransform fullRightT = CGAffineTransformMakeTranslation(CGRectGetWidth([self.backView superview].frame), 0);
                                 panningView.transform = fullRightT;
                             }
                             completion:^(BOOL finished) {
                                 [self popViewControllerAnimated:NO];
                                 panningView.transform = CGAffineTransformIdentity;
                                 [self.backView removeFromSuperview];
                             }];
        }
        else // stay on current
        {
            CGFloat duration = 0.0;
            if (currentVelocity.x < -kFastPanVelocity)
            {
                duration = currentTranslation.x / currentVelocity.x;
                duration = fclampf(fabsf(duration), kBackTransitionMinDuration, kBackTransitionMaxDuration);
            }
            else
            {
                duration = kBackTransitionOptDuration;
            }
            
            [UIView animateWithDuration:duration
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 panningView.transform = CGAffineTransformIdentity;
                             }
                             completion:^(BOOL finished) {
                                 [self.backView removeFromSuperview];
                             }];
        }
    }
}

- (void)prepareBackView
{
    [self.backView removeFromSuperview];
    [self renderPriorViewControllerIntoBackView:self.topViewController];
    [self.backView setFrame:(CGRect){.origin=self.backView.frame.origin, .size=self.topViewController.view.frame.size}];
    [self.topViewController.view addSubview:self.backView];
}

- (void)renderPriorViewControllerIntoBackView:(UIViewController *)viewController
{
    __block NSInteger priorIdx = NSNotFound;
    [self.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (obj == viewController) {
            priorIdx = idx - 1;
            *stop = YES;
        }
    }];
    
    if (priorIdx == NSNotFound || priorIdx < 0 || priorIdx >= self.viewControllers.count)
    {
        self.backView.image = nil;
    }
    else
    {
        UIViewController *toRender = (UIViewController *)[self.viewControllers objectAtIndex:priorIdx];
        [self renderViewControllerIntoBackView:toRender];
    }
}

- (void)renderViewControllerIntoBackView:(UIViewController *)viewController
{
    CGSize size = viewController.view.frame.size;
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    [viewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.backView.image = image;
}

@end

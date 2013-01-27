//
//  LMPanGestureRecognizer.m
//  Photos
//
//  Created by Logan Moseley on 1/21/13.
//  Copyright (c) 2013 Logan Moseley. All rights reserved.
//

#import "LMEdgePanGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>


static CGFloat const kReceivingTouchMarginDefault = 20.;
static LMEdgePanGestureRecognizerEdge const kRecognizedEdgesDefault = LMEdgePanGestureRecognizerEdgeBottom;


@implementation LMEdgePanGestureRecognizer

- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if (self) {
        self.touchMargin = kReceivingTouchMarginDefault;
        self.edge = kRecognizedEdgesDefault;
    }
    return self;
}

- (BOOL)cancelsTouchesInView
{
    return YES;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
    return YES;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if ([self shouldCaptureTouch:touch]) {
        [super touchesBegan:touches withEvent:event];
    }
}

- (UIEdgeInsets)insetsForTouchDetection
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.top    = self.edge & LMEdgePanGestureRecognizerEdgeTop    ? self.touchMargin : 0.;
    insets.left   = self.edge & LMEdgePanGestureRecognizerEdgeLeft   ? self.touchMargin : 0.;
    insets.bottom = self.edge & LMEdgePanGestureRecognizerEdgeBottom ? self.touchMargin : 0.;
    insets.right  = self.edge & LMEdgePanGestureRecognizerEdgeRight  ? self.touchMargin : 0.;
    return insets;
}

- (BOOL)shouldCaptureTouch:(UITouch *)touch
{
    CGPoint location = [touch locationInView:self.view];
    CGRect viewBounds = self.view.frame;
    viewBounds.origin = CGPointZero;
    
    bool viewContainsPoint = CGRectContainsPoint(viewBounds, location);
    if (!viewContainsPoint) return NO;
    
    CGRect insetBounds = UIEdgeInsetsInsetRect(viewBounds, [self insetsForTouchDetection]);
    bool insetContainsPoint = CGRectContainsPoint(insetBounds, location);
    if (insetContainsPoint) return NO;
    
    return YES;
}

@end

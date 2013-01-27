//
//  LMPanGestureRecognizer.h
//  Photos
//
//  Created by Logan Moseley on 1/21/13.
//  Copyright (c) 2013 Logan Moseley. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, LMEdgePanGestureRecognizerEdge)
{
    LMEdgePanGestureRecognizerEdgeRight  = 1 << 0,
    LMEdgePanGestureRecognizerEdgeLeft   = 1 << 1,
    LMEdgePanGestureRecognizerEdgeTop    = 1 << 2,
    LMEdgePanGestureRecognizerEdgeBottom = 1 << 3,
};

@interface LMEdgePanGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic) CGFloat touchMargin; // default is 20
@property (nonatomic) LMEdgePanGestureRecognizerEdge edge; // default is LMEdgePanGestureRecognizerEdgeBottom. the desired direction of the pan. multiple directions may be specified if they will result in the same behavior (for example, UITableView swipe delete)

@end

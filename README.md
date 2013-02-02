# LMEdgeGestureRecognizer

**I think edge gestures should be used more often. This class makes it easier.**

Edge gestures are when a tap slides in from the edge of the view (probably from the edge of the screen). It can be seen in Chrome to switch tabs and in YouTube to open the sidebar.

## Demo

Build and run the `LMEdgeGesturesExample` project in Xcode to see `LMEdgeGestures` in action.

## Example Usage

``` objective-c
- (void)viewDidLoad
{
    [super viewDidLoad];
    LMEdgePanGestureRecognizer *leftEdgePan = [[LMEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMainViewLeftEdgePan:)];
    [leftEdgePan setEdge:LMEdgePanGestureRecognizerEdgeLeft];
    [leftEdgePan setTouchMargin:20.];
    [leftEdgePan setDelegate:self];
    [self.view addGestureRecognizer:leftEdgePan];
    self.leftEdgePanRecognizer = leftEdgePan;
}

- (void)handleMainViewLeftEdgePan:(LMEdgePanGestureRecognizer *)recognizer
{    
    static CGAffineTransform initialTransform;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        initialTransform = self.mainView.transform;
        [self renderBackView];
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint initialTranslation = CGPointMake(initialTransform.tx, initialTransform.ty);
        CGPoint translation = [recognizer translationInView:recognizer.view];
        CGPoint targetTranslation = CGPointMake(translation.x+initialTranslation.x, translation.y+initialTranslation.y);
        CGFloat x = MIN(MAX(0, targetTranslation.x), CGRectGetWidth(recognizer.view.frame)-5);
        CGAffineTransform transform = CGAffineTransformMakeTranslation(x, 0);
        self.mainView.transform = transform;
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
       [UIView animateWithDuration:0.2
                             delay:0.0
                           options:UIViewAnimationOptionBeginFromCurrentState
                        animations:^{
                            self.mainView.transform = CGAffineTransformIdentity;
                        }
                        completion:^(BOOL finished) {
                            self.leftEdgePanRecognizer.touchMargin = self.mainView.transform.tx + kLeftPanTouchMargin;
                        }];
        
    }
}
```

## Contact

Logan Moseley

- http://github.com/loganmoseley
- http://twitter.com/loganmoseley
- l@loganmoseley.com

## License

LMEdgeGestureRecognizer is available under the MIT license. See the LICENSE file for more info.

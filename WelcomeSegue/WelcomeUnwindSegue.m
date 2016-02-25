#import "WelcomeUnwindSegue.h"

@implementation WelcomeUnwindSegue

- (void)perform
{
    UIViewAnimationOptions animation  = NO;//UIViewAnimationOptionTransitionFlipFromRight | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent;
    
    UIViewController *source = (UIViewController *) self.sourceViewController;
    UIViewController *dest = (UIViewController *) self.destinationViewController;
    
    
    [UIView transitionWithView:source.navigationController.view duration:0.4
                       options: animation
                    animations:^{
                        [source.navigationController popToViewController:dest animated:NO];
                    }
                    completion:^(BOOL finished) {
                    }];

}

@end

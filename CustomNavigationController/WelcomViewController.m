#import "WelcomViewController.h"
#import "WelcomeUnwindSegue.h"

@interface WelcomViewController ()

@end

@implementation WelcomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier
{
    
    //how to set identifier for an unwind segue:
    
    //1. in storyboard -> documento outline -> select your unwind segue
    //2. then choose attribute inspector and insert the identifier name
    if ([@"TakeSelfieUnwindSegue" isEqualToString:identifier] || [@"CloseSelfieUnwindSegue" isEqualToString:identifier]) {
        return [[WelcomeUnwindSegue alloc] initWithIdentifier:identifier source:fromViewController destination:toViewController];
    } else if ([@"CameraVCUnwindSegue" isEqualToString:identifier]) {
        return [[WelcomeUnwindSegue alloc] initWithIdentifier:identifier source:fromViewController destination:toViewController];
    }else if([@"unwindChooseRole" isEqualToString:identifier]){
        return [[WelcomeUnwindSegue alloc] initWithIdentifier:identifier source:fromViewController destination:toViewController];
    }else {
        //if you want to use simple unwind segue on the same or on other ViewController this code is very important to mix custom and not custom segue
        return [super segueForUnwindingToViewController:toViewController fromViewController:fromViewController identifier:identifier];
    }
}

@end

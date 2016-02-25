#import "TakeSelfieViewController.h"
#import "ParametersOfModelViewController.h"
#import "ChooseTalentViewController.h"
#import "SignUpViewController.h"
#import "DetailInfoViewController.h"


@interface TakeSelfieViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnTakeSelfie;
@property (weak, nonatomic) IBOutlet UIButton *btnRetakeSelfie;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)takeSelfie:(id)sender;
- (IBAction)revokeSelfie:(id)sender;

@end

@implementation TakeSelfieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
}

- (void)setSelfie:(UIImage *)selfie {
    _selfie = selfie;
    self.imageView.image = selfie;
}

- (IBAction)takeSelfie:(id)sender {
    [self performSegueWithIdentifier:@"TakeSelfieUnwindSegue" sender:self];
}

- (IBAction)revokeSelfie:(id)sender {

}

@end

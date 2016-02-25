#import "PasswordViewController.h"
#import "Model.h"
#import "Helpers.h"
#import "RightMenuViewController.h"
#import "UIViewController+MMDrawerController.h"

@interface PasswordViewController ()

@property (nonatomic) BOOL isProcessing;

@end

@implementation PasswordViewController

-(void)viewDidLoad
{
    [super viewDidLoad];

	UITapGestureRecognizer *hideKeyboardGesture = [[UITapGestureRecognizer alloc]
												   initWithTarget:self action:@selector(hideKeyboard)];
	hideKeyboardGesture.cancelsTouchesInView = NO;
	[self.tableView addGestureRecognizer:hideKeyboardGesture];

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    imageView.image = [UIImage imageNamed:@"login_background"];
    
    self.fogotBtn.text = LNG("Send");
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidShow:)
												 name:UIKeyboardDidShowNotification
											   object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	[self.email resignFirstResponder];

	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardDidShowNotification
												  object:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return [SHARED_CONTROLLER deviceModel] == DeviceModel4 ? 205 : 205;
        case 1:
            return [SHARED_CONTROLLER deviceModel] == DeviceModel4 ? 20 : 60;
        case 2:
            return 65;
        case 3:
            return [SHARED_CONTROLLER deviceModel] == DeviceModel4 ? 52 : 100;
        case 4:
            return 60;
        default:
            return 65;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

	[self reset:nil];
    return YES;
}

- (IBAction)reset:(id)sender
{
    if (!self.isProcessing) {
        self.isProcessing = YES;
        [PFUser requestPasswordResetForEmailInBackground:self.email.text block:^(BOOL succeeded, NSError *error) {
            self.isProcessing = NO;
            if (!error) {
                [SHARED_CONTROLLER showMessage:LNG("E-mail with instructions to reset your password has been sent.") title:nil];
                [self.navigationController popViewControllerAnimated:YES];
                
            } else {
                [SHARED_CONTROLLER handleError:error];
            }
        }];
    }
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)hideKeyboard
{
	[self.view endEditing:NO];
}

-(void)keyboardDidShow:(NSNotification*)aNotification
{
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

@end

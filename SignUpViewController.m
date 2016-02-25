#import "SignUpViewController.h"
#import "LibraryAPI.h"

@interface SignUpViewController ()
{
    UserData *userData;
}

@property (weak, nonatomic) IBOutlet UITextField *login;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UILabel *continueLabel;
@property (assign) UITextField *activeField;

@end


@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.continueLabel.text = LNG("Continue");
    
    [self.login setPlaceholder:LNG("firstScreen.login")];
    [self.email setPlaceholder:LNG("firstScreen.email")];
    [self.password setPlaceholder:LNG("firstScreen.pass")];
    UITapGestureRecognizer *hideKeyboardGesture = [[UITapGestureRecognizer alloc]
                                                   initWithTarget:self action:@selector(hideKeyboard)];
    hideKeyboardGesture.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:hideKeyboardGesture];

}

-(void)hideKeyboard
{
    [self.view endEditing:NO];
}

- (IBAction)btnSignClick:(id)sender {
    if (!allTrim(self.login.text).length || !allTrim(self.email.text).length || !allTrim(self.password.text).length) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:LNG("Please fill all of the fields") delegate:nil cancelButtonTitle:LNG("Btn.OK") otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    USE_APPLICATION;
    [application showActivityView:LNG("Please wait")];
    
    userData = [[UserData alloc] init];
    userData.login = self.login.text;
    userData.password = self.password.text;
    userData.email = self.email.text.copy;
    userData.show_login = YES;
    
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
    if (deviceToken.length > 0) {
        SHARED_CONTROLLER.userData.device_token = deviceToken;
        userData.device_token = deviceToken;
    }
    userData.app_version = [[NSUserDefaults standardUserDefaults] objectForKey:@"BundleShortVersionString"];
    userData.revision = [[NSUserDefaults standardUserDefaults] objectForKey:@"BundleVersion"];
    userData.platform = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentPlatform"];
    userData.os = [[NSUserDefaults standardUserDefaults] objectForKey:@"TypePlatform"];
    userData.mobile_version = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentVersionIOS"];
    userData.device_id = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    
    [LIBRARY_API createUser:userData withHandler:^(UserData *user, NSError *error) {
        if (error) {
            [application hideActivityView];
            [SHARED_CONTROLLER handleError:error];
            return;
        }
        SHARED_CONTROLLER.userData = user;
        [[NSUserDefaults standardUserDefaults] setValue:self.login.text forKey:@"login"];
        [[NSUserDefaults standardUserDefaults] setValue:self.password.text forKey:@"password"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [application registrationMethod];
        [application hideActivityView];
        [self performSegueWithIdentifier:@"DetailSettingSegue" sender:self];
    }];
}
- (BOOL)validateEmail:(NSString *)emailStr {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.login])
        [self.email becomeFirstResponder];
    else if ([textField isEqual:self.email])
        [self.password becomeFirstResponder];
	else
        [textField resignFirstResponder];
    return YES;
}

#pragma mark Keyboard move up

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    _activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _activeField = nil;
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

#pragma mark -

- (UITableViewCell *) getCellFromView:(UIView *) view {
    
    for ( ; view && ![view isKindOfClass:[UITableViewCell class]]; view = view.superview ) {
    }
    
    return [view isKindOfClass:[UITableViewCell class]] ? (UITableViewCell*)view : nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return [SHARED_CONTROLLER deviceModel] == DeviceModel4 ? 110 : 200;
        case 1:
            return [SHARED_CONTROLLER deviceModel] == DeviceModel4 ? 220 : 200;
        case 2:
            return [SHARED_CONTROLLER deviceModel] == DeviceModel4 ? 68 : 87;
        default:
            return 40;
    }
}

@end

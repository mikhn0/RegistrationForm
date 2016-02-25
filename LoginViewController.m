#import "LoginViewController.h"
#import "RightMenuViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "FBHelper.h"
#import "Datas.h"
#import "LibraryAPI.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *login;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton* btnLogin;
@property (weak, nonatomic) IBOutlet UIButton* btnExplore;
@property (assign) UITextField *activeField;
@property (nonatomic) BOOL isProcessing;
@property (weak, nonatomic) IBOutlet UILabel *continueLabel;

- (IBAction)btnExploreClick:(id)sender;

@end

@implementation LoginViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.btnExplore setTitle:LNG("firstScreen.explore") forState:UIControlStateNormal];
    UITapGestureRecognizer *hideKeyboardGesture = [[UITapGestureRecognizer alloc]
                                                   initWithTarget:self action:@selector(hideKeyboard)];
    hideKeyboardGesture.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:hideKeyboardGesture];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    imageView.image = [UIImage imageNamed:@"login_background"];
    
    self.continueLabel.text = LNG("Continue");

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *login =[[NSUserDefaults standardUserDefaults] valueForKey:@"login"];
    NSString *password =[[NSUserDefaults standardUserDefaults] valueForKey:@"password"];
    if (login.length)
        self.login.text = login;
    if (password.length)
        self.password.text = password;
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidShow:)
												 name:UIKeyboardDidShowNotification
											   object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	// unregister for keyboard notifications while not visible.
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardDidShowNotification
												  object:nil];
}


#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
			return [SHARED_CONTROLLER deviceModel] == DeviceModel4 ? 180 : 220;
        case 1:
            return 55;
        case 2:
			return [SHARED_CONTROLLER deviceModel] == DeviceModel4 ? 60 : 80;
        case 3:
            return [SHARED_CONTROLLER deviceModel] == DeviceModel4 ? 30 : 70;
        case 4:
			return [SHARED_CONTROLLER deviceModel] == DeviceModel4 ? 95 : 72;
        default:
            return 40;
    }
}


#pragma mark - Login

- (IBAction)fb_login:(id)sender
{
    [[FBHelper FBHelperSingleton] fb_login:^(BOOL isSuccess) {
        SEND_NOTIF(kCheckUser, nil);
       if (isSuccess) {
           [DATA_SERVICE chatConnect:nil];
           [DATA_SERVICE saveUserLocation];
           USE_APPLICATION;
           if ( [application.window.rootViewController isKindOfClass:NSClassFromString(@"UINavigationController")] ) {
               SET_CURRENT_ROLE(USER_DATA.role);
               [[UINavigationBar appearance] setBackgroundImage:[SHARED_CONTROLLER.currentRoleParametrs[@"navbar_image"]
                                                                 resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)] forBarMetrics:UIBarMetricsDefault];
               [[UITabBar appearance] setBackgroundImage:[SHARED_CONTROLLER.currentRoleParametrs[@"tabbar_image"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)]];
               [application startupApplicationFromRegistrationScreen:NO byRole:localTempRole];
           } else {
               [self.navigationController popToRootViewControllerAnimated:NO];
           }
       }
    }];
}

- (IBAction)login:(id)sender {
    if (!self.isProcessing) {
        self.isProcessing = YES;
		USE_APPLICATION;
		[application showActivityView:LNG("Please wait")];
        UserData *userData = [UserData new];
        userData.login = [self.login.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        userData.password = [self.password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]) {
            userData.device_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
        }
        userData.app_version = [[NSUserDefaults standardUserDefaults] objectForKey:@"BundleShortVersionString"];
        userData.revision = [[NSUserDefaults standardUserDefaults] objectForKey:@"BundleVersion"];
        userData.platform = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentPlatform"];
        userData.os = [[NSUserDefaults standardUserDefaults] objectForKey:@"TypePlatform"];
        userData.mobile_version = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentVersionIOS"];
        userData.device_id = [[UIDevice currentDevice] identifierForVendor].UUIDString;
        
        [LIBRARY_API login:userData withHandler:^(UserData *user, NSError *error){
            self.isProcessing = NO;
            if (!error) {
                SHARED_CONTROLLER.userData = user;
                [[NSUserDefaults standardUserDefaults] setValue:[self.login.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] forKey:@"login"];
                [[NSUserDefaults standardUserDefaults] setValue:[self.password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"password"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                SET_CURRENT_ROLE(USER_DATA.role);
                if ([application.window.rootViewController isKindOfClass:NSClassFromString(@"UINavigationController")]) {
                    
                    [[UINavigationBar appearance] setBackgroundImage:[SHARED_CONTROLLER.currentRoleParametrs[@"navbar_image"]
                                                                      resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)] forBarMetrics:UIBarMetricsDefault];
                    [[UITabBar appearance] setBackgroundImage:[SHARED_CONTROLLER.currentRoleParametrs[@"tabbar_image"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)]];
                    [application startupApplicationFromRegistrationScreen:NO byRole:localTempRole];

                } else {
                    [[UINavigationBar appearance] setBackgroundImage:[SHARED_CONTROLLER.currentRoleParametrs[@"navbar_image"]
                                                                      resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)] forBarMetrics:UIBarMetricsDefault];
                    [[UITabBar appearance] setBackgroundImage:[SHARED_CONTROLLER.currentRoleParametrs[@"tabbar_image"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)]];
                    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
                    SHARED_CONTROLLER.userData.device_token = deviceToken;
                    [application hideActivityView];
                    [self.navigationController popToRootViewControllerAnimated:NO];
                }

                BOOL isEULAShown =[[[NSUserDefaults standardUserDefaults] valueForKey:@"isEULAShown"] boolValue];
                
                if (!isEULAShown) {
                    EULAVC *eulaVC = [EULAVC new];
                    [eulaVC.view setFrame:CGRectMake(0, 0, application.window.frame.size.width, application.window.frame.size.height)];
                    [application.window addSubview:eulaVC.view];
                }
                
            } else {
                [application hideActivityView];
                [SHARED_CONTROLLER handleError:error];
            }
        }];
    }
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.login])
        [self.password becomeFirstResponder];
	else {
        [textField resignFirstResponder];
		[self login:nil];
	}
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    _activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _activeField = nil;
}

-(void)hideKeyboard {
    [self.view endEditing:NO];
}

-(void)keyboardDidShow:(NSNotification*)aNotification {
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(IBAction)signup:(UIStoryboardSegue *)segue {
    [self performSegueWithIdentifier:@"signupSegue" sender:nil];
}

- (IBAction)btnExploreClick:(id)sender {
    USE_APPLICATION;
    [application startupApplicationFromRegistrationScreen:NO byRole:TalentRole];
}

@end

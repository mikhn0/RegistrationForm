#import "FirstScreenViewController.h"
#import "DetailInfoViewController.h"
#import "FBHelper.h"
#import "LibraryAPI.h"

@interface FirstScreenViewController () {
    NSString *lastname, *firstname, *phone;
}

@property (weak, nonatomic) IBOutlet UIButton *btnExplore;

- (IBAction)btnFBClick:(id)sender;
- (IBAction)btnExploreClick:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet UILabel *signUpLabel;
@property (weak, nonatomic) IBOutlet UILabel *fbLoginLabel;

@end

@implementation FirstScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginLabel.text = LNG("firstScreen.loginEnter");
    self.signUpLabel.text = LNG("firstScreen.sign");
    self.fbLoginLabel.text = LNG("firstScreen.fbLogin");
    [self.btnExplore setTitle:LNG("firstScreen.explore") forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setData:)
                                                 name:@"SetDataNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(segueOnSettingScreen:)
                                                 name:@"SegueOnSettingScreenNotification"
                                               object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)setData:(NSNotification *)notification {
    
    lastname = notification.userInfo[@"lastname"];
    firstname = notification.userInfo[@"firstname"];
    phone = notification.userInfo[@"phone"];
    [self performSegueWithIdentifier:@"AfterLoginWithFacebookSegue" sender:self];
    
}

- (void)segueOnSettingScreen:(NSNotification *)notification {
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"AfterLoginWithFacebookSegue"]) {
        DetailInfoViewController *vc = [segue destinationViewController];
        vc.firstnameString = firstname.length > 0 ? firstname : USER_DATA.first_name;
        vc.lastnameString = lastname.length > 0 ? lastname : USER_DATA.last_name;
        vc.phoneString = phone.length > 0 ? phone : USER_DATA.phone;
    }
    
}

- (IBAction)btnFBClick:(id)sender {
    USE_APPLICATION;
    [application showActivityView:LNG("Please wait")];
    [[FBHelper FBHelperSingleton] fb_login:^(BOOL isSuccess) {
        if (isSuccess) {
            if (USER_DATA.is_new) {
                [self performSegueWithIdentifier:@"AfterLoginWithFacebookSegue" sender:self];
                [application hideActivityViewWithDelay:1.0];
            } else {
                NSString *role = USER_DATA.role;
                RoleTypeForColor roleType;
                if ([role isEqualToString:@"fashion_model"]) {
                    roleType = ProfessionalModelRole;
                } else if ([role isEqualToString:@"celebrity"]) {
                    roleType = CelebrityRole;
                } else if ([role isEqualToString:@"talent"]) {
                    roleType = TalentRole;
                } else if ([role isEqualToString:@"guest"]) {
                    roleType = GuestRole;
                }
                [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:@"isEULAShown"];
                [application startupApplicationFromRegistrationScreen:NO byRole:roleType];
                [application hideActivityView];
                [DATA_SERVICE chatConnect:nil];
                [DATA_SERVICE saveUserLocation];
                
                SEND_NOTIF(kCheckUser, nil);
            }
        } else {
            [application hideActivityView];
        }
    }];
}

- (IBAction)btnExploreClick:(id)sender {
	USE_APPLICATION;
	[application startupApplicationFromRegistrationScreen:NO byRole:TalentRole];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            return [SHARED_CONTROLLER deviceModel] == DeviceModel4 ? 160 : 206;
        case 1:
            return [SHARED_CONTROLLER deviceModel] == DeviceModel4 ? 260 : 280;
        case 2:
            return [SHARED_CONTROLLER deviceModel] == DeviceModel4 ? 60 : 83;
        default:
            return 40;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

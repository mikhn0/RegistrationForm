#import "DetailInfoViewController.h"
#import "LibraryAPI.h"

#define MAN @"man"
#define WOMAN @"woman"

@interface DetailInfoViewController ()

@property (assign)                   UITextField    *activeField;
@property (weak, nonatomic) IBOutlet UIButton       *btnLicenseAgreement;
@property (weak, nonatomic) IBOutlet UIButton       *btnMale;
@property (weak, nonatomic) IBOutlet UIButton       *btnFemale;
@property (weak, nonatomic) IBOutlet UILabel        *maleLable;
@property (weak, nonatomic) IBOutlet UILabel        *femaleLable;
@property (weak, nonatomic) IBOutlet UILabel        *continueLabel;

@property (weak, nonatomic) IBOutlet UITextField    *firstname;
@property (weak, nonatomic) IBOutlet UITextField    *lastname;
@property (weak, nonatomic) IBOutlet UITextField    *phone;

- (IBAction)toggleUIButtonImage:(id)sender;
- (IBAction)toggleLicenseAgreement:(UIButton *)sender;
- (IBAction)toogleCheckBoxLecenseAgreement:(UIButton *)sender;

@end


@implementation DetailInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.maleLable.text = LNG("firstScreen.male");
    self.femaleLable.text = LNG("firstScreen.female");
    self.continueLabel.text = LNG("Continue");
    
    [self.firstname setPlaceholder:LNG("firstScreen.firstname")];
    [self.firstname setText:self.firstnameString];
    [self.lastname setPlaceholder:LNG("firstScreen.lastname")];
    [self.lastname setText:self.lastnameString];
    [self.phone setPlaceholder:LNG("firstScreen.phone")];
    [self.phone setText:self.phoneString];
    [self.btnLicenseAgreement setTitle:LNG("firstScreen.licenseAgreement") forState:UIControlStateNormal];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isEULAShown"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UITapGestureRecognizer *hideKeyboardGesture = [[UITapGestureRecognizer alloc]
                                                   initWithTarget:self action:@selector(hideKeyboard)];
    hideKeyboardGesture.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:hideKeyboardGesture];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)hideKeyboard {
    [self.view endEditing:NO];
}

- (IBAction)toggleUIButtonImage:(id)sender {
    if ([sender isSelected]) {
        if ([sender tag] == 1)
            [sender setImage:[UIImage imageNamed:@"ic_male_normal"] forState:UIControlStateNormal];
        else
            [sender setImage:[UIImage imageNamed:@"ic_female_normal"] forState:UIControlStateNormal];
        
        [sender setSelected:NO];
    } else {
        if ([sender tag] == 1) {
            [sender setImage:[UIImage imageNamed:@"ic_male_active"] forState:UIControlStateSelected];
            [self.btnFemale setImage:[UIImage imageNamed:@"ic_female_normal"] forState:UIControlStateNormal];
            [self.btnFemale setSelected:NO];
        } else {
            [sender setImage:[UIImage imageNamed:@"ic_female_active"] forState:UIControlStateSelected];
            [self.btnMale setImage:[UIImage imageNamed:@"ic_male_normal"] forState:UIControlStateNormal];
            [self.btnMale setSelected:NO];
        }
        [sender setSelected:YES];
    }
}


- (IBAction)toggleLicenseAgreement:(UIButton *)sender {
    USE_APPLICATION;
    EULAVC *eulaVC = [[EULAVC alloc] init];
    [eulaVC.view setFrame:CGRectMake(0, 0, application.window.frame.size.width, application.window.frame.size.height)];
    [application.window addSubview:eulaVC.view];
}

- (IBAction)toogleCheckBoxLecenseAgreement:(UIButton *)sender {
    if ([sender isSelected]) {
        [sender setImage:[UIImage imageNamed:@"checkbox_license_agreement"] forState:UIControlStateNormal];
        sender.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [sender setSelected:NO];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isEULAShown"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [sender setImage:[UIImage imageNamed:@"select_checkbox_license_agreement"] forState:UIControlStateSelected];
        sender.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 3.5 , 0);
        [sender setSelected:YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isEULAShown"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (IBAction)btnSignClick:(id)sender {
    if (!allTrim(self.lastname.text).length || !allTrim(self.firstname.text).length || !allTrim(self.phone.text).length || (!self.btnFemale.selected && !self.btnMale.selected)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:LNG("Please fill all of the fields") delegate:nil cancelButtonTitle:LNG("Btn.OK") otherButtonTitles:nil];
        [alert show];
        return;
    }
    BOOL isEULAShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"isEULAShown"];
    if ( !isEULAShown ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LNG("eula.info") message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    } else {
        USE_APPLICATION;
        [application showActivityView:LNG("Please wait")];
        USER_DATA.last_name = self.lastname.text;
        USER_DATA.first_name = self.firstname.text;
        USER_DATA.phone = self.phone.text;
        USER_DATA.show_login = YES;
        USER_DATA.gender = self.btnMale.selected ? MAN : WOMAN;
        if ((self.firstnameString.length > 0 && ![self.firstnameString isEqualToString:self.firstname.text]) || (self.lastnameString.length > 0 && ![self.lastnameString isEqualToString:self.lastname.text]) || (self.phoneString > 0 && ![self.lastnameString isEqualToString:self.phone.text])) {
            [LIBRARY_API updateUserWithParams:USER_DATA withCompletion:^(UserData *user, NSError *error) {
                if (!error) {
                    [self performSegueWithIdentifier:@"SelectRoleTypeSegue" sender:self];
                    [application hideActivityView];
                } else {
                    [application hideActivityView];
                    [SHARED_CONTROLLER handleError:error];
                    return;
                }
            }];
        } else {

            [LIBRARY_API updateExtendedProfile:USER_DATA withCompletion:^(id object, NSError *error) {
                if (!error) {
                    [self performSegueWithIdentifier:@"SelectRoleTypeSegue" sender:self];
                    [application hideActivityView];
                } else {
                    [application hideActivityView];
                    [SHARED_CONTROLLER handleError:error];
                    return;
                }
            }];
        }
#warning сохранять пол
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.lastname])
        [self.firstname becomeFirstResponder];
    else    if ([textField isEqual:self.firstname])
        [self.phone becomeFirstResponder];
    else
        [textField resignFirstResponder];
    return YES;
}

#pragma mark Keyboard move up

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _activeField = nil;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

#pragma mark -

- (UITableViewCell*) getCellFromView:(UIView*) view {
    
    for ( ; view && ![view isKindOfClass:[UITableViewCell class]]; view = view.superview ) {
    }
    
    return [view isKindOfClass:[UITableViewCell class]] ? (UITableViewCell*)view : nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return [SHARED_CONTROLLER deviceModel] == DeviceModel4 ? 91 : 180;
        case 1:
            return [SHARED_CONTROLLER deviceModel] == DeviceModel4 ? 239 : 255;
        case 2:
            return [SHARED_CONTROLLER deviceModel] == DeviceModel4 ? 87: 97;
        default:
            return 40;
    }
}


@end

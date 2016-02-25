#import "ParametersOfModelViewController.h"
#import "SelectAgencyViewController.h"
#import "CameraViewController.h"
#import "TakeSelfieViewController.h"
#import "LibraryAPI.h"


@interface ParametersOfModelViewController () <UITextFieldDelegate> {
    UITextField *activeField;
    User *tempUser;
    UserData *tempUserData;
    NSMutableDictionary *beforeDict, *afterDict;
    NSString *linkPortfolio, *linkModels;
}

@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *btnChooseAgency;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *profileTF;
@property (weak, nonatomic) IBOutlet UITextField *facebookTF;
@property (weak, nonatomic) IBOutlet UIImageView *selfieImageView;
@property (nonatomic) NSString *agencyName;
@property (nonatomic) NSString *cityName;
@property (nonatomic) NSInteger agencyId;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSendBtnConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topAddSelfieBtnConstraint;
@property (weak, nonatomic) IBOutlet UILabel *sendLabel;
@property (weak, nonatomic) IBOutlet UIView *view2Outlet;


- (IBAction)finishRegistration:(id)sender;

@end

@implementation ParametersOfModelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ( iPhone4 ) {
        self.topAddSelfieBtnConstraint.constant = 20;
        self.topSendBtnConstraint.constant = 20;
        [self.view setNeedsUpdateConstraints];
    }
    
    [self registerForKeyboardNotifications];
    [self.selfieImageView setImage:self.selfieImage];
    self.selfieImageView.backgroundColor = SHARED_CONTROLLER.currentRoleParametrs[@"selfi_bgr_color"];
    self.btnAddSelfie.titleLabel.textColor = SHARED_CONTROLLER.currentRoleParametrs[@"color"];
    self.btnAddSelfie.titleLabel.text = LNG("Add selfie");
    
    [self.sendBtn setImage:SHARED_CONTROLLER.currentRoleParametrs[@"send_btn_image"] forState:UIControlStateNormal];
    [self.sendBtn setImage:SHARED_CONTROLLER.currentRoleParametrs[@"send_btn_active_image"] forState:UIControlStateHighlighted];
    self.sendLabel.text = LNG("Send");
    
    self.profileTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LNG("Profile_agency") attributes:@{NSForegroundColorAttributeName:DEACTIVE_FIELD}];
    self.facebookTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Facebook" attributes:@{NSForegroundColorAttributeName:DEACTIVE_FIELD}];
    
    if ( self.roleType == TalentRole ) {
        self.profileTF.enabled = NO;
        self.profileTF.hidden = YES;
        self.view2Outlet.hidden = YES;
    }
    if ( self.roleType == CelebrityRole ) {
        self.btnChooseAgency.frame = CGRectZero;
        self.btnChooseAgency.hidden = YES;
    } else if (self.roleType == TalentRole ) {
        [self.btnChooseAgency setTitle:LNG("Choose_your_profession") forState:UIControlStateNormal];
        self.btnChooseAgency.layer.borderColor = [UIColor colorWithRed:177.0/255.0 green:134.0/255.0 blue:245.0/255.0 alpha:1.0].CGColor;
        self.btnChooseAgency.layer.borderWidth = 1.0;
        self.btnChooseAgency.hidden = NO;
    } else {
        [self.btnChooseAgency setTitle:LNG("Choose_your_agency") forState:UIControlStateNormal];
        self.btnChooseAgency.layer.borderColor = [UIColor colorWithRed:177.0/255.0 green:134.0/255.0 blue:245.0/255.0 alpha:1.0].CGColor;
        self.btnChooseAgency.layer.borderWidth = 1.0;
        self.btnChooseAgency.hidden = NO;
    }
    
    CGSize scrollViewContentSize = self.view.frame.size;
    [self.scrollView setContentSize:scrollViewContentSize];
    
    tempUserData = USER_DATA;
    UITapGestureRecognizer *hideKeyboardGesture = [[UITapGestureRecognizer alloc]
                                                   initWithTarget:self action:@selector(hideKeyboard)];
    hideKeyboardGesture.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:hideKeyboardGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    CGPoint scrollPoint = CGPointMake(0.0, 45.0);
    [self.scrollView setContentOffset:scrollPoint animated:YES];
}

- (void)hideKeyboard {
    [self.view endEditing:NO];
}

- (IBAction)finishRegistration:(id)sender {
    
    USE_APPLICATION;
    
    [application showActivityView:LNG("Please wait")];
    
    if (!allTrim(self.facebookTF.text).length || (!allTrim(self.profileTF.text).length && self.roleType == ProfessionalModelRole)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:LNG("Please fill all of the fields") delegate:nil cancelButtonTitle:LNG("Btn.OK") otherButtonTitles:nil];
        [alert show];
        [application hideActivityView];
        return;
    }
    if ( !self.selfieImage ) {
        [application setActivityText:LNG("Make selfie")];
        [application hideActivityViewWithDelay:2.0];
        return;
    }
    if ( !self.agencyName && self.roleType != CelebrityRole) {
        [application setActivityText:LNG("Add agency")];
        [application hideActivityViewWithDelay:2.0];
        return;
    }
    NSString *targetRole;
    if (self.roleType == CelebrityRole) {
        targetRole = role_celebrity;
        
    } else if (self.roleType == TalentRole) {
        targetRole = role_model;
        tempUserData.profession_id = self.agencyId; // При Talant agencyName эквивалентно professionName
        tempUserData.profession = self.agencyName;
        
    } else if (self.roleType == ProfessionalModelRole) {
        targetRole = role_prof_model;
        tempUserData.agencies = @[@(self.agencyId)];
        
    } else {
        targetRole = role_user;
        
    }
    
    tempUserData.links = @[].mutableCopy;
    
    if (self.facebookTF.text > 0) {
        LinkData *linkFacebook = [LinkData new];
        linkFacebook.variant = @"facebook";
        linkFacebook.source = self.facebookTF.text;
        [tempUserData.links addObject:linkFacebook];
    }

    if (self.profileTF.text.length > 0) {
        LinkData *linkPortf = [LinkData new];
        linkPortf.variant = @"portfolio";
        linkPortf.source = self.profileTF.text;
        [tempUserData.links addObject:linkPortf];
    }
    
    tempUserData.target_role = targetRole;
    
    if ( self.selfieImage ) {
       tempUserData.selfie = self.selfieImage;
        [application showActivityView:LNG("Please wait")];
        
       dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
           SHARED_CONTROLLER.currentRoleParametrs = [SHARED_CONTROLLER getRoleParametrsForRoleInt:-1];
           
           [LIBRARY_API updateUserWithParams:tempUserData withCompletion:^(UserData *user, NSError *error) {
               NSLog(@"ERROR ==== %@", error);
               if (!error) {
                   dispatch_async(dispatch_get_main_queue(), ^{
                       AGENCY_MODULE.current_agency.title = self.agencyName;
                       AGENCY_MODULE.current_agency.city_name = self.cityName;
                       AGENCY_MODULE.current_agency.ID = self.agencyId;
                       USER_DATA = tempUserData;
                       
                       [application hideActivityView];
                       [application startupApplicationFromRegistrationScreen:YES byRole:self.roleType];
                       [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];

                   });
               } else {
                   [SHARED_CONTROLLER handleError:error];
                   [application hideActivityView];
               }

           }];
       });
    }
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
    if (textField.tag == 1001 && (textField.text.length <= 25)) {
        
        textField.text = @"https://www.facebook.com/";
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (NSString *)GetUUID {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

- (IBAction)unwindToChooseRoleVC:(UIStoryboardSegue *)unwindSegue {
    if ([unwindSegue.identifier isEqualToString:@"unwindChooseRole"]) {
        SelectAgencyViewController *vc = (SelectAgencyViewController *)unwindSegue.sourceViewController;
        if (vc.selectedAgency) {
            self.agencyName = vc.selectedAgency;
            self.cityName = vc.selectedCity;
            self.agencyId = vc.selectedAgencyId;
            [self.btnChooseAgency setTitle:[NSString stringWithFormat:@"%@ / %@", vc.selectedCity, vc.selectedAgency] forState:UIControlStateNormal];
        }
    }
}


- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue {
    if ([unwindSegue.identifier isEqualToString:@"TakeSelfieUnwindSegue"]) {
        TakeSelfieViewController *takeSelfieVC = (TakeSelfieViewController *)unwindSegue.sourceViewController;
        takeSelfieVC.modalPresentationStyle = UIModalPresentationNone;
    
        if (takeSelfieVC.selfie) {
            self.selfieImageView.image = takeSelfieVC.selfie;
            self.btnAddSelfie.backgroundColor = [UIColor clearColor];
            [self.btnAddSelfie setBackgroundImage:nil forState:UIControlStateNormal];
            self.btnAddSelfie.titleLabel.text = nil;
            self.roleColor = takeSelfieVC.roleColor;
            self.roleType = takeSelfieVC.roleType;
            self.selfieImage = takeSelfieVC.selfie;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CameraSegue"]) {
        CameraViewController *vc = (CameraViewController *)segue.destinationViewController;
        vc.roleType = self.roleType;
        vc.roleColor = self.roleColor;
    } else if ([segue.identifier isEqualToString:@"SelectAgencySegue"]) {
        SelectAgencyViewController *vc = (SelectAgencyViewController *)segue.destinationViewController;
        if (self.roleType == TalentRole) {
            vc.selectorType = ProfessionSelector;
        } else if (self.roleType == ProfessionalModelRole) {
            vc.selectorType = AgencySelector;
        }
    }
}

@end

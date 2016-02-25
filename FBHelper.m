#import "FBHelper.h"
#import "UIViewController+Localization.h"
#import "EULAVC.h"
#import "LibraryAPI.h"

#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>


@implementation FBHelper

static FBHelper * _FBHelperSingleton = nil;

+ (FBHelper*)FBHelperSingleton
{
    @synchronized([FBHelper class])
    {
        if (!_FBHelperSingleton)
        {
            _FBHelperSingleton = [[self alloc] init];
        }
        return _FBHelperSingleton;
    }
    return nil;
}

+ (id)alloc {
    @synchronized([FBHelper class])
    {
        NSAssert(_FBHelperSingleton == nil, @"Attempted to allocate a second instance of a singleton.");
        _FBHelperSingleton = [super alloc];
        return _FBHelperSingleton;
    }
    return nil;
}

- (void)fb_login:(void (^)  (BOOL isSuccess))handler {
    NSArray *permissionsArray = @[@"user_about_me", @"user_birthday", @"email"];
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:permissionsArray fromViewController:nil handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
             handler(NO);
             [SHARED_CONTROLLER handleError:error];
         } else if (result.isCancelled) {
             NSLog(@"Cancelled ===== ");
             handler(NO);
         } else {
             if ([FBSDKAccessToken currentAccessToken]) {
                 __block FBSDKAccessToken *token = result.token;
                 NSLog(@"------Get user data from facebook------");
                 [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
                  startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                      if (!error) {
                          NSLog(@"------------------OK-------------------");
                          NSString *device_token;
                          if ([[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]) {
                              device_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
                          } else {
                              device_token = @"";
                          }
                          NSString *app_version = [[NSUserDefaults standardUserDefaults] objectForKey:@"BundleShortVersionString"];
                          NSString *revision = [[NSUserDefaults standardUserDefaults] objectForKey:@"BundleVersion"];
                          NSString *platform = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentPlatform"];
                          NSString *os = [[NSUserDefaults standardUserDefaults] objectForKey:@"TypePlatform"];
                          NSString *mobile_version = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentVersionIOS"];
                          NSString *device_id = [UIDevice currentDevice].identifierForVendor.UUIDString;
                          
                          NSDictionary *params = @{@"user":@{@"social":@{@"email":result[@"email"] ? result[@"email"] : @"", @"user_social_id":token.userID, @"token":token.tokenString, @"expiration":token.expirationDate, @"social_title":@"facebook"}, @"device_token":device_token, @"app_version":app_version, @"revision":revision, @"platform":platform, @"mobile_version":mobile_version, @"device_id":device_id, @"os": os}};
                          NSLog(@"      -----------LOGIN-ON-OUR-SERVER---------");
                          [LIBRARY_API loginSocial:params withHandler:^(UserData *user, NSError *error) {
                              if (error) {
                                  handler(NO);
                                  [SHARED_CONTROLLER handleError:error];
                                  return;
                              }
                              SHARED_CONTROLLER.userData = user;
                              if (!user) {
                                  NSString *errorMessage = nil;
                                  if (!error) {
                                      NSLog(@"Uh oh. The user cancelled the Facebook login.");
                                      errorMessage = @"Uh oh. The user cancelled the Facebook login.";
                                  } else {
                                      NSLog(@"Uh oh. An error occurred: %@", error);
                                      errorMessage = [error localizedDescription];
                                      errorMessage = @"Uh oh. Please, try again.";
                                  }
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                                                  message:errorMessage
                                                                                 delegate:nil
                                                                        cancelButtonTitle:nil
                                                                        otherButtonTitles:@"Dismiss", nil];
                                  [alert show];
                                  handler(NO);
                              } else {
                                  
                                  SHARED_CONTROLLER.isAuthFBAlready=YES;
                                  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"fb_login"];
                                  [[NSUserDefaults standardUserDefaults] synchronize];
                                  SEND_NOTIF(kCheckUser, nil);
                                  handler(YES);
                              }
                              NSLog(@"userData ==== %li, email === %@", (long)user.ID, user.email);
                          }];
                          NSLog(@"fetched user: %@", result);
                      } else {
                          NSLog(@"-----------------ERROR-----------------");
                          [SHARED_CONTROLLER handleError:error];
                          NSLog(@"-----------------ERROR-----------------");
                      }
                  }];
             }
             NSLog(@"Logged in");
         }
     }];
}

- (void)_loadDataforReg:(BOOL)forReg WithSuccess:(void (^)  (BOOL isSuccess))handler {
    FBSDKGraphRequest *requestMe = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
    
    [requestMe startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            UserData *user  = SHARED_CONTROLLER.userData;
    
            NSDictionary *userData = (NSDictionary *)result;
            
            LinkData *linkFacebook = [LinkData new];
            linkFacebook.source = userData[@"link"];
            linkFacebook.variant = @"facebook";
            
            user.links = @[linkFacebook];
            NSString *email = userData[@"email"];
            NSString *facebookID = userData[@"id"];
            NSMutableArray* arrUsers = [NSMutableArray array];
            [DATA_SERVICE getUserByEmail:email ? email : userData[@"id"] block:^(NSArray *objects, NSError *error) {
                NSLog(@"users %@",objects);
                [arrUsers addObjectsFromArray:objects];
                BOOL itsOK=YES;
                BOOL isTempUserName=NO;
                if ([arrUsers count]>0) //такой юзер уже есть в БАЗЕ
                {
                    UserData *tempUser = (UserData *)[arrUsers objectAtIndex:0];
                    NSString*FaceBookIDUser = @"0";

                    if ([FaceBookIDUser isEqualToString:facebookID]) //этот юзер регался через ФБ
                    {
                        itsOK=YES;
                    } else//этот юзер регался старым способом
                    {
                        
                        NSString* tempUsername = tempUser.login ? : user.login;
                        
                        user.password = tempUser.password?:user.password;
                        user.first_name = tempUser.first_name?:user.first_name;
                        user.last_name = tempUser.last_name?:user.last_name;
                        user.phone = tempUser.phone ? : user.phone;
                        user.birthday = tempUser.birthday ? : user.birthday;
                        user.helpful = tempUser.helpful ? : user.helpful ? : 0;
                        user.platform = tempUser.platform ? : user.platform;
                        user.revision = tempUser.revision ? : user.revision;
                        user.selfie = tempUser.selfie ? : user.selfie;
                        user.agencies = tempUser.agencies ? : user.agencies;

                        user.avatar = tempUser.avatar ? : user.avatar;
                        user.city = tempUser.city ? : user.city;
                        user.country = tempUser.country ? : user.country;
                        user.passport_photo = tempUser.passport_photo ? : user.passport_photo;
                        user.photos = tempUser.photos ? : user.photos;
                        user.upTo = tempUser.upTo ? : user.upTo;
                        user.city = user.city ? : tempUser.city;
                        user.role = tempUser.role;

                        NSDictionary *params = [NSDictionary dictionaryWithObject:@(tempUser.ID) forKey:@"userID"];
                        NSError *error;
                        
                        [PFCloud callFunction:@"deleteUserWithoutCheck" withParameters:params error:&error];
                        
                        if (error) {
                            NSLog(@"%@",error);
                        }else{
                            isTempUserName = YES;
                            user.login = tempUsername;
                        }
                        itsOK = YES;
                    }

                } else {
                    
                    itsOK=YES;
                }
                if ((itsOK)&&(forReg || user.avatar == nil)) //для решения конфликта с сохранением фото
                {
                    if (forReg) {
                        user.show_login = NO;
                    }
                    NSString* first = [NSString stringWithFormat:@"%@",userData[@"first_name"]];


                    if ([first rangeOfString:@"null"].location == NSNotFound) {
                        user.first_name = user.first_name?:first;
                    } else {

                    }

                    NSString* sec = [NSString stringWithFormat:@"%@",userData[@"last_name"]];
                    if ([sec rangeOfString:@"null"].location == NSNotFound) {
                        user.last_name = user.last_name?: sec;
                    } else {

                    }
                    NSString *nick=isTempUserName? user.login : userData[@"name"];
                        [DATA_SERVICE searchUsersWithNick:nick block:^(NSArray *objects, NSError *error) {

                            if ([objects count]<1) {
                                user.login = nick;
                            } else {
								if (forReg)
                                {
                                    user.login = [NSString stringWithFormat:@"%@%d",nick,arc4random()%1000];
                                }
                            }
                            user.email = email;
                            NSString *birthday = userData[@"birthday"];
                            NSDate*  birthDate =nil;
                            NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
                            [inFormat setDateFormat:@"MM/dd/yyyy"];
                            birthDate = [inFormat dateFromString:birthday];
                            if (birthDate)
                            {
                                user.birthday = user.birthday ? : birthDate;
                            }

                            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
                            {
                                UIImage * avaImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:pictureURL]];
                                user.avatar = avaImage;
                            }
                        }];
                }

                handler(itsOK);
                if (forReg) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"SetDataNotification" object:nil userInfo:@{@"lastname":userData[@"last_name"] ? userData[@"last_name"]:@"", @"firstname":userData[@"first_name"]?userData[@"first_name"]:@"", @"phone":userData[@"phone"]?userData[@"phone"]:@""}];
                }
            }];
        }
    }];
}

@end

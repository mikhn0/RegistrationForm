#import <UIKit/UIKit.h>

#define DEACTIVE_FIELD [UIColor colorWithRed:94.0/255.0 green:105.0/255.0 blue:127.0/255.0 alpha:1.0]

@interface ParametersOfModelViewController : UIViewController

@property (nonatomic) RoleTypeForColor roleType;
@property (nonatomic) UIColor *roleColor;
@property (weak, nonatomic) IBOutlet UIButton *btnAddSelfie;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *settingView;
@property (nonatomic) UIImage *selfieImage;

@end

#import <UIKit/UIKit.h>

@interface EULAVC : UIViewController
{
    IBOutlet UITextView* txtEULA;
    IBOutlet UIButton* btnAccept;
    IBOutlet UIButton* btnCancel;

}
@property (strong, nonatomic)EULAVC* strongSelf;
-(IBAction)btnDeclineEULAClick:(id)sender;

@end

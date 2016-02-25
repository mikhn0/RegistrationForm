#import <UIKit/UIKit.h>

@interface PasswordViewController : MyTableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UILabel *fogotBtn;
- (IBAction)reset:(id)sender;
- (IBAction)back:(id)sender;

@end

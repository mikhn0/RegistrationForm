#import "EULAVC.h"

@interface EULAVC ()

@end

@implementation EULAVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.strongSelf = self;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"eula" ofType:@"txt"];

    if (filePath) {
        NSError* err=nil;
        NSString* myText = [[NSString alloc] initWithContentsOfFile:filePath encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingWindowsHebrew) error:&err];
        if (myText) {
            txtEULA.text= myText;
        } else {
            NSLog(@"error EULA %@",err);
        }
    }
 [txtEULA scrollRangeToVisible:NSMakeRange(0, 0)];

}

-(IBAction)btnDeclineEULAClick:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SegueOnSettingScreenNotification" object:nil];
    [self.view removeFromSuperview];
}

@end

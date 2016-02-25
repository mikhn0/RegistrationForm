#import "ChooseTalentViewController.h"
#import "HorizontalScroller.h"
#import "BulletListLabel.h"
#import <GLKit/GLKit.h>
#import "BallonImageView.h"
#import "ParametersOfModelViewController.h"


typedef NS_ENUM(NSUInteger, DirectionOnMotion) {
    fromRight = 1,
    fromLeft = -1
};

@interface ChooseTalentViewController ()
{
    NSArray *roleArray, *roleTitle, *textArray;
    int currentRoleIndex;
    CGFloat height;
    CGFloat angle, motionRadiusX, motionRadiusY, rad;
    BallonImageView *ballonImageView1, *leftImageView, *rightImageView;
    CGPoint startPosition;
    NSMutableArray *arrayOfImageView;
    CGFloat sizeForCenterImageView, sizeForBoundImageView, sizeOfHorda, heightOfBorderBall, heightOfCenterBall;
    BulletListLabel *bulletLabel;
    RoleTypeForColor roleType;
    NSMutableArray *arrayOfVectors;
    BOOL successLeft, successRight;
    NSTimer *timer;
    CGPoint zeroPoint;
    NSDictionary *currentTypeRole;
    BallonImageView *imageViewFirst;
}

@property (weak, nonatomic) IBOutlet UIButton *continueBtn;
@property (weak, nonatomic) IBOutlet UIView *textView;
@property (weak, nonatomic) IBOutlet HorizontalScroller *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *labelUpdateStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelNowYouGuest;
@property (weak, nonatomic) IBOutlet UIButton *continueAsGuest;
@property (weak, nonatomic) IBOutlet UIImageView *ovalLineImageView;
@property (weak, nonatomic) IBOutlet UILabel *roleLabel;
@property (weak, nonatomic) IBOutlet UILabel *explanationLabel;
@property (weak, nonatomic) IBOutlet UILabel *sendLabel;

- (IBAction)clickContinueAsGuest:(UIButton *)sender;
- (void)moveViewWithGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer;

@end

@implementation ChooseTalentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sendLabel.text = LNG("Send");
    
    heightOfBorderBall = self.scrollView.frame.size.height/2;
    heightOfCenterBall = self.scrollView.frame.size.height;
    currentTypeRole = [NSDictionary new];
    currentRoleIndex = 1;
    roleArray = @[[UIImage imageNamed:@"ic_stat_role_celebrity"], [UIImage imageNamed:@"ic_stat_role_profmodel"], [UIImage imageNamed:@"ic_stat_role_talent"], [UIImage imageNamed:@"ic_stat_role_celebrity"], [UIImage imageNamed:@"ic_stat_role_profmodel"], [UIImage imageNamed:@"ic_stat_role_talent"]];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    [self.labelUpdateStatus setText:LNG("Or update your status")];
    [self.continueAsGuest setTitle:LNG("Continue as a Guest") forState:UIControlStateNormal];
    [self.explanationLabel setText:LNG("Explanation Profession Model")];
    [self.labelNowYouGuest setText:LNG("Now you Guest")];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewWithGestureRecognizer:)];
    sizeForCenterImageView = self.scrollView.frame.size.height;
    sizeForBoundImageView = self.scrollView.frame.size.height/2;
    sizeOfHorda = self.scrollView.frame.size.width;
    arrayOfImageView = [NSMutableArray new];
    
    for (int i=0; i<3; i++) {
        ballonImageView1 = [[BallonImageView alloc] initWithFrame:CGRectMake(0, 0, sizeForBoundImageView, sizeForBoundImageView)];
        CGFloat startAngle;
        if (i == 0) {
            startAngle = atan(40/(self.ovalLineImageView.frame.size.width/2))+0.4;
            ballonImageView1.heightOfBall = heightOfBorderBall;
        } else if (i == 1) {
            startAngle = M_PI / 2;
            ballonImageView1.tag = 1;
            ballonImageView1.heightOfBall = heightOfCenterBall;
        } else if ( i == 2 ) {
            startAngle = M_PI - atan(40/(self.ovalLineImageView.frame.size.width/2)) - 0.4;
            ballonImageView1.heightOfBall = heightOfBorderBall;
        }
        ballonImageView1.centerEllipse = CGPointMake(self.scrollView.frame.size.width/2, self.scrollView.frame.size.height/2 + self.ovalLineImageView.frame.size.height + 40);
        ballonImageView1.radiusEllipse = CGSizeMake(self.ovalLineImageView.frame.size.width/2 + 40, self.ovalLineImageView.frame.size.height + 40);
        ballonImageView1.alpha = startAngle;
        ballonImageView1.image = roleArray[i];
        [self.scrollView addSubview:ballonImageView1];
        [ballonImageView1 addGestureRecognizer:panGestureRecognizer];
        [arrayOfImageView addObject:ballonImageView1];
    }
    [self showDataForRoleAtIndex:1];
    successLeft = successRight = YES;
    arrayOfVectors = [NSMutableArray new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTextViewNotification:) name:@"ChangeTextViewNotification" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)moveViewWithGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer{
    CGPoint touchLocation = [panGestureRecognizer locationInView:self.view];
    self.scrollView.center = touchLocation;
    
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event {
    CGPoint point=[[touches anyObject] locationInView:self.scrollView];
    startPosition = zeroPoint = point;
}

- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self.scrollView];
    [arrayOfVectors addObject:@(point.x)];
    /// Test point
    BOOL flagSuccess = YES;
    for (BallonImageView *imageView in arrayOfImageView) {
        [imageView testPoint:asin((point.x - startPosition.x) / (self.ovalLineImageView.frame.size.width/2 + 40))];
        if (imageView.tag == 1) {
            if (imageView.x1 > self.view.frame.size.width && imageView.y1 > self.scrollView.frame.size.height/2 + self.ovalLineImageView.frame.size.height) {
                flagSuccess = NO;
            } else if ( imageView.x1 < 0 && imageView.y1 > self.scrollView.frame.size.height/2 + self.ovalLineImageView.frame.size.height ) {
                flagSuccess = NO;
            }
        }
    }
    if (flagSuccess) {
        for (BallonImageView *imageView in arrayOfImageView) {
            imageView.betta = asin((point.x - startPosition.x) / (self.ovalLineImageView.frame.size.width/2));
            successLeft = successRight = YES;
        }
        startPosition = point;
    } else {
        for (BallonImageView *imageView in arrayOfImageView) {
            if (imageView.center.x < self.view.frame.size.width && imageView.x1 > self.view.frame.size.width && imageView.y1 > self.view.frame.size.height && successRight) {
                imageView.betta = asin((self.view.frame.size.width - imageView.center.x) / ((self.ovalLineImageView.frame.size.width/2 + 40)));
                successRight = NO;
            } else if (imageView.center.x > 0 && imageView.x1 < 0 && imageView.y1 > self.view.frame.size.height && successLeft){
                imageView.betta = asin(- imageView.center.x / ((self.ovalLineImageView.frame.size.width / 2) + 40));
                successLeft = NO;
            }
        }
    }
    

}

- (void)updateToRight:(NSTimer *)timer1  {
    
    if (imageViewFirst.betta < 3 * M_PI_2) {
        for (BallonImageView *imageView in arrayOfImageView) {
            imageView.betta = 2 * M_PI / 180;
        }
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeTextViewNotification" object:self userInfo:@{@"index":timer1.userInfo[@"i"]}];
        [timer invalidate];
        timer = nil;
    }
}

- (void)updateToLeft:(NSTimer *)timer1 {
    
        if (imageViewFirst.betta > 3 * M_PI_2) {
            for (BallonImageView *imageView in arrayOfImageView) {
                imageView.betta = - 2 * M_PI / 180;
            }
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeTextViewNotification" object:self userInfo:@{@"index":timer1.userInfo[@"i"]}];
            [timer invalidate];
            timer = nil;
        }
}

- (void)changeTextViewNotification:(NSNotification *)notification
{
    for (id subview in self.textView.subviews) {
        [subview removeFromSuperview];
    }
    [self showDataForRoleAtIndex:[notification.userInfo[@"index"] integerValue]];
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event {
    CGPoint point=[[touches anyObject] locationInView:self.scrollView];
    [arrayOfVectors addObject:@(point.x)];
    if (zeroPoint.x < point.x) {
        int i = 0;
        imageViewFirst = arrayOfImageView[0];
        if (!(imageViewFirst.center.x > 0 && imageViewFirst.center.x < self.view.frame.size.width/2)) {
            i = 1;
            imageViewFirst = arrayOfImageView[i];
        }
        [timer invalidate];
        timer = nil;
        CGFloat time = 1.0/60.0;
        timer = [NSTimer timerWithTimeInterval:time target:self selector:@selector(updateToRight:) userInfo:@{@"i":@(i)} repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    } else {
        int i = 2;
        imageViewFirst = arrayOfImageView[2];
        [imageViewFirst testPoint:imageViewFirst.betta];
        if (!(imageViewFirst.center.x >= self.view.frame.size.width/2 && imageViewFirst.center.x <= self.view.frame.size.width)) {
            imageViewFirst = arrayOfImageView[1];
            i = 1;
        }
        [timer invalidate];
        timer = nil;
        CGFloat time = 1.0/60.0;
        timer = [NSTimer timerWithTimeInterval:time target:self selector:@selector(updateToLeft:) userInfo:@{@"i":@(i)} repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    }
}

- (void)showDataForRoleAtIndex:(int)index {
    height = 0;
    int realIndex = index;
    
    for (int i = 0; i < arrayOfImageView.count; i++) {
        BallonImageView *imageView = arrayOfImageView[i];
        if (imageView.center.x < 2 * sizeOfHorda / 3 && imageView.center.x > sizeOfHorda / 3) {
            realIndex = i;
        } 
    }
    currentTypeRole = [SHARED_CONTROLLER getRoleParametrsForRoleInt:realIndex];
    roleType = realIndex;
    for (int i=0; i < [currentTypeRole[@"text"] count]; i++) {
        bulletLabel = [[BulletListLabel alloc] initWithFrame:CGRectMake(0, height, self.textView.frame.size.width, 30.0)];
        [bulletLabel setTextForLabel:[currentTypeRole[@"text"] objectAtIndex:i]  forRole:roleType];
        if (iPhone4) {
            CGSize maximumLabelSize     = CGSizeMake(244, FLT_MAX);
            NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
            NSDictionary *attr = @{NSFontAttributeName: [UIFont systemFontOfSize:12]};
            CGRect labelBounds = [bulletLabel.text boundingRectWithSize:maximumLabelSize
                                                      options:options
                                                   attributes:attr
                                                      context:nil];
            labelBounds.size.width = 244;
            labelBounds.size.height += 15;
            labelBounds.origin.y = height;
            bulletLabel.frame = labelBounds;
        } else {
            [self resizeHeightToFitForLabel:bulletLabel];
        }
        
        height += bulletLabel.frame.size.height;
        [self.textView addSubview:bulletLabel];
    }
    NSAttributedString *attribute = [[NSAttributedString alloc] initWithString:currentTypeRole[@"title"] attributes:@{NSForegroundColorAttributeName:currentTypeRole[@"color"]}];
    self.roleLabel.attributedText = attribute;
    [self.continueBtn setImage:currentTypeRole[@"send_btn_active_image"] forState:UIControlStateHighlighted];
    [self.continueBtn setImage:currentTypeRole[@"send_btn_image"] forState:UIControlStateNormal];
}

- (CGFloat)heightForLabel:(UILabel *)label withText:(NSString *)text {
    CGSize maximumLabelSize     = CGSizeMake(244, FLT_MAX);
    UIFont *font = [UIFont boldSystemFontOfSize:18];
    CGRect expectedLabelSize = [text boundingRectWithSize:maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    return expectedLabelSize.size.height;
}

- (void)resizeHeightToFitForLabel:(UILabel *)label
{
    CGRect newFrame         = label.frame;
    newFrame.size.height    = [self heightForLabel:label withText:label.text]-15;
    label.frame             = newFrame;
}

- (IBAction)clickContinueAsGuest:(UIButton *)sender {
    USE_APPLICATION;
    SHARED_CONTROLLER.currentRoleParametrs = [SHARED_CONTROLLER getRoleParametrsForRoleInt:-1];
    [application startupApplicationFromRegistrationScreen:NO byRole:GuestRole];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"AddingInfoForRoleSegue"]) {
        ParametersOfModelViewController *vc = (ParametersOfModelViewController *)[segue destinationViewController];
        vc.roleType = roleType;
        vc.roleColor = currentTypeRole[@"color"];
        SHARED_CONTROLLER.currentRoleParametrs = currentTypeRole;
        vc.view.backgroundColor = [UIColor whiteColor];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

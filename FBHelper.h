#import <Foundation/Foundation.h>

@interface FBHelper : NSObject
{
    
}

+(FBHelper*)FBHelperSingleton;
-(void)fb_login:(void (^) (BOOL isSuccess))handler;

@end

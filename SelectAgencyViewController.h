#import "MyController.h"

typedef NS_ENUM(NSInteger, SelectorType)
{
    AgencySelector,
    ProfessionSelector
};

@interface SelectAgencyViewController : MyTableViewController

@property (nonatomic) SelectorType selectorType;
@property (nonatomic) NSString *selectedAgency;
@property (nonatomic) NSString *selectedCity;
@property (nonatomic) NSInteger selectedAgencyId;

@end

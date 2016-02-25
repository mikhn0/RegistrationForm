#import "SelectAgencyViewController.h"
#import "Agency.h"
#import "LibraryAPI.h"

#import "NSMutableArray+Agency.h"

@interface SelectAgencyViewController () {
    NSMutableArray *agencyArr, *cityArr, *alpabeticArray, *orderAgencyArray;
    NSMutableDictionary *agencyDictionary;
    NSArray *modelAgencies;
}

@property (nonatomic) IBOutlet UIBarButtonItem *saveButton;

@end

@implementation SelectAgencyViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.selectorType == AgencySelector) {
        [self configurationAgencyContent];
    } else if (self.selectorType == ProfessionSelector) {
        [self configurationProfessionContent];
    }
    self.saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Save"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(saveView:)];
    self.navigationItem.rightBarButtonItem = self.saveButton;
}


- (void)configurationAgencyContent {
    [LIBRARY_API getAllAgenciesWithComletion:^(NSArray *agencyArray, NSError *error) {
        modelAgencies = [agencyArray mutableCopy];
        agencyArr = [NSMutableArray array];
        cityArr = [NSMutableArray array];
        
        for (AgencyData *object in modelAgencies) {
            [cityArr addObject:object.city_name];
        }
        
        NSOrderedSet *orderedSet_cities = [NSOrderedSet orderedSetWithArray:cityArr];
        cityArr = [NSMutableArray arrayWithArray:[orderedSet_cities array]];
        [cityArr sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        agencyDictionary = [NSMutableDictionary new];
        alpabeticArray = [NSMutableArray new];
        
        for (int i = 0; i < cityArr.count; i++) {
            
            orderAgencyArray = [NSMutableArray array];
            [agencyDictionary setValue:orderAgencyArray forKey:cityArr[i]];
            [alpabeticArray addObject:[cityArr[i] substringToIndex:1]];
            
            for (AgencyData *object in modelAgencies) {
                if ([object.city_name isEqualToString:cityArr[i]]) {
                    [agencyDictionary[cityArr[i]] addObject:@{@"title":object.title, @"id":@(object.ID)}];
                }
            }
        }
        
        NSOrderedSet *orderedSet_alphabetical = [NSOrderedSet orderedSetWithArray:alpabeticArray];
        alpabeticArray = [NSMutableArray arrayWithArray:[orderedSet_alphabetical array]];
        [alpabeticArray sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        [self.tableView reloadData];
    }];
}

- (void)configurationProfessionContent {
    [LIBRARY_API getAllProfessionsWithComletion:^(NSArray *professionArray, NSError *error) {
        agencyDictionary = @{@"professions": @[].mutableCopy}.mutableCopy;
        cityArr = [NSArray arrayWithObject:@"professions"].mutableCopy;
        
        alpabeticArray = [NSMutableArray new];
        
        for (ProfessionData *object in professionArray) {
            [agencyDictionary[@"professions"] addObject:@{@"title":object.title, @"id":@(object.ID)}];
            
            [alpabeticArray addObject:[object.title substringToIndex:1]];
        }
        
        NSOrderedSet *orderedSet_alphabetical = [NSOrderedSet orderedSetWithArray:alpabeticArray];
        alpabeticArray = [NSMutableArray arrayWithArray:[orderedSet_alphabetical array]];
        [alpabeticArray sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        [self.tableView reloadData];
    }];
}

- (IBAction)saveView:(id)sender {
    [self performSegueWithIdentifier:@"unwindChooseRole" sender:self];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return agencyDictionary.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [agencyDictionary[cityArr[section]] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return alpabeticArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedAgency = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    self.selectedCity = [self tableView:tableView titleForHeaderInSection:indexPath.section];
    self.selectedAgencyId = [tableView cellForRowAtIndexPath:indexPath].tag;
    [[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
}


#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:cityArr[section] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue-Light" size:16], NSFontAttributeName, nil]];
    return [attr string];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.textLabel.text = [[agencyDictionary[cityArr[indexPath.section]] objectAtIndex:indexPath.row] objectForKey:@"title"];
    cell.tag = [[[agencyDictionary[cityArr[indexPath.section]] objectAtIndex:indexPath.row] objectForKey:@"id"] integerValue];
    return cell;
}

@end

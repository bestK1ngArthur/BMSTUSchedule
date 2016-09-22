//
//  DayViewController.m
//  BMSTU Schedule
//
//  Created by Artem Belkov on 10/02/16.
//  Copyright © 2016 Artem Belkov. All rights reserved.
//

#import "TodayViewController.h"

#import "BMSTULibrary.h"

#import "UniversityClassCell.h"
#import "UniversityNoClassCell.h"

@interface TodayViewController ()

@property (strong, nonatomic) BADUniversityGroup *currentGroup;

@property (strong, nonatomic) BADUniversityDay *currentDay;
@property (assign, nonatomic) NSInteger weekNumber;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Getting week number
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    self.weekNumber = 0;
    
    [[BADDownloader sharedDownloader]
     getWeekNumberWithSuccess:^(NSInteger weekNumber) {
         
         self.weekNumber = weekNumber;
         
     }
     failure:^(NSError *error) {
         
         self.weekNumber = 0;
         
     }];
    
    // Adding cells

    UINib *nib = [UINib nibWithNibName:@"UniversityClassCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"UniversityClassCell"];
    
    UINib *nibNoClassCell = [UINib nibWithNibName:@"UniversityNoClassCell" bundle:nil];
    [self.tableView registerNib:nibNoClassCell forCellReuseIdentifier:@"UniversityNoClassCell"];
    
    // Getting group
    
    NSString *fullTitle = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentGroup"];
    self.currentGroup = [[BADUniversityGroup alloc] initWithString:fullTitle];
    
    // Getting schedule
    
    [[BADDownloader sharedDownloader] getScheduleForGroup:self.currentGroup
                                                     success:^(BADUniversitySchedule *schedule) {
                                                         
                                                         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                         
                                                         BADHandler *handler = [[BADHandler alloc] init];
                                                         BADUniversitySchedule *currentSchedule = [handler handleSchedule:schedule];
                                                         
                                                         NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                                                         NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
                                                         NSInteger weekday = [comps weekday];
                                                         
                                                         if (weekday == 1) {
                                                             weekday = 6;
                                                         } else {
                                                             weekday -= 2;
                                                         }
                                                         
                                                         if ([currentSchedule.oddWeek count] > weekday) {
                                                             
                                                             if ([currentSchedule.oddWeek objectAtIndex:weekday]) {
                                                                 
                                                                 if (self.weekNumber == 0) {            // No week
                                                                     
                                                                 } else if (self.weekNumber % 2 == 0) { // Even week
                                                                     
                                                                     self.currentDay = [currentSchedule.evenWeek objectAtIndex:weekday];
                                                                     
                                                                     
                                                                 } else {                               // Odd week
                                                                     
                                                                     self.currentDay = [currentSchedule.oddWeek objectAtIndex:weekday];
                                                                     
                                                                     
                                                                 }
                                                                 
                                                                 self.navigationItem.title = self.currentDay.title;
                                                                 
                                                             }
                                                             
                                                         }
                                                         
                                                         [self.tableView reloadData];
                                                         
                                                     }
                                                     failure:^(NSError *error) {
                                                         
                                                         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                         
                                                         NSLog(@"Loading error!");
                                                         
                                                     }];
    
    self.tableView.tableFooterView = [[UIView alloc] init]; // Removing extra separators
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    NSString *fullTitle = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentGroup"];
    BADUniversityGroup *group = [[BADUniversityGroup alloc] initWithString:fullTitle];
    
    if (![[group fullTitle] isEqualToString:[self.currentGroup fullTitle]]) {
        
        [self viewDidLoad];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.currentDay.classes count] == 0) {
        
        return 200;
        
    } else {
        
        BADUniversityClass *class = [self.currentDay.classes objectAtIndex:indexPath.row];
        
        return [UniversityClassCell heightForText:class.title];
        
    }
    
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *testAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Добавить" handler:^(UITableViewRowAction *testAction, NSIndexPath *indexPath){

        UIAlertView *notificationAlert = [[UIAlertView alloc] initWithTitle:@"Уведомление"
                                                                    message:@"Пиздец какое клёвое уведомление"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ладненько"
                                                          otherButtonTitles:nil, nil];
        
        [notificationAlert show];
        
        [self.tableView setEditing:NO];
        
    }];
    
    testAction.backgroundColor = [UIColor colorWithRed:  77 / 255.f
                                                 green: 179 / 255.f
                                                  blue: 214 / 255.f
                                                 alpha: 1.f];
    
    return @[testAction];
}


#pragma mark - UITableViewDataSource

/*
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [self.currentDay title];
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    #warning Fix current day
    
    if ([self.currentDay.classes count] == 0) {
        
        self.navigationItem.title = @"Воскресенье";
        
        return 1;
        
    } else {

        return [self.currentDay.classes count];

    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.currentDay.classes count] == 0) {
        
        UniversityNoClassCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UniversityNoClassCell" forIndexPath:indexPath];
        
        return cell;
        
    } else {
        
        UniversityClassCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UniversityClassCell" forIndexPath:indexPath];
        
        BADUniversityClass *class = [self.currentDay.classes objectAtIndex:indexPath.row];
        
        cell.classTitleLabel.text = class.title;
        cell.classTypeLabel.text = [BADUniversityClass stringFromType:class.type];
        cell.classRoomLabel.text = class.room;
        cell.classTeacherLabel.text = class.teacher;
        
        cell.beginTimeLabel.text = class.startTime;
        cell.endTimeLabel.text = class.endTime;
        
        return cell;
        
    }
    
}


@end

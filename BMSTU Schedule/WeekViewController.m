//
//  FirstViewController.m
//  BMSTU Schedule
//
//  Created by Artem Belkov on 30/12/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import "WeekViewController.h"

#import "UniversityClassCell.h"
#import "UniversityNoClassCell.h"

#import "BADUniversityGroup.h"
#import "BADUniversityDepartment.h"
#import "BADUniversityFaculty.h"

#import "BADUniversitySchedule.h"
#import "BADUniversityDay.h"
#import "BADUniversityClass.h"

#import "BADDownloader.h"
#import "BADHandler.h"

@interface WeekViewController ()

@property (strong, nonatomic) BADUniversityGroup *currentGroup;

@property (strong, nonatomic) BADUniversitySchedule *currentSchedule;
@property (assign, nonatomic) NSInteger weekNumber;

@end

@implementation WeekViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Getting week number
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    self.weekNumber = 0;
    
    [[BADDownloader sharedDownloader]
     getWeekNumberWithSuccess:^(NSInteger weekNumber) {
         
         self.weekNumber = weekNumber;
         
         self.navigationItem.title = [[NSString stringWithFormat:@"%ld", weekNumber] stringByAppendingString:@" неделя"];
         
     }
     failure:^(NSError *error) {
         
         self.weekNumber = 0;
         
     }];
    
    // Adding cells
    
    UINib *nibClassCell = [UINib nibWithNibName:@"UniversityClassCell" bundle:nil];
    [self.tableView registerNib:nibClassCell forCellReuseIdentifier:@"UniversityClassCell"];
    
    UINib *nibNoClassCell = [UINib nibWithNibName:@"UniversityNoClassCell" bundle:nil];
    [self.tableView registerNib:nibNoClassCell forCellReuseIdentifier:@"UniversityNoClassCell"];
    
    // Getting group
    
    NSString *fullTitle = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentGroup"];
    self.currentGroup = [[BADUniversityGroup alloc] initWithString:fullTitle];
    
    // Getting schedule
    
    [[BADDownloader sharedDownloader] getScheduleForGroup:self.currentGroup
                                                     success:^(BADUniversitySchedule *schedule) {
                                                         
                                                         BADHandler *handler = [[BADHandler alloc] init];
                                                         self.currentSchedule = [handler handleSchedule:schedule];
                                                         
                                                         [self.tableView reloadData];
                                                         
                                                         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                                                                                  
                                                     }
                                                     failure:^(NSError *error) {
                                                         
                                                         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                         
                                                         NSLog(@"Loading error!");
                                                         
                                                     }];
    
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
    
    BADUniversityClass *class;
    
    if (self.weekNumber == 0) {            // No week
        
        return 0;
        
    } else if (self.weekNumber % 2 == 0) { // Even week
        
        if ([[[self.currentSchedule.evenWeek objectAtIndex:indexPath.section] classes] count] == 0) {
            
            //UniversityNoClassCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UniversityNoClassCell" forIndexPath:indexPath];
            
            return 200;//CGRectGetHeight(cell.frame);
            
        } else {
            
            class = [[[self.currentSchedule.evenWeek objectAtIndex:indexPath.section] classes] objectAtIndex:indexPath.row];
            
            return [UniversityClassCell heightForText:class.title];
            
        }
        
    } else {                               // Odd week
        
        if ([[[self.currentSchedule.oddWeek objectAtIndex:indexPath.section] classes] count] == 0) {
            
            //UniversityNoClassCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UniversityNoClassCell" forIndexPath:indexPath];
            
            return 200;//CGRectGetHeight(cell.frame);
            
        } else {
            
            class = [[[self.currentSchedule.oddWeek objectAtIndex:indexPath.section] classes] objectAtIndex:indexPath.row];
            
            return [UniversityClassCell heightForText:class.title];
            
        }

        
    }
    
}

#pragma mark - UITableViewDataSource

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (self.weekNumber == 0) {            // No week
        
        return @"";
        
    } else if (self.weekNumber % 2 == 0) { // Even week
        
        if ([[[self.currentSchedule.evenWeek objectAtIndex:section] classes] count] == 0) {
            return [[self.currentSchedule.evenWeek objectAtIndex:section] title];
        } else {
            return [[self.currentSchedule.evenWeek objectAtIndex:section] title];
        }
        
    } else {                               // Odd week
        
        if ([[[self.currentSchedule.oddWeek objectAtIndex:section] classes] count] == 0) {
            return [[self.currentSchedule.oddWeek objectAtIndex:section] title];
        } else {
            return [[self.currentSchedule.oddWeek objectAtIndex:section] title];
        }
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.weekNumber == 0) {            // No week
        
        return 0;
        
    } else if (self.weekNumber % 2 == 0) { // Even week
        
        return [self.currentSchedule.evenWeek count];
        
    } else {                               // Odd week
        
        return [self.currentSchedule.oddWeek count];
        
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.weekNumber == 0) {            // No week
        
        return 0;
        
    } else if (self.weekNumber % 2 == 0) { // Even week
        
        if ([[[self.currentSchedule.evenWeek objectAtIndex:section] classes] count] == 0) {
            return 1;
        } else {
            return [[[self.currentSchedule.evenWeek objectAtIndex:section] classes] count];
        }
        
        
    } else {                               // Odd week
        
        if ([[[self.currentSchedule.oddWeek objectAtIndex:section] classes] count] == 0) {
            return 1;
        } else {
            return [[[self.currentSchedule.oddWeek objectAtIndex:section] classes] count];
        }
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.weekNumber == 0) {            // No week
        
        return nil;
        
    } else if (self.weekNumber % 2 == 0) { // Even week
        
        if ([[[self.currentSchedule.evenWeek objectAtIndex:indexPath.section] classes] count] == 0) {
            
            UniversityNoClassCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UniversityNoClassCell" forIndexPath:indexPath];
            
            return cell;
            
        } else {
            
            UniversityClassCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UniversityClassCell" forIndexPath:indexPath];
            
            BADUniversityClass *class = [[[self.currentSchedule.evenWeek objectAtIndex:indexPath.section] classes] objectAtIndex:indexPath.row];
            
            cell.classTitleLabel.text = class.title;
            cell.classTypeLabel.text = [BADUniversityClass stringFromType:class.type];
            cell.classRoomLabel.text = class.room;
            cell.classTeacherLabel.text = class.teacher;
            
            cell.beginTimeLabel.text = class.startTime;
            cell.endTimeLabel.text = class.endTime;
            
            return cell;
            
        }
        
    } else {                               // Odd week
        
        if ([[[self.currentSchedule.oddWeek objectAtIndex:indexPath.section] classes] count] == 0) {
            
            UniversityNoClassCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UniversityNoClassCell" forIndexPath:indexPath];
            
            return cell;
            
        } else {
            
            UniversityClassCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UniversityClassCell" forIndexPath:indexPath];
            
            BADUniversityClass *class = [[[self.currentSchedule.oddWeek objectAtIndex:indexPath.section] classes] objectAtIndex:indexPath.row];
            
            cell.classTitleLabel.text = class.title;
            cell.classTypeLabel.text = [BADUniversityClass stringFromType:class.type];
            cell.classRoomLabel.text = class.room;
            cell.classTeacherLabel.text = class.teacher;
            
            cell.beginTimeLabel.text = class.startTime;
            cell.endTimeLabel.text = class.endTime;
            
            return cell;
            
        }
        
    }
    
}

@end

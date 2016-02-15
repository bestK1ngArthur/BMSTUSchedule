//
//  FirstViewController.m
//  BMSTU Schedule
//
//  Created by Artem Belkov on 30/12/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import "WeekViewController.h"

#import "UniversityClassCell.h"

#import "BADUniversityGroup.h"
#import "BADUniversityDepartment.h"
#import "BADUniversityFaculty.h"

#import "BADUniversitySchedule.h"
#import "BADUniversityDay.h"
#import "BADUniversityClass.h"

#import "BADDownloader.h"
#import "BADHandler.h"

@interface WeekViewController ()

@property (strong, nonatomic) BADUniversitySchedule *currentSchedule;
@property (assign, nonatomic) NSInteger weekNumber;

@end

@implementation WeekViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Getting week number
    
    self.weekNumber = 0;
    
    [[BADDownloader sharedDownloader]
     getWeekNumberOnSuccess:^(NSInteger weekNumber) {
         
         self.weekNumber = weekNumber;
         
         self.navigationItem.title = [[NSString stringWithFormat:@"%ld", weekNumber] stringByAppendingString:@" неделя"];
         
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
         self.weekNumber = 0;
         
     }];
    
    // Adding cells
    
    UINib *nib = [UINib nibWithNibName:@"UniversityClassCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"UniversityClassCell"];
    
    // Getting schedule
    
    BADUniversityFaculty *faculty = [[BADUniversityFaculty alloc] initWithName:@"Факультет информатики и систем управления"
                                                                     shortName:@"ИУ"];
    BADUniversityDepartment *department = [[BADUniversityDepartment alloc] initWithName:@"Кафедра систем обработки информации и управления"
                                                                                 number:5
                                                                                faculty:faculty];
    BADUniversityGroup *group = [[BADUniversityGroup alloc] initWithDepartment:department number:23];
    
    [[BADDownloader sharedDownloader] getScheduleForGroup:group
                                                     onSuccess:^(BADUniversitySchedule *schedule) {
                                                         
                                                         BADHandler *handler = [[BADHandler alloc] init];
                                                         self.currentSchedule = [handler handleSchedule:schedule];
                                                         
                                                         [self.tableView reloadData];
                                                                                                                  
                                                     }
                                                     onFailure:^(NSError *error, NSInteger statusCode) {
                                                         
                                                         NSLog(@"Loading error!");
                                                         
                                                     }];
    
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
        
        class = [[[self.currentSchedule.evenWeek objectAtIndex:indexPath.section] classes] objectAtIndex:indexPath.row];
        
    } else {                               // Odd week
        
        class = [[[self.currentSchedule.oddWeek objectAtIndex:indexPath.section] classes] objectAtIndex:indexPath.row];
        
    }
    
    return [UniversityClassCell heightForText:class.title];
}

#pragma mark - UITableViewDataSource

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (self.weekNumber == 0) {            // No week
        
        return @"";
        
    } else if (self.weekNumber % 2 == 0) { // Even week
        
        if ([[[self.currentSchedule.evenWeek objectAtIndex:section] classes] count] == 0) {
            return [[[self.currentSchedule.evenWeek objectAtIndex:section] title] stringByAppendingString:@" - нет занятий"];
        } else {
            return [[self.currentSchedule.evenWeek objectAtIndex:section] title];
        }
        
    } else {                               // Odd week
        
        if ([[[self.currentSchedule.evenWeek objectAtIndex:section] classes] count] == 0) {
            return [[[self.currentSchedule.oddWeek objectAtIndex:section] title] stringByAppendingString:@" - нет занятий"];
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
        
        return [[[self.currentSchedule.evenWeek objectAtIndex:section] classes] count];
        
    } else {                               // Odd week
        
        return [[[self.currentSchedule.oddWeek objectAtIndex:section] classes] count];
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UniversityClassCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UniversityClassCell" forIndexPath:indexPath];
    
    BADUniversityClass *class;
    
    if (self.weekNumber == 0) {            // No week
        
        return nil;
        
    } else if (self.weekNumber % 2 == 0) { // Even week
        
        class = [[[self.currentSchedule.evenWeek objectAtIndex:indexPath.section] classes] objectAtIndex:indexPath.row];
        
    } else {                               // Odd week
        
        class = [[[self.currentSchedule.oddWeek objectAtIndex:indexPath.section] classes] objectAtIndex:indexPath.row];
        
    }
    
    cell.classTitleLabel.text = class.title;
    cell.classTypeLabel.text = [BADUniversityClass stringFromType:class.type];
    cell.classRoomLabel.text = class.room;
    cell.classTeacherLabel.text = class.teacher;
    
    cell.beginTimeLabel.text = class.startTime;
    cell.endTimeLabel.text = class.endTime;
    
    return cell;
    
}

@end

//
//  DayViewController.m
//  BMSTU Schedule
//
//  Created by Artem Belkov on 10/02/16.
//  Copyright © 2016 Artem Belkov. All rights reserved.
//

#import "TodayViewController.h"

#import "UniversityClassCell.h"

#import "BADUniversityGroup.h"
#import "BADUniversityDepartment.h"
#import "BADUniversityFaculty.h"

#import "BADUniversitySchedule.h"
#import "BADUniversityDay.h"
#import "BADUniversityClass.h"

#import "BADDownloader.h"
#import "BADHandler.h"

@interface TodayViewController ()

@property (strong, nonatomic) BADUniversityDay *currentDay;


@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"UniversityClassCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"UniversityClassCell"];
    
    BADUniversityFaculty *faculty = [[BADUniversityFaculty alloc] initWithName:@"Факультет информатики и систем управления"
                                                                     shortName:@"ИУ"];
    BADUniversityDepartment *department = [[BADUniversityDepartment alloc] initWithName:@"Кафедра систем обработки информации и управления"
                                                                                 number:5
                                                                                faculty:faculty];
    BADUniversityGroup *group = [[BADUniversityGroup alloc] initWithDepartment:department number:23];
    
    [[BADDownloader sharedDownloader] downloadScheduleForGroup:group
                                                     onSuccess:^(BADUniversitySchedule *schedule) {
                                                         
                                                         BADHandler *handler = [[BADHandler alloc] init];
                                                         BADUniversitySchedule *currentSchedule = [handler handleSchedule:schedule];
                                                         
                                                         NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                                                         NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
                                                         NSInteger weekday = [comps weekday];
                                                         
                                                         if ([currentSchedule.oddWeek objectAtIndex:(weekday - 2)]) {
                                                             self.currentDay = [currentSchedule.oddWeek objectAtIndex:(weekday - 2)];
                                                         }
                                                         
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


#pragma mark - UITableViewDataSource

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [self.currentDay title];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.currentDay.classes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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


@end

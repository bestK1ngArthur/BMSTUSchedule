//
//  FirstViewController.m
//  BMSTU Schedule
//
//  Created by Artem Belkov on 30/12/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import "WeekViewController.h"

#import "BMSTULibrary.h"

#import "UniversityClassCell.h"
#import "UniversityNoClassCell.h"

@interface WeekViewController ()

@property (strong, nonatomic) BADUniversityGroup *currentGroup;

@property (strong, nonatomic) BADUniversitySchedule *currentSchedule;
@property (assign, nonatomic) NSInteger weekNumber;

@end

@implementation WeekViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add tabBar
    
    /*
    MDTabBar *tabBar = [[MDTabBar alloc] initWithFrame:CGRectMake(0, 200, 320, 100)];
    [tabBar setItems:@[ @"TAB ONE", @"THE NEXT TAB" ]];
    tabBar.delegate = self;
    tabBar.selectedIndex = 1;
    [self.view addSubview:tabBar];
        */
     
    // Get general information
    
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
    
    [[BADDownloader sharedDownloader]
     getWeekTypeWithSuccess:^(NSString *weekType) {
         
         self.navigationItem.title = [NSString stringWithFormat:@"%@ (%@)", self.navigationItem.title, weekType];
         
     }
     failure:^(NSError *error) {
         
         // Error
         
     }];
    
    
    // Add cells
    
    UINib *nibClassCell = [UINib nibWithNibName:@"UniversityClassCell" bundle:nil];
    [self.tableView registerNib:nibClassCell forCellReuseIdentifier:@"UniversityClassCell"];
    
    UINib *nibNoClassCell = [UINib nibWithNibName:@"UniversityNoClassCell" bundle:nil];
    [self.tableView registerNib:nibNoClassCell forCellReuseIdentifier:@"UniversityNoClassCell"];
    
    [self loadScheduleDate];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    // Check if need to update
    
    NSString *fullTitle = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentGroup"];
    BADUniversityGroup *group = [[BADUniversityGroup alloc] initWithString:fullTitle];
    
    if (![[group fullTitle] isEqualToString:[self.currentGroup fullTitle]]) {
        
        [self viewDidLoad];
        
    }
    
}

- (void)loadScheduleDate {
    
    // Get group
    
    NSString *fullTitle = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentGroup"];
    self.currentGroup = [[BADUniversityGroup alloc] initWithString:fullTitle];
    
    // Get schedule
    
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

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BADUniversityClass *class;
    
    if (self.weekNumber == 0) {
        
        // No week
        
        return 0;
        
    } else if (self.weekNumber % 2 == 0) {
        
        // Even week
        
        if ([[[self.currentSchedule.evenWeek objectAtIndex:indexPath.section] classes] count] == 0) {
            
            //UniversityNoClassCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UniversityNoClassCell" forIndexPath:indexPath];
            
            return 200; //CGRectGetHeight(cell.frame);
            
        } else {
            
            class = [[[self.currentSchedule.evenWeek objectAtIndex:indexPath.section] classes] objectAtIndex:indexPath.row];
            
            return [UniversityClassCell heightForText:class.title];
            
        }
        
    } else {
        
        // Odd week
        
        if ([[[self.currentSchedule.oddWeek objectAtIndex:indexPath.section] classes] count] == 0) {
            
            // WTF??
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
    
    if (self.weekNumber == 0) {
        
        // No week
        
        return @"";
        
    } else if (self.weekNumber % 2 == 0) {
        
        // Even week
        
        if ([[[self.currentSchedule.evenWeek objectAtIndex:section] classes] count] == 0) {
            return [[self.currentSchedule.evenWeek objectAtIndex:section] title];
        } else {
            return [[self.currentSchedule.evenWeek objectAtIndex:section] title];
        }
        
    } else {
        
        // Odd week
        
        if ([[[self.currentSchedule.oddWeek objectAtIndex:section] classes] count] == 0) {
            return [[self.currentSchedule.oddWeek objectAtIndex:section] title];
        } else {
            return [[self.currentSchedule.oddWeek objectAtIndex:section] title];
        }
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.weekNumber == 0) {
        
        // No week
        
        return 0;
        
    } else if (self.weekNumber % 2 == 0) {
        
        // Even week
        
        return [self.currentSchedule.evenWeek count];
        
    } else {
        
        // Odd week
        
        return [self.currentSchedule.oddWeek count];
        
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.weekNumber == 0) {
        
        // No week
        
        return 0;
        
    } else if (self.weekNumber % 2 == 0) {
        
        // Even week
        
        if ([[[self.currentSchedule.evenWeek objectAtIndex:section] classes] count] == 0) {
            return 1;
        } else {
            return [[[self.currentSchedule.evenWeek objectAtIndex:section] classes] count];
        }
        
        
    } else {
        
        // Odd week
        
        if ([[[self.currentSchedule.oddWeek objectAtIndex:section] classes] count] == 0) {
            return 1;
        } else {
            return [[[self.currentSchedule.oddWeek objectAtIndex:section] classes] count];
        }
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.weekNumber == 0) {
        
        // No week
        
        return nil;
        
    } else if (self.weekNumber % 2 == 0) {
        
        // Even week
        
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
        
    } else {
        
        // Odd week
        
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

#pragma mark - Memory

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
}

@end

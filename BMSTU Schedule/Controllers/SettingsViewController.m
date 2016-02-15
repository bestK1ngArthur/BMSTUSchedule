//
//  SettingsViewController.m
//  BMSTU Schedule
//
//  Created by Artem Belkov on 15/02/16.
//  Copyright © 2016 Artem Belkov. All rights reserved.
//

#import "SettingsViewController.h"

#import "BADUniversityFaculty.h"
#import "BADUniversityDepartment.h"
#import "BADUniversityGroup.h"

#import "BADDownloader.h"

typedef enum {
    GroupPickerComponentTypeFaculty    = 0,
    GroupPickerComponentTypeDepartment = 1,
    GroupPickerComponentTypeGroup      = 2
} GroupPickerComponentType;

@interface SettingsViewController ()

@property (strong, nonatomic) NSArray *listOfFaculties;
@property (strong, nonatomic) NSArray *listOfDepartments;
@property (strong, nonatomic) NSArray *listOfGroups;

@property (strong, nonatomic) BADUniversityFaculty *selectedFaculty;
@property (strong, nonatomic) BADUniversityDepartment *selectedDepartment;
@property (strong, nonatomic) BADUniversityGroup *selectedGroup;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[BADDownloader sharedDownloader] getListOfFacultiesOnSuccess:^(NSArray *faculties) {
        
        [[BADDownloader sharedDownloader] getListOfDepartmentsForFaculty:[faculties objectAtIndex:0]
                                                               onSuccess:^(NSArray *faculties) {
                                                                   
                                                               }
                                                               onFailure:^(NSError *error, NSInteger statusCode) {
                                                                   
                                                               }];
        
    }
    onFailure:^(NSError *error, NSInteger statusCode) {
                                                            
    
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPickerViewDataSource

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
    if (component == GroupPickerComponentTypeFaculty) { // If faculty component
        
        if (self.listOfFaculties.count > 0) {
            
            return self.listOfFaculties.count;
            
        }
        
    } else if (component == GroupPickerComponentTypeDepartment) { // If department component
        
        if (self.listOfDepartments.count > 0) {
            
            return self.listOfDepartments.count;
            
        }
        
    } else if (component == GroupPickerComponentTypeGroup) { // If group component
        
        if (self.listOfGroups.count > 0) {
            
            return self.listOfGroups.count;
            
        }
        
    }
    
    return 0;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if (component == GroupPickerComponentTypeFaculty) { // If faculty component
        
        if (self.listOfFaculties.count > 0) {
            
            return [[self.listOfFaculties objectAtIndex:row] shortName];
            
        }
        
    } else if (component == GroupPickerComponentTypeDepartment) { // If department component
        
        if (self.listOfDepartments.count > 0) {
            
            return [[self.listOfDepartments objectAtIndex:row] shortName];
            
        }
        
    } else if (component == GroupPickerComponentTypeGroup) { // If group component
        
        if (self.listOfGroups.count > 0) {
            
            return [[NSString alloc] initWithFormat:@"%ld", (long)[[self.listOfGroups objectAtIndex:row] number]];
            
        }
        
    }
    
    return nil;
}

/*
// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == GroupPickerComponentTypeFaculty) { // If touch faculty component
        
        if (self.listOfFaculties.count > 0) {
            
            self.selectedFaculty = [self.listOfFaculties objectAtIndex:row];
            
            [self.selectedFaculty loadListOfDepartmentsOnSuccess:^(NSArray *listOfDepartments) {
                
                self.listOfDepartments = listOfDepartments;
                
                [pickerView reloadAllComponents];
                
                NSString *groupString = [[NSUserDefaults standardUserDefaults] objectForKey:@"ScheduleCurrentGroup"];
                BADUniversityGroup *group = [[BADUniversityGroup alloc] initWithString:groupString];
                
                BOOL isFound = false;
                
                for (BADUniversityDepartment *department in self.listOfDepartments) {
                    
                    if ([department.shortName isEqualToString:group.department.shortName]) {
                        
                        isFound = true;
                        
                        [pickerView selectRow:[self.listOfDepartments indexOfObject:department]
                                  inComponent:GroupPickerComponentTypeDepartment animated:true];
                        [self pickerView:pickerView
                            didSelectRow:[self.listOfDepartments indexOfObject:department]
                             inComponent:GroupPickerComponentTypeDepartment];
                        
                    }
                    
                }
                
                if (!isFound) {
                    
                    [pickerView selectRow:0 inComponent:GroupPickerComponentTypeDepartment animated:true];
                    [self pickerView:pickerView didSelectRow:0 inComponent:GroupPickerComponentTypeDepartment];
                    
                }
                
            } onFailure:^(NSError *error, NSInteger statusCode) {
                
            }]; // Load departments for faculty
            
        }
        
    } else if (component == GroupPickerComponentTypeDepartment) { // If touch department component
        
        if (self.listOfDepartments.count > 0) {
            
            self.selectedDepartment = [self.listOfDepartments objectAtIndex:row];
            [self.selectedDepartment loadListOfGroupsOnSuccess:^(NSArray *listOfGroups) {
                
                self.listOfGroups = listOfGroups;
                
                [pickerView reloadAllComponents];
                
                NSString *groupString = [[NSUserDefaults standardUserDefaults] objectForKey:@"ScheduleCurrentGroup"];
                BADUniversityGroup *group = [[BADUniversityGroup alloc] initWithString:groupString];
                
                BOOL isFound = false;
                
                for (BADUniversityGroup *nowGroup in self.listOfGroups) {
                    
                    if ([[nowGroup getFullNumber] isEqualToString:[group getFullNumber]]) {
                        
                        isFound = true;
                        
                        [pickerView selectRow:[listOfGroups indexOfObject:nowGroup]
                                  inComponent:GroupPickerComponentTypeGroup animated:true];
                        [self pickerView:pickerView didSelectRow:[listOfGroups indexOfObject:nowGroup]
                             inComponent:GroupPickerComponentTypeGroup];
                        
                    }
                    
                }
                
                if (!isFound) {
                    
                    [pickerView selectRow:0 inComponent:GroupPickerComponentTypeGroup animated:true];
                    [self pickerView:pickerView didSelectRow:0 inComponent:GroupPickerComponentTypeGroup];
                    
                }
                
            } onFailure:^(NSError *error, NSInteger statusCode) {
                
            }]; // Load groups for department
            
        }
        
    } else if (component == GroupPickerComponentTypeGroup) { // If touch group component
        
        if (self.listOfGroups.count > 0) {
            
            self.selectedGroup = [self.listOfGroups objectAtIndex:row];
            
            [[NSUserDefaults standardUserDefaults] setObject:[self.selectedGroup getFullNumber] forKey:@"ScheduleCurrentGroup"];
            
        }
        
    }
    
}
*/

@end

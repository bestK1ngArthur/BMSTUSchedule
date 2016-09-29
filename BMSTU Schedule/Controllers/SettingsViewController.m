//
//  SettingsViewController.m
//  BMSTU Schedule
//
//  Created by Artem Belkov on 15/02/16.
//  Copyright © 2016 Artem Belkov. All rights reserved.
//

#import "SettingsViewController.h"

#import "BMSTULibrary.h"

typedef enum {
    GroupPickerComponentTypeFaculty    = 0,
    GroupPickerComponentTypeDepartment = 1,
    GroupPickerComponentTypeCourse     = 2,
    GroupPickerComponentTypeGroup      = 3
} GroupPickerComponentType;

@interface SettingsViewController ()

@property (strong, nonatomic) NSArray *faculties;
@property (strong, nonatomic) NSArray *departments;
@property (strong, nonatomic) NSArray *courses;
@property (strong, nonatomic) NSArray *groups;

@property (strong, nonatomic) BADUniversityFaculty *selectedFaculty;
@property (strong, nonatomic) BADUniversityDepartment *selectedDepartment;
@property (assign, nonatomic) NSInteger selectedCourse;
@property (strong, nonatomic) BADUniversityGroup *selectedGroup;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup group picker
    
    self.courses = [NSArray arrayWithObjects:@1, @2, @3, @4, nil];
    
    [[BADDownloader sharedDownloader] getListOfFacultiesWithSuccess:^(NSArray *faculties) {
        
        self.faculties = faculties;
        [self.groupPicker reloadAllComponents];
        
        [self.groupPicker selectRow:0 inComponent:0 animated:true];
        
        NSString *groupString = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentGroup"];
        BADUniversityGroup *group = [[BADUniversityGroup alloc] initWithString:groupString];
        
        for (BADUniversityFaculty *faculty in self.faculties) {
            
            if ([faculty.shortName isEqualToString:group.department.faculty.shortName]) {
                
                [self.groupPicker selectRow:[faculties indexOfObject:faculty] inComponent:GroupPickerComponentTypeFaculty animated:true];
                [self pickerView:self.groupPicker didSelectRow:[faculties indexOfObject:faculty] inComponent:GroupPickerComponentTypeFaculty];
                
            }
        }
        
    } failure:^(NSError *error) {
        
        // Failure to get groups
        
    }];
    
}

#pragma mark - UIPickerViewDataSource

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 4;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (component == GroupPickerComponentTypeFaculty) { // If faculty component
        
        if (self.faculties.count > 0) {
            return self.faculties.count;
        }
        
    } else if (component == GroupPickerComponentTypeDepartment) { // If department component
        
        if (self.departments.count > 0) {
            return self.departments.count;
        }
        
    }else if (component == GroupPickerComponentTypeCourse) { // If course component
        
        if (self.departments.count > 0) {
            return self.courses.count;
        }
        
    } else if (component == GroupPickerComponentTypeGroup) { // If group component
        
        if (self.groups.count > 0) {
            return self.groups.count;
        }
        
    }
    
    return 0;
}

// The data to return for the row and component (column) that's being passed in

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (component == GroupPickerComponentTypeFaculty) { // If faculty component
        
        if (self.faculties.count > 0) {
            return [[self.faculties objectAtIndex:row] shortName];
        }
        
    } else if (component == GroupPickerComponentTypeDepartment) { // If department component
        
        if (self.departments.count > 0) {
            return [[self.departments objectAtIndex:row] shortName];
        }
        
    } else if (component == GroupPickerComponentTypeCourse) { // If course component
        
        if (self.courses.count > 0) {
            return [[NSString alloc] initWithFormat:@"%@", [self.courses objectAtIndex:row]];
        }
        
    } else if (component == GroupPickerComponentTypeGroup) { // If group component
        
        if (self.groups.count > 0) {
            return [[NSString alloc] initWithFormat:@"%ld", (long)[[self.groups objectAtIndex:row] number]];
        }
        
    }
    
    return nil;
}

// Catpure the picker view selection

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == GroupPickerComponentTypeFaculty) { // If touch faculty component
        
        if (self.faculties.count > 0) {
            
            self.selectedFaculty = [self.faculties objectAtIndex:row];
            
            // Load departments for faculty
            
            [[BADDownloader sharedDownloader] getListOfDepartmentsForFaculty:self.selectedFaculty
                                                                   success:^(NSArray *faculties) {
                                                                       
                                                                       self.departments = faculties;
                                                                       
                                                                       [pickerView reloadAllComponents];
                                                                       
                                                                       NSString *groupString = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentGroup"];
                                                                       BADUniversityGroup *group = [[BADUniversityGroup alloc] initWithString:groupString];
                                                                       
                                                                       BOOL isFound = false;
                                                                       
                                                                       for (BADUniversityDepartment *department in self.departments) {
                                                                           
                                                                           if ([department.shortName isEqualToString:group.department.shortName]) {
                                                                               
                                                                               isFound = true;
                                                                               
                                                                               [pickerView selectRow:[self.departments indexOfObject:department]
                                                                                         inComponent:GroupPickerComponentTypeDepartment animated:true];
                                                                               [self pickerView:pickerView
                                                                                   didSelectRow:[self.departments indexOfObject:department]
                                                                                    inComponent:GroupPickerComponentTypeDepartment];
                                                                               
                                                                           }
                                                                           
                                                                       }
                                                                       
                                                                       if (!isFound) {
                                                                           
                                                                           [pickerView selectRow:0 inComponent:GroupPickerComponentTypeDepartment animated:true];
                                                                           [self pickerView:pickerView didSelectRow:0 inComponent:GroupPickerComponentTypeDepartment];
                                                                           
                                                                       }
                                                                       
                                                                   }
                                                                   failure:^(NSError *error) {
                                                                      
                                                                       // Failure to load faculties
                                                                       
                                                                   }];
            
        }
        
    } else if (component == GroupPickerComponentTypeDepartment) { // If touch department component
        
        if (self.departments.count > 0) {
            
            self.selectedDepartment = [self.departments objectAtIndex:row];
            
            [pickerView selectRow:0 inComponent:GroupPickerComponentTypeCourse animated:true];
            [self pickerView:pickerView didSelectRow:0 inComponent:GroupPickerComponentTypeCourse];
            
        }
        
    } else if (component == GroupPickerComponentTypeCourse) { // If touch course component
        
        if (self.courses.count > 0) {
            
            self.selectedCourse = (NSInteger)[self.courses objectAtIndex:row];
            
            // Load groups for department
            
            [[BADDownloader sharedDownloader] getListOfGroupsForDepartment:self.selectedDepartment
                                                                    course:[[self.courses objectAtIndex:row] integerValue]
                                                                 success:^(NSArray *groups) {
                                                                     
                                                                     self.groups = groups;
                                                                     
                                                                     [pickerView reloadAllComponents];
                                                                     
                                                                     NSString *groupString = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentGroup"];
                                                                     BADUniversityGroup *group = [[BADUniversityGroup alloc] initWithString:groupString];
                                                                     
                                                                     BOOL isFound = false;
                                                                     
                                                                     for (BADUniversityGroup *nowGroup in self.groups) {
                                                                         
                                                                         if ([nowGroup.fullTitle isEqualToString:group.fullTitle]) {
                                                                             
                                                                             isFound = true;
                                                                             
                                                                             [pickerView selectRow:[groups indexOfObject:nowGroup]
                                                                                       inComponent:GroupPickerComponentTypeGroup animated:true];
                                                                             [self pickerView:pickerView didSelectRow:[groups indexOfObject:nowGroup]
                                                                                  inComponent:GroupPickerComponentTypeGroup];
                                                                             
                                                                         }
                                                                         
                                                                     }
                                                                     
                                                                     if (!isFound) {
                                                                         
                                                                         [pickerView selectRow:0 inComponent:GroupPickerComponentTypeGroup animated:true];
                                                                         [self pickerView:pickerView didSelectRow:0 inComponent:GroupPickerComponentTypeGroup];
                                                                         
                                                                     }
                                                                     
                                                                 }
                                                                 failure:^(NSError *error) {
                                                                     
                                                                     // Failure to load groups
                                                                     
                                                                 }];
            
        }
        
    } else if (component == GroupPickerComponentTypeGroup) { // If touch group component
        
        if (self.groups.count > 0) {
            self.selectedGroup = [self.groups objectAtIndex:row];
            [[NSUserDefaults standardUserDefaults] setObject:self.selectedGroup.fullTitle forKey:@"CurrentGroup"];
        }
        
    }
    
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
}

@end


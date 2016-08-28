//
//  BADDownloader.h
//  BMSTU Schedule
//
//  Created by Artem Belkov on 31/12/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BADUniversityGroup;
@class BADUniversityDepartment;
@class BADUniversityFaculty;

@class BADUniversitySchedule;

@interface BADDownloader : NSObject

+ (BADDownloader *) sharedDownloader;

#pragma mark - Unknown server

// General information

- (void)getWeekNumberWithSuccess:(void (^)(NSInteger weekNumber))success
                         failure:(void (^)(NSError *error))failure;

// University structure

- (void)getListOfFacultiesWithSuccess:(void (^)(NSArray *faculties))success
                              failure:(void (^)(NSError *error))failure;

- (void)getListOfDepartmentsForFaculty:(BADUniversityFaculty *)faculty
                               success:(void (^)(NSArray *departmens))success
                               failure:(void (^)(NSError *error))failure;

- (void)getListOfGroupsForDepartment:(BADUniversityDepartment *)department
                              course:(NSInteger)course
                             success:(void (^)(NSArray *groups))success
                             failure:(void (^)(NSError *error))failure;

// Schedule

- (void) getScheduleForGroup:(BADUniversityGroup *)group
                     success:(void (^)(BADUniversitySchedule *schedule))success
                     failure:(void (^)(NSError *error))failure;

#pragma mark - Firebase

@end

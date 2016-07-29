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

// General information

- (void)getWeekNumberOnSuccess:(void (^)(NSInteger weekNumber))success
                     onFailure:(void (^)(NSError *error))failure;

// University structure

- (void)getListOfFacultiesOnSuccess:(void (^)(NSArray *faculties))success
                          onFailure:(void (^)(NSError *error))failure;

- (void)getListOfDepartmentsForFaculty:(BADUniversityFaculty *)faculty
                             onSuccess:(void (^)(NSArray *departmens))success
                             onFailure:(void (^)(NSError *error))failure;

- (void)getListOfGroupsForDepartment:(BADUniversityDepartment *)department
                              course:(NSInteger)course
                           onSuccess:(void (^)(NSArray *groups))success
                           onFailure:(void (^)(NSError *error))failure;

// Schedule

- (void) getScheduleForGroup:(BADUniversityGroup *)group
                        onSuccess:(void (^)(BADUniversitySchedule *schedule))success
                        onFailure:(void (^)(NSError *error))failure;

@end

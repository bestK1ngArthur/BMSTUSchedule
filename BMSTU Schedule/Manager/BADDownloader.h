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

- (void)getWeekNumberOnSuccess:(void (^)(NSInteger weekNumber))success
                     onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)getListOfFacultiesOnSuccess:(void (^)(NSArray *faculties))success
                          onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void)getListOfDepartmentsForFaculty:(BADUniversityFaculty *)faculty
                             onSuccess:(void (^)(NSArray *faculties))success
                             onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

- (void) getScheduleForGroup:(BADUniversityGroup *)group
                        onSuccess:(void (^)(BADUniversitySchedule *schedule))success
                        onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

@end

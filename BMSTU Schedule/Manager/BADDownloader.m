//
//  BADDownloader.m
//  BMSTU Schedule
//
//  Created by Artem Belkov on 31/12/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import "BADDownloader.h"

#import "AFNetworking.h"
#import "TFHpple.h"

#import "BADUniversityGroup.h"
#import "BADUniversityDepartment.h"
#import "BADUniversityFaculty.h"

#import "BADUniversitySchedule.h"
#import "BADUniversityDay.h"
#import "BADUniversityClass.h"

#warning Fix bug with commits

@interface BADDownloader ()

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;

@property (strong, nonatomic) NSDictionary *daysTitlesDictionary;

@end

@implementation BADDownloader

+ (BADDownloader *) sharedDownloader {
    
    static BADDownloader *downloader = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        downloader = [[BADDownloader alloc] init];
    
        downloader.daysTitlesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           @"Понедельник", @"monday",
                                           @"Вторник", @"tuesday",
                                           @"Среда", @"wednesday",
                                           @"Четверг", @"thursday",
                                           @"Пятница", @"friday",
                                           @"Суббота", @"saturday", nil];
    
    });
    
    return downloader;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSURL *url = [NSURL URLWithString:@"http://raspisanie.bmstu.ru:8088/api/"];
        
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
        
    }
    return self;
}

- (BOOL)isNull:(id)object {

    return object == [NSNull null];
}

#pragma mark - General information

- (void)getWeekNumberWithSuccess:(void (^)(NSInteger weekNumber))success
                     failure:(void (^)(NSError *error))failure {
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    [self.sessionManager setResponseSerializer:responseSerializer];
    
    [self.sessionManager GET:@"semester/get/now/weeknumber"
                  parameters:nil
                    progress:^(NSProgress * _Nonnull downloadProgress) {}
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         
                         NSInteger weekNumber = [responseObject integerValue];
                         
                         if (success) {
                             success(weekNumber);
                         }
                         
                     }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         
                         NSLog(@"Error(getWekNumber): %@", error);
                         
                         if (failure) {
                             failure(error);
                         }
                         
                     }];

}

#pragma mark - University structure

- (void)getListOfFacultiesWithSuccess:(void (^)(NSArray *faculties))success
                          failure:(void (^)(NSError *error))failure {
    
    [self.sessionManager GET:@"faculties/get/now/all"
                  parameters:nil
                    progress:^(NSProgress * _Nonnull downloadProgress) {}
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         
                         NSMutableArray *faculties = [NSMutableArray array];
                         
                         for (NSString *shortName in responseObject) {
                             
                             BADUniversityFaculty *faculty = [[BADUniversityFaculty alloc] initWithName:@""
                                                                                              shortName:shortName];
                             
                             [faculties addObject:faculty];
                             
                         }
                         
                         if (success) {
                             success(faculties);
                         }
                         
                     }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         
                         NSLog(@"Error(getWekNumber): %@", error);
                         
                         if (failure) {
                             failure(error);
                         }
                         
                     }];
 
}

- (void)getListOfDepartmentsForFaculty:(BADUniversityFaculty *)faculty
                             success:(void (^)(NSArray *faculties))success
                             failure:(void (^)(NSError *error))failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            faculty.shortName, @"faculty", nil];
    
    [self.sessionManager GET:@"departments/get/now/param"
                  parameters:params
                    progress:^(NSProgress * _Nonnull downloadProgress) {}
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         
                         NSMutableArray *departments = [NSMutableArray array];
                         
                         for (NSNumber *number in responseObject) {
                             
                             BADUniversityDepartment *department = [[BADUniversityDepartment alloc] initWithName:@""
                                                                                                          number:[number integerValue]
                                                                                                         faculty:faculty];
                             
                             [departments addObject:department];
                             
                             departments = [NSMutableArray arrayWithArray:[departments sortedArrayUsingComparator:^NSComparisonResult(BADUniversityFaculty*  _Nonnull department1, BADUniversityFaculty*  _Nonnull department2) {
                                 
                                 NSInteger number1 = [[[department1.shortName componentsSeparatedByCharactersInSet:
                                                        [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""] integerValue];
                                 
                                 NSInteger number2 = [[[department2.shortName componentsSeparatedByCharactersInSet:
                                                        [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""] integerValue];
                                 
                                 if (number1 < number2) {
                                     
                                     return NSOrderedAscending;
                                     
                                 } else {
                                     
                                     return NSOrderedDescending;
                                     
                                 }
                                 
                             }]];
                             
                         }
                         
                         if (success) {
                             success(departments);
                         }
                         
                     }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         
                         NSLog(@"Error(getListOfDepartments): %@", error);
                         
                         if (failure) {
                             failure(error);
                         }
                         
                     }];
    
}

- (void)getListOfGroupsForDepartment:(BADUniversityDepartment *)department
                              course:(NSInteger)course
                           success:(void (^)(NSArray *groups))success
                           failure:(void (^)(NSError *error))failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            department.faculty.shortName, @"faculty",
                            @(department.number), @"department",
                            @(course), @"course", nil];
    
    [self.sessionManager GET:@"studygroup/get/now/param"
                  parameters:params
                    progress:^(NSProgress * _Nonnull downloadProgress) {}
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         
                         NSMutableArray *groups = [NSMutableArray array];
                         
                         for (NSString *string in responseObject) {
                             
                             NSInteger number = [[[string componentsSeparatedByString:@"-"] objectAtIndex:1] integerValue];
                             
                             BADUniversityGroup *group = [[BADUniversityGroup alloc] initWithDepartment:department
                                                                                                 number:number];
                             
                             [groups addObject:group];
                             
                         }
                         
                         if (success) {
                             success(groups);
                         }
                         
                     }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         
                         NSLog(@"Error(getListOfGroups): %@", error);
                         
                         if (failure) {
                             failure(error);
                         }
                         
                     }];
    
}

#pragma mark - Schedule

- (void)getScheduleForGroup:(BADUniversityGroup *)group
              success:(void (^)(BADUniversitySchedule *schedule))success
              failure:(void (^)(NSError *error))failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            group.department.faculty.shortName, @"faculty",
                            @(group.department.number), @"department",
                            @"", @"course",
                            @(group.number), @"groupNumber", nil];
    
    [self.sessionManager GET:@"timetable/get/now/param"
                  parameters:params
                    progress:^(NSProgress * _Nonnull downloadProgress) {}
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         
                         BADUniversitySchedule *shedule = [[BADUniversitySchedule alloc] init];
                         
                         NSMutableArray *oddWeek = [NSMutableArray array];
                         NSMutableArray *evenWeek = [NSMutableArray array];
                         
                         NSArray *dayObjects = [[responseObject objectAtIndex:0] objectForKey:@"studyWeek"];
                         
                         for (NSDictionary *dayObject in dayObjects) {
                             
                             NSString *title = [dayObject objectForKey:@"title"];
                             
                             if ([self.daysTitlesDictionary objectForKey:title]) {
                                 title = [self.daysTitlesDictionary objectForKey:title];
                             }
                             
                             BADUniversityDay *oddDay = [[BADUniversityDay alloc] init];
                             BADUniversityDay *evenDay = [[BADUniversityDay alloc] init];
                             
                             oddDay.title = title;
                             evenDay.title = title;
                             
                             NSMutableArray *oddDayClasses = [NSMutableArray array];
                             NSMutableArray *evenDayClasses = [NSMutableArray array];
                             
                             NSArray *classObjects = [dayObject objectForKey:@"periods"];
                             
                             for (NSDictionary *classObject in classObjects) {
                                 
                                 NSInteger number = [[classObject objectForKey:@"number"] intValue];
                                 
                                 NSArray *studyClasses = [classObject objectForKey:@"studyClasses"];
                                 
                                 for (NSDictionary *studyClass in studyClasses) {
                                     
                                     BADUniversityClass *class = [[BADUniversityClass alloc] init];
                                     
                                     class.number = number;
                                     
                                     if ([studyClass objectForKey:@"studyClassLecturer"] == [NSNull null]) {
                                         
                                         class.teacher = @"";
                                         
                                     } else {
                                         
                                         class.teacher = [studyClass objectForKey:@"studyClassLecturer"];
                                         
                                     }
                                     
                                     if ([studyClass objectForKey:@"studyClassRoom"] == [NSNull null]) {
                                         
                                         class.room = @"";
                                         
                                     } else {
                                         
                                         class.room = [studyClass objectForKey:@"studyClassRoom"];
                                         
                                     }
                                     
                                     if ([studyClass objectForKey:@"studyClassTitle"] == [NSNull null]) {
                                         
                                         class.title = @"";
                                         
                                     } else {
                                         
                                         class.title = [studyClass objectForKey:@"studyClassTitle"];
                                         
                                     }
                                     
                                     if ([[studyClass objectForKey:@"type"] isEqualToString:@"normal"]) {
                                         
                                         [oddDayClasses addObject:class];
                                         [evenDayClasses addObject:class];
                                         
                                     } else if ([[studyClass objectForKey:@"type"] isEqualToString:@"nominator"]) {
                                         
                                         [oddDayClasses addObject:class];
                                         
                                     } else if ([[studyClass objectForKey:@"type"] isEqualToString:@"denominator"]) {
                                         
                                         [evenDayClasses addObject:class];
                                         
                                     }
                                     
                                 }
                                 
                             }
                             
                             oddDay.classes = oddDayClasses;
                             evenDay.classes = evenDayClasses;
                             
                             [evenWeek addObject:evenDay];
                             [oddWeek addObject:oddDay];
                             
                         }
                         
                         shedule.oddWeek = oddWeek;
                         shedule.evenWeek = evenWeek;
                         
                         if (success) {
                             success(shedule);
                         }
                         
                     }
                     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         
                         NSLog(@"Error(downloadSchedule): %@", error);
                         
                         if (failure) {
                             failure(error);
                         }
                         
                     }];
    
}


@end

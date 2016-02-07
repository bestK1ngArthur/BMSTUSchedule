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


@interface BADDownloader ()

@property (strong, nonatomic) AFHTTPRequestOperationManager *requestOperationManager;

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
        
        self.requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
        
    }
    return self;
}

- (BOOL)isNull:(id)object {

    return object == [NSNull null];
}

#pragma mark - Schedule

- (void)downloadScheduleForGroup:(BADUniversityGroup *)group
              onSuccess:(void (^)(BADUniversitySchedule *schedule))success
              onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            group.department.faculty.shortName, @"faculty",
                            @(group.department.number), @"department",
                            @"", @"course",
                            @(group.number), @"groupNumber", nil];
    
    [self.requestOperationManager GET:@"timetable/get/now/param"
                           parameters:params
                              success:^(AFHTTPRequestOperation * _Nonnull operation, NSArray *  _Nonnull responseObject) {
                                  
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
                              failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                                  
                                  NSLog(@"Error: %@", error);
                                  
                                  if (failure) {
                                      failure(error, operation.response.statusCode);
                                  }
                                  
                              }];
    
}


@end

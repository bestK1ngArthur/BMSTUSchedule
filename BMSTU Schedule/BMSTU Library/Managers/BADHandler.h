//
//  BADHandler.h
//  BMSTU Schedule
//
//  Created by Artem Belkov on 31/12/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BADUniversityClass;
@class BADUniversityDay;
@class BADUniversitySchedule;

@interface BADHandler : NSObject

- (BADUniversityClass *)handleClass:(BADUniversityClass *)universityClass;
- (BADUniversityDay *)handleDay:(BADUniversityDay *)day;
- (BADUniversitySchedule *)handleSchedule:(BADUniversitySchedule *)schedule;

@end

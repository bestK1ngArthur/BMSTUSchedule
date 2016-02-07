//
//  BADUniversityTable.m
//  BMSTU
//
//  Created by Artem Belkov on 03/11/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import "BADUniversitySchedule.h"
#import "BADUniversityClass.h"
#import "BADUniversityDay.h"

@implementation BADUniversitySchedule

- (NSArray *)allClasses {
    
    NSMutableArray *classes = [NSMutableArray array];
    
    for (BADUniversityDay *day in self.oddWeek) {
        for (BADUniversityClass *class in day.classes) {
            [classes addObject:class];

        }
    }
    
    for (BADUniversityDay *day in self.evenWeek) {
        for (BADUniversityClass *class in day.classes) {
            [classes addObject:class];
            
        }
    }
    
    return classes;
}

@end

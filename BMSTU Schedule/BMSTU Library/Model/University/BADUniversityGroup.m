//
//  BADUniversityGroup.m
//  BMSTU
//
//  Created by Artem Belkov on 08/10/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import "BADUniversityGroup.h"

#import "BADUniversityDepartment.h"
#import "BADUniversityFaculty.h"

@implementation BADUniversityGroup

- (instancetype)initWithDepartment:(BADUniversityDepartment *)department number:(NSInteger)number {
    
    self = [super init];
    
    if (self) {
        
        self.department = department;
        self.number = number;
        
    }
    
    return self;
}

- (instancetype)initWithString:(NSString *)string {
    
    self = [super init];
    
    if (self) {
        
        NSArray *array = [string componentsSeparatedByString:@"-"];
        
        self.department = [[BADUniversityDepartment alloc] init];
        self.department.faculty = [[BADUniversityFaculty alloc] init];
        
        self.department.shortName = [array objectAtIndex:0];
        
        self.department.number = [[[[array objectAtIndex:0] componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""] integerValue];
        
        self.department.faculty.shortName = [[[array objectAtIndex:0] componentsSeparatedByCharactersInSet:
                                              [NSCharacterSet decimalDigitCharacterSet]] componentsJoinedByString:@""];
        self.number = [[array objectAtIndex:1] integerValue];
        
    }
    
    return self;
    
}

#pragma mark -

- (NSString *)fullTitle {
    
    NSString *fullTitle = [NSString stringWithFormat:@"%@-%ld", self.department.shortName, (long)self.number];
    
    return fullTitle;
}

@end

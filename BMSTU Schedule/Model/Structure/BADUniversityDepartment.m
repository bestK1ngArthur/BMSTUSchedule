//
//  BADUniversityDepartment.m
//  BMSTU
//
//  Created by Artem Belkov on 08/10/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import "BADUniversityDepartment.h"
#import "BADUniversityFaculty.h"
#import "BADUniversityGroup.h"

#import "AFNetworking.h"
#import "TFHpple.h"

@implementation BADUniversityDepartment

- (instancetype)initWithName:(NSString *)name number:(NSInteger)number faculty:(BADUniversityFaculty *)faculty {
    
    self = [super init];
    
    if (self) {
        
        self.name = name;
        self.number = number;
        self.faculty = faculty;
        
        self.shortName = [self.faculty.shortName stringByAppendingFormat:@"%ld", (long)number];
        
    }
    
    return self;
}

@end

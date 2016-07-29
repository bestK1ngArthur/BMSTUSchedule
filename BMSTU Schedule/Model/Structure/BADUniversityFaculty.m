//
//  BADUniversityFaculty.m
//  BMSTU
//
//  Created by Artem Belkov on 08/10/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import "BADUniversityFaculty.h"
#import "BADUniversityDepartment.h"

#import "TFHpple.h"
#import "AFNetworking.h"

@implementation BADUniversityFaculty

- (instancetype)initWithName:(NSString *)name shortName:(NSString *)shortName {
    
    self = [super init];
    
    if (self) {
        
        self.name = name;
        self.shortName = shortName;
        
    }
    
    return self;
}

@end

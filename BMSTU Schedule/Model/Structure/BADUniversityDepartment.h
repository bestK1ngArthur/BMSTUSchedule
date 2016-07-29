//
//  BADUniversityDepartment.h
//  BMSTU
//
//  Created by Artem Belkov on 08/10/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BADUniversityFaculty;

@interface BADUniversityDepartment : NSObject

@property (strong, nonatomic) BADUniversityFaculty *faculty;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *shortName;
@property (assign, nonatomic) NSInteger number;

- (instancetype)initWithName:(NSString *)name number:(NSInteger)number faculty:(BADUniversityFaculty *)faculty;

@end

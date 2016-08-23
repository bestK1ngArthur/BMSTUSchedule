//
//  BADUniversityGroup.h
//  BMSTU
//
//  Created by Artem Belkov on 08/10/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BADUniversityDepartment;

@interface BADUniversityGroup : NSObject

@property (strong, nonatomic) BADUniversityDepartment *department;
@property (assign, nonatomic) NSInteger number;

- (instancetype)initWithDepartment:(BADUniversityDepartment *)department number:(NSInteger)number;
- (instancetype)initWithString:(NSString *)string;

- (NSString *) fullTitle;

@end

//
//  BADUniversityFaculty.h
//  BMSTU
//
//  Created by Artem Belkov on 08/10/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BADUniversityFaculty : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *shortName;

- (instancetype)initWithName:(NSString *)name shortName:(NSString *)shortName;

@end

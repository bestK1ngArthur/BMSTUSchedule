//
//  BADUniversityTable.h
//  BMSTU
//
//  Created by Artem Belkov on 03/11/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BADUniversitySchedule : NSObject

@property (strong, nonatomic) NSArray *oddWeek;  // "числитель"
@property (strong, nonatomic) NSArray *evenWeek; // "знаменатель"

- (NSArray *)allClasses;

@end

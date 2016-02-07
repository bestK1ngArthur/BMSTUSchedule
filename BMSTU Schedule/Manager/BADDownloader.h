//
//  BADDownloader.h
//  BMSTU Schedule
//
//  Created by Artem Belkov on 31/12/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BADUniversityGroup;
@class BADUniversitySchedule;

@interface BADDownloader : NSObject

+ (BADDownloader *) sharedDownloader;

- (void) downloadScheduleForGroup:(BADUniversityGroup *)group
                        onSuccess:(void (^)(BADUniversitySchedule *schedule))success
                        onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;

@end

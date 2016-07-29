//
//  BADUniversityClass.h
//  BMSTU
//
//  Created by Artem Belkov on 16/10/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BADUniversityDepartment.h"

typedef enum {
    
    BADUniversityClassTypeUnknown     = 0,
    BADUniversityClassTypeLecture     = 1, //Лекция
    BADUniversityClassTypeSeminar     = 2, //Семинар
    BADUniversityClassTypeConsultaion = 3, //КСР
    BADUniversityClassTypeLab         = 4, //Лаба
    BADUniversityClassTypePractice    = 5  //ОФП
    
} BADUniversityClassType;

@interface BADUniversityClass : NSObject

@property (strong, nonatomic) NSString *title;

@property (strong, nonatomic) NSString *teacher;
@property (strong, nonatomic) NSString *room;

@property (assign, nonatomic) BADUniversityClassType type;

@property (assign, nonatomic) NSInteger number;

@property (strong, nonatomic) NSString *startTime;
@property (strong, nonatomic) NSString *endTime;

+ (NSString *)stringFromType:(BADUniversityClassType)type;

@end

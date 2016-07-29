//
//  BADUniversityClass.m
//  BMSTU
//
//  Created by Artem Belkov on 16/10/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import "BADUniversityClass.h"

@implementation BADUniversityClass

+ (NSString *)stringFromType:(BADUniversityClassType)type {
    
    NSString *stringType;
    
    if (type == BADUniversityClassTypeSeminar) {
        
        stringType = @"семинар";
    
    } else if (type == BADUniversityClassTypeLecture) {
    
        stringType = @"лекция";
    
    } else if (type == BADUniversityClassTypeLab) {
    
        stringType = @"лаба";
        
    } else if (type == BADUniversityClassTypePractice) {
        
        stringType = @"практика";
        
    } else if (type == BADUniversityClassTypeConsultaion) {
        
        stringType = @"кср";
        
    } else {
        
        stringType = @"";
        
    }

    return stringType;
}

+ (NSString *)nameFromString:(NSString *)nameString {
    
    NSString *name = [[NSString alloc] initWithString:[nameString lowercaseString]];
    
    if ([name rangeOfString:@"кср"].location != NSNotFound) {
        
        name = [name stringByReplacingOccurrencesOfString:@"кср " withString:@""];
        
    } else if ([name rangeOfString:@"утп"].location != NSNotFound) {
        
        name = [name stringByReplacingOccurrencesOfString:@"утп " withString:@""];
        
    }
    
    name = [[[name substringToIndex:1] uppercaseString] stringByAppendingString:[name substringFromIndex:1]];
    
    //
    
    return name;
}


@end

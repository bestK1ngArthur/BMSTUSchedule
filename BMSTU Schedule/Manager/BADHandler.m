//
//  BADHandler.m
//  BMSTU Schedule
//
//  Created by Artem Belkov on 31/12/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import "BADHandler.h"

#import "BADUniversityClass.h"
#import "BADUniversityDay.h"
#import "BADUniversitySchedule.h"

@implementation BADHandler

#pragma mark - Time

- (NSString *)startTimeForNumber:(NSInteger)number {
    
    switch (number) {
        
        case 1: return @"8:30";
        case 2: return @"10:15";
        case 3: return @"12:00";
        case 4: return @"13:50";
        case 5: return @"15:40";
        case 6: return @"17:25";
        case 7: return @"19:10";
            
        default: return @"";
            
    }
}

- (NSString *)endTimeForNumber:(NSInteger)number {
    
    switch (number) {
            
        case 1: return @"10:05";
        case 2: return @"11:50";
        case 3: return @"13:35";
        case 4: return @"15:25";
        case 5: return @"17:15";
        case 6: return @"19:00";
        case 7: return @"20:45";
            
        default: return @"";
            
    }
}

#pragma mark - Type

- (BADUniversityClassType)typeFromString:(NSString *)string {
    
    BADUniversityClassType type = BADUniversityClassTypeUnknown;
    
    if ([string isEqualToString:@"(сем)"]) {
        
        type = BADUniversityClassTypeSeminar;
        
    } else if ([string isEqualToString:@"(лек)"]) {
        
        type = BADUniversityClassTypeLecture;
        
    } else if ([string isEqualToString:@"(лаб)"]) {
        
        type = BADUniversityClassTypeLab;
        
    } else if ([string isEqualToString:@"(утп)"]) {
        
        type = BADUniversityClassTypePractice;
        
    } else if ([string isEqualToString:@"(кср)"]) {
        
        type = BADUniversityClassTypeConsultaion;
        
    } else {
        
        if ([[string lowercaseString] rangeOfString:@"кср"].location != NSNotFound) {
            
            type = BADUniversityClassTypeConsultaion;
            
        } else if ([[string lowercaseString] rangeOfString:@"утп"].location != NSNotFound) {
            
            type = BADUniversityClassTypePractice;
            
        } else if (([[string lowercaseString] rangeOfString:@"лаб"].location != NSNotFound) &&
                   ([[string lowercaseString] rangeOfString:@"раб"].location != NSNotFound)) {
            
            type = BADUniversityClassTypeLab;
            
        }
        
    }
    
    return type;
}

#pragma mark - Teacher

- (NSString *)teacherFromString:(NSString *)string {
    
    string = [string stringByReplacingOccurrencesOfString:@"null" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"  " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    NSArray *teacherComponents = [string componentsSeparatedByString:@" "];
    NSMutableArray *newTeacherComponents = [NSMutableArray array];
    
    for (NSString *teacherComponent in teacherComponents) {
        
        
        if ([teacherComponent length] == 2) {
            
            NSString *string = @"";
            
            for (int i = 0; i < [teacherComponent length]; i++) {
                
                string = [string stringByAppendingFormat:@"%C.", [teacherComponent characterAtIndex:i]];
                
            }

            [newTeacherComponents addObject:string];
            
        } else if ([teacherComponent length] == 1) {
            
            NSString *string = [teacherComponent stringByAppendingString:@"."];
            
            [newTeacherComponents addObject:string];

        } else {
            
            [newTeacherComponents addObject:teacherComponent];
            
        }
        
    }
    
    string = [newTeacherComponents componentsJoinedByString:@" "];
    
    return string;
}

#pragma mark - Room

- (NSString *)roomFromString:(NSString *)string {
    
    if (!string) {
        
        return @"";
    
    } else {
        
        if ([[string lowercaseString] rangeOfString:@"на кафедре"].location == NSNotFound) {
            
            if ([[string lowercaseString] rangeOfString:@"каф"].location != NSNotFound) {
                
                string = @"на кафедре";
                
            } else {
                
                NSString *digits = [[string componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
                
                if ([digits length] < 3) {
                    
                    string = [NSString stringWithFormat:@"на кафедре %@", string];
                    
                }
                
            }
            
        }
        
        return string;
        
    }
    
}

#pragma mark - Title

- (BADUniversitySchedule *)decryptAllTitlesInSchedule:(BADUniversitySchedule *)schedule {
    
    BADUniversitySchedule *newSchedule = schedule;
    
    NSMutableArray *allClasses = [NSMutableArray arrayWithArray:[schedule allClasses]];
    
    for (BADUniversityClass *class in allClasses) {
        
        NSString *title = [class.title lowercaseString];
        
        title = [title stringByReplacingOccurrencesOfString:@"  " withString:@" "];
        title = [title stringByReplacingOccurrencesOfString:@"   " withString:@" "];
        
        // Phase 1: checking popular ciphers
        
        // = Физическое воспитание
        if (([title rangeOfString:@"физ"].location != NSNotFound) &&
            ([title rangeOfString:@"восп"].location != NSNotFound)) {
            
            class.title = @"Физическое воспитание";
            continue;
        }
        
        // = Иностранный язык
        if ([class.title isEqualToString:@"ино"]) {
            
            class.title = @"Иностранный язык";
            continue;
        }
        
        // = УТП
        if ([class.title isEqualToString:@"утп"]) {
            
            class.title = @"УТП";
            continue;
        }
        
        // Phase 2: decrypting title
        
        if ([self classNeedToDecrypt:class]) { // Need to decrypt
            
            NSArray *commaComponents = [title componentsSeparatedByString:@","];
            NSMutableArray *decryptedCommaComponents = [NSMutableArray array];
            
            for (NSString *commaComponent in commaComponents) {
                
                NSArray *spaceComponents = [commaComponent componentsSeparatedByString:@" "];
                
                if ([spaceComponents count] == 1) {
                    
                    // ду
                    
                    if ([self decryptClassTitleComponentWithLetters:[spaceComponents objectAtIndex:0]
                                                         withClasses:allClasses]) {
                        
                        [decryptedCommaComponents addObject:[self decryptClassTitleComponentWithLetters:[spaceComponents objectAtIndex:0]
                                                                                            withClasses:allClasses]];
                        
                    }
                    
                } else {
                    
                    // инт и диффер ур
                    
                    if ([self decryptClassTitleComponentWithSyllables:commaComponent
                                                          withClasses:allClasses]) {
                        
                        [decryptedCommaComponents addObject:[self decryptClassTitleComponentWithSyllables:commaComponent
                                                                                              withClasses:allClasses]];
                        
                    }
                    
                }

            }
            
            if ([decryptedCommaComponents count] > 0) {
                
                NSMutableArray *components = [NSMutableArray arrayWithArray:[[decryptedCommaComponents objectAtIndex:0] componentsSeparatedByString:@" "]];
                [components setObject:[[components objectAtIndex:0] capitalizedString] atIndexedSubscript:0];
                [decryptedCommaComponents setObject:[components componentsJoinedByString:@" "] atIndexedSubscript:0];
                
                NSString *decryptedTitle = [decryptedCommaComponents componentsJoinedByString:@", "];
                
                class.title = decryptedTitle;
                
            }

            //NSLog(@"Need to decrypt - %@, components count: %ld", title, [commaComponents count]);
            
        }
        
    }
    
    return newSchedule;
}

- (BOOL)classNeedToDecrypt:(BADUniversityClass *)class {
    
    NSInteger smallComponentsCount = 0;
    
    NSArray *titleComponents = [class.title componentsSeparatedByString:@" "];
    
    for (NSString *titleComponent in titleComponents) {
        
        if ([titleComponent rangeOfString:@","].location != NSNotFound) {
            
            NSArray *additionalTitleComponents = [titleComponent componentsSeparatedByString:@","];
            
            for (NSString *additionalTitleComponent in additionalTitleComponents) {
                
                if (([additionalTitleComponent length] < 4) && ([additionalTitleComponent length] > 1)) {
                    
                    smallComponentsCount++;
                    
                }
                
            }
            
        } else {
            
            if (([titleComponent length] < 4) && ([titleComponent length] > 1)) {
                
                smallComponentsCount++;
                
            }
            
        }
        
    }

    return (smallComponentsCount > 1);
}

- (NSString *)decryptClassTitleComponentWithLetters:(NSString *)title withClasses:(NSArray *)classes {
    
    NSInteger indexOfExTitle = -1;
    NSInteger oldNumberOfMatches = 0;
    
    for (BADUniversityClass *class in classes) {
        
        if (![self classNeedToDecrypt:class]) {
         
            NSInteger numberOfMatches = 0;
            
            for (int i = 0; i < [title length]; i++) {
                
                unichar a = [title characterAtIndex:i];
                
                NSArray *exClassComponents = [[class.title lowercaseString] componentsSeparatedByString:@" "];
                
                for (NSString *exClassComponent in exClassComponents) {
                    
                    if ([exClassComponent length] == 0) {
                        
                        break;
                        
                    } else {
                        
                        unichar b = [exClassComponent characterAtIndex:0];
                        
                        if (a == b) {
                            
                            numberOfMatches++;
                            
                            break;
                        }
                        
                    }
                    
                }
                
            }
            
            if (numberOfMatches >= oldNumberOfMatches) {
                
                oldNumberOfMatches = numberOfMatches;
                indexOfExTitle = [classes indexOfObject:class];
                
            }
            
        }
        
    }
    
    if (indexOfExTitle != -1) {
        
        return [[[classes objectAtIndex:indexOfExTitle] title] lowercaseString];
        
    } else {
        
        return nil;
        
    }

}

- (NSString *)decryptClassTitleComponentWithSyllables:(NSString *)title withClasses:(NSArray *)classes {
    
    NSInteger indexOfExTitle = -1;
    
    NSInteger componentsCount = 0;
    NSInteger oldNumberOfMatches = 0;
    
    for (BADUniversityClass *class in classes) {
        
        if (![self classNeedToDecrypt:class]) {
            
            NSInteger numberOfMatches = 0;
            
            NSArray *titleComponents = [[title lowercaseString] componentsSeparatedByString:@" "];
            
            NSString *exTitle = [class.title stringByReplacingOccurrencesOfString:@"  " withString:@" "];
            exTitle = [exTitle stringByReplacingOccurrencesOfString:@"   " withString:@" "];
            
            NSArray *exTitleComponents = [[exTitle lowercaseString] componentsSeparatedByString:@" "];
            
            
            for (int i = 0, j = 0; i < MIN(titleComponents.count, exTitleComponents.count); i++, j++) {
                
                NSString *titleComponent = [titleComponents objectAtIndex:j];
                NSString *exTitleComponent = [exTitleComponents objectAtIndex:i];

                if ([exTitleComponent rangeOfString:titleComponent].location != NSNotFound) {
                    
                    numberOfMatches++;
                    
                } else {
                    
                    j--;
                    
                }
                
            }
            
            if ((numberOfMatches >= oldNumberOfMatches) && ([class.title rangeOfString:@","].location == NSNotFound)) {
                
                oldNumberOfMatches = numberOfMatches;
                componentsCount = [[class.title componentsSeparatedByString:@" "] count];
                
                indexOfExTitle = [classes indexOfObject:class];
                
            }
            
        }
        
    }
    
    if ((indexOfExTitle != -1) && (oldNumberOfMatches >= (componentsCount / 2))) {
        
        return [[[classes objectAtIndex:indexOfExTitle] title] lowercaseString];
        
    } else {
        
        return nil;
        
    }
    
}

#pragma mark -

- (BADUniversityClass *)handleClass:(BADUniversityClass *)universityClass {
    
    // Handle time
    
    universityClass.startTime = [self startTimeForNumber:universityClass.number];
    universityClass.endTime = [self endTimeForNumber:universityClass.number];
    
    // Handle type
    
    universityClass.title = [universityClass.title lowercaseString];
    universityClass.title = [universityClass.title stringByReplacingOccurrencesOfString:@"." withString:@" "];
    NSMutableArray *titleComponents = [NSMutableArray arrayWithArray:[universityClass.title componentsSeparatedByString:@" "]];
    
    for (NSString *titleComponent in titleComponents) {
        
        BADUniversityClassType type = [self typeFromString:titleComponent];
                
        if (type != BADUniversityClassTypeUnknown) {
            
            universityClass.type = type;
            
            if ([titleComponents count] > 1) {
                [titleComponents removeObject:titleComponent];

            }
            
            break;
        
        }
        
    }
    
    // Handle title
    
    if ([titleComponents count] > 0) {
        [titleComponents setObject:[[titleComponents objectAtIndex:0] capitalizedString] atIndexedSubscript:0];
    }
    
    int singleCharsCount = 0;
    
    for (NSString *titleComponent in titleComponents) {
     
        if ([titleComponent length] == 1) {
            singleCharsCount++;
        }
        
    }
    
    NSString *title = [titleComponents componentsJoinedByString:@" "];
    
    if (singleCharsCount > 3) {
        
        title = [title stringByReplacingOccurrencesOfString:@" " withString:@""];
        
    }
    
    universityClass.title = title;
    
    // Handle room
    
    universityClass.room = [self roomFromString:universityClass.room];

    // Handle teacher
    
    universityClass.teacher = [self teacherFromString:universityClass.teacher];

    
    return universityClass;
}

- (BADUniversityDay *)handleDay:(BADUniversityDay *)day {
    
    // Handle title
    
    
    
    // Handle classes
    
    NSMutableArray *classes = [NSMutableArray array];
    
    for (BADUniversityClass *class in day.classes) {
        
        [classes addObject:[self handleClass:class]];
        
    }
    
    day.classes = classes;
    
    return day;
}

#pragma mark -

- (BADUniversitySchedule *)handleSchedule:(BADUniversitySchedule *)schedule {
    
    // Handle odd week
    
    NSMutableArray *oodWeek = [NSMutableArray array];
    
    for (BADUniversityDay *day in schedule.oddWeek) {
        
        [oodWeek addObject:[self handleDay:day]];
        
    }
    
    schedule.oddWeek = oodWeek;
    
    // Handle even week
    
    NSMutableArray *evenWeek = [NSMutableArray array];
    
    for (BADUniversityDay *day in schedule.evenWeek) {
        
        [evenWeek addObject:[self handleDay:day]];
        
    }
    
    schedule.evenWeek = evenWeek;
    
    schedule = [self decryptAllTitlesInSchedule:schedule];
    
    return schedule;
}

@end

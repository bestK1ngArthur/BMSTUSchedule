//
//  BADUniversityClassCell.m
//  BMSTU
//
//  Created by Artem Belkov on 05/10/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import "UniversityClassCell.h"

@implementation UniversityClassCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)heightForText:(NSString *)text {
    
    CGFloat upOffset   = 39.0;
    CGFloat downOffset = 39.0;
    
    UIFont *font = [UIFont systemFontOfSize:17.f];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                font, NSFontAttributeName,
                                paragraphStyle, NSParagraphStyleAttributeName, nil];
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(254, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attributes
                                     context:nil];
    
    return CGRectGetHeight(rect) + upOffset + downOffset;
}

@end

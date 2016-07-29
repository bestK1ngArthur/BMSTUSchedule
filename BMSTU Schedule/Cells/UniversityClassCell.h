//
//  BADUniversityClassCell.h
//  BMSTU
//
//  Created by Artem Belkov on 05/10/15.
//  Copyright © 2015 Artem Belkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UniversityClassCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *beginTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *classTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *classRoomLabel;
@property (weak, nonatomic) IBOutlet UILabel *classTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *classTeacherLabel;

+ (CGFloat)heightForText:(NSString *)text;

@end

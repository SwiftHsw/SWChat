//
//  SWLocationTableViewCell.m
//  SWChatUI
//
//  Created by 帅到不行 on 2020/11/18.
//  Copyright © 2020 sw. All rights reserved.
//

#import "SWLocationTableViewCell.h"

@implementation SWLocationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
 
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont systemFontOfSize:16];

        self.detailTextLabel.font = [UIFont systemFontOfSize:12];
        self.detailTextLabel.textColor = [UIColor lightGrayColor];
    }

    return self;
}
 

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.top -= 3;
    self.textLabel.left -= 3;
    
    self.detailTextLabel.bottom += 1;
    self.detailTextLabel.left -= 3;
}

@end

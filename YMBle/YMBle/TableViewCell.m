//
//  TableViewCell.m
//  YMBle
//
//  Created by ren zhicheng on 2018/1/11.
//  Copyright © 2018年 Yinkman. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _deviceName = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 40)];
        [self addSubview:_deviceName];
        
        _deviceRssi = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width-(self.bounds.size.width - 210), 0, 60, 40)];
        [self addSubview:_deviceRssi];
       
    }
    
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

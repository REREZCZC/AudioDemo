//
//  CharacteristicTableViewController.m
//  YMBle
//
//  Created by ren zhicheng on 2018/1/15.
//  Copyright © 2018年 Yinkman. All rights reserved.
//

#import "CharacteristicTableViewController.h"

@interface CharacteristicTableViewController () {
    CBCharacteristic *currentItem;
    CBPeripheral *currentPeripher;
}
@end

@implementation CharacteristicTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    _sectionArray = [NSMutableArray arrayWithObjects:@"Value",@"WriteValue",@"Properties", nil];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellID"];
}

- (void)setCharacter:(CBCharacteristic *)character {
    currentItem = character;
}
- (void)setPeriph:(CBPeripheral *)periph {
    currentPeripher = periph;
}

#pragma mark - Table view data source



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 1;
            break;
        default:
            return 0; break;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.view.bounds.size.width, 50)];
    title.text = _sectionArray[section];
    [title setTextColor:[UIColor whiteColor]];
    [title setBackgroundColor:[UIColor darkGrayColor]];
    return title;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier2 = [NSString stringWithFormat:@"CommonTextCell%ld_%ld",(long)indexPath.section,(long)indexPath.row];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(7, 0, self.view.bounds.size.width, 40)];
        
        switch (indexPath.section) {
            case 0:
                label.text = [NSString stringWithFormat:@"%@",currentItem.value];
                break;
            case 1:
                label.text = @"Write a value";
                break;
            case 2:
                label.text = [self propertiesWithCharacteristic:currentItem];
                break;
            default:
                break;
        }

        [cell.contentView addSubview:label];
    }
    
    
    return cell;

}

- (NSString *)propertiesWithCharacteristic:(CBCharacteristic *)characteristic {
    CBCharacteristicProperties p = characteristic.properties;
    NSString *string = @"";
    if (p & CBCharacteristicPropertyBroadcast) {
        string = [string stringByAppendingString:@" Broadcast "];
    }
    if (p & CBCharacteristicPropertyRead) {
        string = [string stringByAppendingString:@" Read "];
    }
    if (p & CBCharacteristicPropertyWriteWithoutResponse) {
        string = [string stringByAppendingString:@" WriteWithoutResponse "];
    }
    if (p & CBCharacteristicPropertyWrite) {
        string = [string stringByAppendingString:@" Write "];
    }
    if (p & CBCharacteristicPropertyNotify) {
        string = [string stringByAppendingString:@" Notify "];
    }
    if (p & CBCharacteristicPropertyIndicate) {
        string = [string stringByAppendingString:@" Indicate "];
    }
    if (p & CBCharacteristicPropertyAuthenticatedSignedWrites) {
        string = [string stringByAppendingString:@" AuthenticatedSignedWrites "];
    }
    if (p & CBCharacteristicPropertyExtendedProperties) {
        string = [string stringByAppendingString:@" ExtendedProperties "];
    }

    return string;
}


@end

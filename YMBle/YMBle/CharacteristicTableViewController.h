//
//  CharacteristicTableViewController.h
//  YMBle
//
//  Created by ren zhicheng on 2018/1/15.
//  Copyright © 2018年 Yinkman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface CharacteristicTableViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong)CBCharacteristic *character;
@property(nonatomic, strong)CBPeripheral *periph;
@property(nonatomic, strong)NSMutableArray *sectionArray;
@end

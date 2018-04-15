//
//  ServiceViewController.h
//  YMBle
//
//  Created by ren zhicheng on 2018/1/11.
//  Copyright © 2018年 Yinkman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ServiceViewController : UITableViewController <CBPeripheralDelegate>
@property(nonatomic, strong)CBPeripheral *peripheral;
@property(nonatomic, strong)NSMutableArray *servicesArray;
@property(nonatomic, strong)NSMutableDictionary *characteristicDict;
@end

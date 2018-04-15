//
//  ViewController.h
//  YMBle
//
//  Created by ren zhicheng on 2018/1/10.
//  Copyright © 2018年 Yinkman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate,UITableViewDataSource,UITableViewDelegate>{
    CBCentralManager *bleManager;
    CBPeripheral *perpher;
    CBCharacteristic *cc;
    NSMutableArray *foundDeviceArray;
    NSMutableArray *rssiArray;
    CBPeripheral *selectedPer;
}


@end


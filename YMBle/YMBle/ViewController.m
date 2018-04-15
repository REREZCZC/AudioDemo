//
//  ViewController.m
//  YMBle
//
//  Created by ren zhicheng on 2018/1/10.
//  Copyright © 2018年 Yinkman. All rights reserved.
//

#import "ViewController.h"
#import "TableViewCell.h"
#import "ServiceViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
NSString * const identifier = @"DEVICELIST";
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Create ble manager
    bleManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView registerClass:[TableViewCell class] forCellReuseIdentifier:identifier];
}

- (IBAction)startScan:(UIButton *)sender {

    if (bleManager.state == CBCentralManagerStatePoweredOn) {//ble ok
        NSLog(@"扫描中..");
        self.title = @"扫描中";
        //开始扫描设备
        //nil 表示扫描所有设备, 或者指定 Service uuid
        [bleManager scanForPeripheralsWithServices:nil options:nil];
    }
    
}





//----------------------------TableView Delegate----------------------------
//--------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return foundDeviceArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    CBPeripheral *per = foundDeviceArray[indexPath.row];
    cell.deviceName.text = per.name ? per.name : @"Null";
    cell.deviceRssi.text = [rssiArray[indexPath.row] stringValue];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedPer = foundDeviceArray[indexPath.row];
    [bleManager stopScan];
    
    [bleManager connectPeripheral:selectedPer options:nil];
    
   
}


//-----------------------CentralManager Delegate----------------------------
//--------------------------------------------------------------------------
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state==CBCentralManagerStatePoweredOn) {
        self.title = @"蓝牙已就绪";
    }else{
        self.title = @"蓝牙未准备好";
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSLog(@"peripherName: %@",peripheral.name);
    //检查重复设备
    if (!foundDeviceArray) {
        foundDeviceArray = [[NSMutableArray alloc] initWithObjects:peripheral, nil];
        rssiArray = [[NSMutableArray alloc] initWithObjects:RSSI, nil];
    }else {
        for (int i = 0; i < foundDeviceArray.count ; i++) {
            CBPeripheral *per = [foundDeviceArray objectAtIndex:i];
            if ((per.identifier == NULL) || (peripheral.identifier == NULL)) continue;//跳出本次循环
            if ([per.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {//已经存在
                [foundDeviceArray replaceObjectAtIndex:i withObject:peripheral];//替换更新
                [rssiArray replaceObjectAtIndex:i withObject:RSSI];
                return;
            }
        }
        //添加新设备
        [foundDeviceArray addObject:peripheral];
        [rssiArray addObject:RSSI];
        [_tableView reloadData];
    }
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"已经连接到%@",peripheral.name);
    NSLog(@"----------");
    self.title = @"连接成功";
    
    //如果连接成功了,就进入详细界面
    ServiceViewController *serviceVC = [[ServiceViewController alloc] init];
    serviceVC.peripheral = selectedPer;
    [self.navigationController pushViewController:serviceVC animated:YES];
    
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"连接%@失败",peripheral.name);
    self.title = @"连接失败";
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"已经断开%@连接",peripheral.name);
    self.title = @"已断开";
}


@end

































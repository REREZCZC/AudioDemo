//
//  ServiceViewController.m
//  YMBle
//
//  Created by ren zhicheng on 2018/1/11.
//  Copyright © 2018年 Yinkman. All rights reserved.
//

#import "ServiceViewController.h"
#import "CharacteristicTableViewController.h"

@interface ServiceViewController ()

@end

@implementation ServiceViewController

//连接成功 peripheral 之后进入此详细界面, 进而继续搜索Service, 和 characteristic.
- (void)viewWillAppear:(BOOL)animated {
    [_peripheral setDelegate:self];//设置 peripheral 代理
    [_peripheral discoverServices:nil];//让 peripheral 搜索 Service
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    _servicesArray = [[NSMutableArray alloc ] init];
    _characteristicDict = [[NSMutableDictionary alloc] init];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellID"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

//Service
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    if (!error) {
        for (int i = 0; i < peripheral.services.count; i++) {
            CBService *service = peripheral.services[i];
            [_servicesArray addObject:service];
            [peripheral discoverCharacteristics:nil forService:service];
            
        }
    }else {
        NSLog(@"扫描 Service 错误");
    }
}


//characteristic
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSMutableArray *characteristicsArray = [NSMutableArray arrayWithCapacity:service.characteristics.count];
    
    if (!error) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            [characteristicsArray addObject:characteristic];
        }
    }
    [_characteristicDict setObject:characteristicsArray forKey:service.UUID.UUIDString];
    [self.tableView reloadData];
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
//    NSLog(@"%@Vlaue: %@",characteristic.UUID,characteristic.value);
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _characteristicDict.allKeys.count;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.view.bounds.size.width, 50)];
     CBService *service = _servicesArray[section];
    title.text = [NSString stringWithFormat:@"%@",service.UUID];
    
    [title setTextColor:[UIColor whiteColor]];
    [title setBackgroundColor:[UIColor darkGrayColor]];
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CBService *ser = _servicesArray[section];
    NSString *string = ser.UUID.UUIDString;
    NSArray *array = _characteristicDict[string];
    return array.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier2 = [NSString stringWithFormat:@"CommonTextCell%ld_%ld",(long)indexPath.section,(long)indexPath.row];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        UILabel *characterisitcID = [[UILabel alloc] initWithFrame:CGRectMake(7, 0, self.view.bounds.size.width, 40)];
        CBService *ser = _servicesArray[indexPath.section];
        NSString *string = ser.UUID.UUIDString;
        NSArray *array = _characteristicDict[string];
        CBCharacteristic *charar = array[indexPath.row];
        characterisitcID.text = [NSString stringWithFormat:@"%@",charar.UUID];
        
        [cell.contentView addSubview:characterisitcID];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBService *ser = _servicesArray[indexPath.section];
    NSString *string = ser.UUID.UUIDString;
    NSArray *array = _characteristicDict[string];
    CBCharacteristic *charar = array[indexPath.row];
    [_peripheral readValueForCharacteristic:charar];
    
    CharacteristicTableViewController *VC = [[CharacteristicTableViewController alloc] init];
    VC.character = charar;
    [self.navigationController pushViewController:VC animated:YES];
    
}



@end

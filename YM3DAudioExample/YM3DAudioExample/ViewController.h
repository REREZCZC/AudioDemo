//
//  ViewController.h
//  YinkmanAudioDemo
//
//  Created by zhicheng ren on 2017/3/7.
//  Copyright © 2017年 Yinkman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioProcessor.h"

@interface ViewController : UIViewController

@property (nonatomic, strong)UILabel *mainSwitchLabel;
@property (nonatomic, strong)UISwitch *mainSwitch;
@property (nonatomic, strong)AudioProcessor *audioProcessor;
@property (nonatomic, strong)UISwitch *bandEQSwitch;
@property (nonatomic, strong)UILabel *bandEQSwitchLabel;
@property (nonatomic, strong)UILabel *currentValue;
@property (nonatomic, strong)UISegmentedControl *segmentControl;

@end


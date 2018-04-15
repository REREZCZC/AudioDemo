//
//  ViewController.m
//  YinkmanAudioDemo
//
//  Created by zhicheng ren on 2017/3/7.
//  Copyright © 2017年 Yinkman. All rights reserved.
//

#import "ViewController.h"
#import "masonry.h"

NSMutableArray *labelArrary;
NSMutableArray *LabelTestArray;
NSArray *nameArray;

float heavyBaseArray[10]  = {6,8,7,4,0,-1,-5,1,2,-2};
float humanVoiceArray[10] = {-4,-5,-2,2,4,9,5,1,-2,-2};
float popularArray[10]    = {0,0,0,2,3,3,2,0,0,0};
float rockArray[10]       = {7,1,4,2,-3,2,5,5,7,5};
float electronicArray[10] = {8,6,2,0,3,4,6,3,0,0};
float classicalArray[10]  = {5,4,2,1,-1,0,2,3,3,3};
float heavyMetal[10]      = {-2,2,3,-4,-5,-4,0,4,6,2};
float noEQArray[10]       = {0,0,0,0,0,0,0,0,0,0};
NSMutableArray *sliderArray;

@interface ViewController ()

@end

@implementation ViewController

@synthesize mainSwitch,mainSwitchLabel,audioProcessor, bandEQSwitch,bandEQSwitchLabel, currentValue, segmentControl;



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //main
    mainSwitch = [[UISwitch alloc] init];
    [mainSwitch addTarget:self action:@selector(mainSwitchValueChange:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mainSwitch];
    
    mainSwitchLabel = [[UILabel alloc] init];
    mainSwitchLabel.textAlignment = NSTextAlignmentRight;
    mainSwitchLabel.text = @" Main";
    [self.view addSubview:mainSwitchLabel];
    
    audioProcessor = [[AudioProcessor alloc] init];
    
    [self updateConstraints];
    
}



- (void)updateConstraints  {
    [mainSwitch mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(65);
        make.top.equalTo(self.view.mas_top).offset(50);
    }];
    [mainSwitchLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(mainSwitch.mas_centerY);
        make.right.equalTo(self.view.mas_right).offset(-50);
        make.height.equalTo(mainSwitch.mas_height);
        make.left.equalTo(mainSwitch.mas_right).offset(20);
    }];
    
    [bandEQSwitch mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(mainSwitch.mas_left);
        make.top.equalTo(mainSwitch.mas_bottom).offset(20);
    }];
    
    [bandEQSwitchLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bandEQSwitch.mas_centerY);
        make.right.equalTo(self.view.mas_right).offset(-50);
        make.height.equalTo(mainSwitch.mas_height);
        make.left.equalTo(bandEQSwitch.mas_right).offset(20);
    }];
    
    [currentValue mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(bandEQSwitchLabel.mas_bottom).offset(10);
        make.height.equalTo(bandEQSwitchLabel.mas_height);
        make.width.equalTo(@150);
    }];
    
    [segmentControl mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom).offset(-25);
        make.height.equalTo(@20);
    }];
    
}




- (void)mainSwitchValueChange:(id)sender {
    if (!mainSwitch.on) {
        [audioProcessor stop];
    } else {
        if (audioProcessor == nil) {
            audioProcessor = [[AudioProcessor alloc] init];
        }
        [audioProcessor start];
    }
}



- (void)bandEQSwitchValueChange:(id)sender {
    if (!bandEQSwitch.on) {
        audioProcessor.shouldBandEQ = NO;
    }else {
        audioProcessor.shouldBandEQ = YES;
    }
}


- (void)sliderValueDidChange:(UISlider *)slider {
    currentValue.text = [NSString stringWithFormat:@"%.f",slider.value];
    [audioProcessor setEQindex:(unsigned int)slider.tag forValue:slider.value];
}

- (void)segmentControlValueChanged:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self setWithArray:heavyBaseArray];
            
            break;
        case 1:
            [self setWithArray:humanVoiceArray];
            break;
        case 2:
            [self setWithArray:popularArray];
            break;
        case 3:
            [self setWithArray:rockArray];
            break;
        case 4:
            [self setWithArray:electronicArray];
            break;
        case 5:
            [self setWithArray:classicalArray];
            break;
        case 6:
            [self setWithArray:heavyMetal];
            break;
        case 7:
            [self setWithArray:noEQArray];
            break;
        default:
            break;
    }
}

- (void) setWithArray:(float *)array {
    for (int i = 0; i < 10; i++) {
        float value = array[i];
        UISlider *slider = sliderArray[i];
        slider.value = value;
        [audioProcessor setEQindex:i forValue:value];
    }
}

@end








































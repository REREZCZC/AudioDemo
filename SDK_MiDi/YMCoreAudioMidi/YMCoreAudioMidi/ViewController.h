//
//  ViewController.h
//  YMCoreAudioMidi
//
//  Created by zhicheng ren on 2017/12/19.
//  Copyright © 2017年 yinkman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController : UIViewController {
    MusicPlayer mp;
    MusicSequence ms;
    NSString *deviceName_1;
    NSMutableArray *devicesArray;
    UIButton *selectDevice;
    UITableView *deviceNameTable;
    NSInteger deviceNumber;
    Float64 longestTrackLength;

}
@property(nonatomic, strong)UIButton *playButton;
@property(nonatomic, strong)UITextField *textfield;
@property(nonatomic, strong)UILabel *deviceName;
@property(nonatomic, strong)UISlider *noteValueSlider;
@property(nonatomic, strong)UILabel *currentNoteValueLabel;

@property(nonatomic, strong)UISegmentedControl *segment;
@end


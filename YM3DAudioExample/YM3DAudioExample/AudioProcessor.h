//
//  AudioProcessor.h
//  YinkmanAudioDemo
//
//  Created by zhicheng ren on 2017/3/7.
//  Copyright © 2017年 Yinkman. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#define max(a, b) (((a) > (b)) ? (a) : (b))
#define kOutputBus 0
#define kInputBus 1

#define SAMPLE_RATE 44100.00

@interface AudioProcessor : NSObject

@property (readonly) AudioBuffer audioBuffer;
@property (readonly) AudioComponentInstance audioUnit;
@property (nonatomic) AudioBufferList *bufferList;
@property (nonatomic) UInt32 newSampleNumber;


@property (nonatomic) BOOL shouldBandEQ;

-(AudioProcessor*)init;

-(void)start;
-(void)stop;
void CheckError(OSStatus error , const char *operation);
- (void)setEQindex:(unsigned int)index forValue:(float)value;
@end

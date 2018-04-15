#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ViewController.h"
typedef struct {
    UInt32 firstChannelNumber;
    BOOL  isStereo;
    UInt32  frameCount;
    UInt32  sampleNumber;
    AudioUnitSampleType  *audioDataLeft;
    AudioUnitSampleType  *audioDataRight;
    AudioUnitSampleType  *audioDataChannelFirst;
    AudioUnitSampleType  *audioDataChannelSecond;
    AudioUnitSampleType  *audioDataChannelThird;
    AudioUnitSampleType  *audioDataChannelFouth;
} soundStruct, *soundStructPtr;

@interface AudioPlayer : NSObject 
{
    Float64       sampleRate;
    soundStruct   soundStructInfo;
//    AudioUnit     outputUnit;
    AudioStreamBasicDescription fileASBD;
    
    
    AudioUnitSampleType *allData;
    
    SInt64 packetCount;
    
    AudioStreamBasicDescription importFormat;
    
    
//    AUChannelInfo *inputAndOutputChannelNumber;
}

 void    FillOutASBDForLPCM(AudioStreamBasicDescription outASBD, Float64 inSampleRate, UInt32 inChannelsPerFrame, UInt32 inValidBitsPerChannel, UInt32 inTotalBitsPerChannel, bool inIsFloat, bool inIsBigEndian, bool inIsNonInterleaved);

- (void)passSpeed:(CGFloat)speed;
- (void)passdis:(CGFloat)dis;
- (void)passReverber:(CGFloat)reverber;
- (void)passDelay:(CGFloat)delay;


- (void)play;
- (void)stop;
- (void)pause;



//- (id)initWithAudioFileURL:(NSURL *)urlToAudioFile samplingRate:(float)thisSamplingRate numChannels:(UInt32)thisNumChannels;
- (void)writeNewAudio:(float *)newData numFrames:(UInt32)thisNumFrames numChannels:(UInt32)thisNumChannels;


void writeNewAuido(float *newData, UInt32 thisNumFrames, UInt32 thisNumChannels);
//void writeNewAuido(float *newData, float *rightData ,UInt32 thisNumFrames, UInt32 thisNumChannels);



@end

//
//  AudioProcessor.m
//  YinkmanAudioDemo
//
//  Created by zhicheng ren on 2017/3/7.
//  Copyright © 2017年 Yinkman. All rights reserved.
//
#import <pthread.h>
#import <AudioUnit/AudioUnit.h>
#import "AudioProcessor.h"
#import "subrt.h"
#import "YinManAudioAPI.h"
#import "SuperpoweredSimple.h"


unsigned  int       memSize;
void *baseAdr = NULL;
float SPEED = 20;
float distance;
struct param_DSP sParamDsp;
float delta;
float angle = 45;


//#import "YMNBandEQ.h"


UInt64          totalFramesInFile;
UInt32          channelCount;
//YMNBandEQ       *ymNBandEQ;
SInt16          *bgmTotalBufferSint16;

#define MONO_MIC_INPUT 0

@implementation AudioProcessor

#pragma mark Synthesize
@synthesize audioUnit, audioBuffer, bufferList, newSampleNumber;


void CheckError(OSStatus error, const char *operation) {
    if (error == noErr) return;
    
    char str[20];
    *(UInt32 *)(str + 1) = CFSwapInt32HostToBig(error);
    if (isprint(str[1]) && isprint(str[2]) && isprint(str[3]) && isprint(str[4])) {
        str[0] = str[5] = '\'';
        str[6] = '\0';
    } else
        sprintf(str, "%d", (int)error);
    
    fprintf(stderr, "Error: %s (%s)\n", operation, str);
    
    exit(1);
}



-(AudioProcessor*)init
{
    self = [super init];
    if (self) {
        
        [self readBackGroundMusicToMemery];
        [self initializeProcessor];
        [self initializeAudio];
    }
    return self;
}



- (void) readBackGroundMusicToMemery {
    
    //打开音频文件
    NSURL *guitarLoop = [[NSBundle mainBundle] URLForResource: @"hktxmp3" withExtension: @"mp3"];
    ExtAudioFileRef audioFileObject = 0;
    CheckError(ExtAudioFileOpenURL ((__bridge CFURLRef)guitarLoop, &audioFileObject), "audio file open URL failed");
    UInt32 frameLengthPropertySize = sizeof (totalFramesInFile);
    
    //获取文件长度
    CheckError(ExtAudioFileGetProperty (
                                        audioFileObject,
                                        kExtAudioFileProperty_FileLengthFrames,
                                        &frameLengthPropertySize,
                                        &totalFramesInFile
                                        ), "get audio file lengthframes failed");
    
    
    //得到声道数
    AudioStreamBasicDescription fileAudioFormat = {0};
    UInt32 formatPropertySize = sizeof (fileAudioFormat);
    CheckError(ExtAudioFileGetProperty (
                                        audioFileObject,
                                        kExtAudioFileProperty_FileDataFormat,
                                        &formatPropertySize,
                                        &fileAudioFormat
                                        ), "get file data format failed");
    
    channelCount = fileAudioFormat.mChannelsPerFrame;
    NSLog(@"channelCount :%d",channelCount);
    AudioStreamBasicDescription bgmFormat = [self setAudioFormatDescriptionWithChannelCount:channelCount];
    
    CheckError(ExtAudioFileSetProperty (
                                        audioFileObject,
                                        kExtAudioFileProperty_ClientDataFormat,
                                        sizeof (bgmFormat),
                                        &bgmFormat
                                        ), "set audio file client data format failed");
    
    //分配内存读取数据
    bufferList = AudioBufferListCreate(bgmFormat, (int)totalFramesInFile);
    UInt32 numberOfPacketsToReads = (UInt32) totalFramesInFile;
    CheckError(ExtAudioFileRead (audioFileObject, &numberOfPacketsToReads, bufferList), "audio file read failed.");
    newSampleNumber = 0;
    CheckError(ExtAudioFileDispose (audioFileObject), "close audio file failed");
    
}

//format description
- (AudioStreamBasicDescription)setAudioFormatDescriptionWithChannelCount:(int)channelCount {
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate            = SAMPLE_RATE;
    audioFormat.mFormatID              = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags           = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
    audioFormat.mFramesPerPacket       = 1;
    audioFormat.mChannelsPerFrame      = channelCount;
    audioFormat.mBytesPerFrame         = audioFormat.mChannelsPerFrame * 2;
    audioFormat.mBytesPerPacket	       = audioFormat.mFramesPerPacket * audioFormat.mBytesPerFrame;
    audioFormat.mBitsPerChannel	       = 16;
    return audioFormat;
}


-(void)initializeAudio {
    
    //Audio Component
    AudioComponentDescription desc;
    desc.componentType          = kAudioUnitType_Output; //ouput
    desc.componentSubType       = kAudioUnitSubType_RemoteIO; //in and ouput
    desc.componentFlags         = 0; // must be zero
    desc.componentFlagsMask     = 0; // must be zero
    desc.componentManufacturer  = kAudioUnitManufacturer_Apple;
    
    // find component
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    
    // auidoUnit
    CheckError(AudioComponentInstanceNew(inputComponent, &audioUnit), "audio component instace new failed");
    
    
    // set audioUnit IO
    UInt32 flag = 1;
    CheckError(AudioUnitSetProperty(audioUnit,
                                    kAudioOutputUnitProperty_EnableIO,
                                    kAudioUnitScope_Input,
                                    kInputBus,
                                    &flag,
                                    sizeof(flag)), "set audio unit enableIO inputBus failed ");
    
    //outbus format
    AudioStreamBasicDescription outbusFormat = [self setAudioFormatDescriptionWithChannelCount:channelCount];
    
    
    CheckError(AudioUnitSetProperty(audioUnit,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Input,
                                    kOutputBus,
                                    &outbusFormat,
                                    sizeof(outbusFormat)), "set audio outputBus streamFormat failed");
    
    
    AURenderCallbackStruct callbackStruct;
    
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)self;
    
    CheckError(AudioUnitSetProperty(audioUnit,
                                    kAudioUnitProperty_SetRenderCallback,
                                    kAudioUnitScope_Global,
                                    kOutputBus,
                                    &callbackStruct,
                                    sizeof(callbackStruct)), "Set ouputBus renderCallback failed");
    flag = 0;
    
    
    CheckError(AudioUnitSetProperty(audioUnit,
                                    kAudioUnitProperty_ShouldAllocateBuffer,
                                    kAudioUnitScope_Output,
                                    kInputBus,
                                    &flag,
                                    sizeof(flag)), "set audio unit should allocate buffer failed");
    

    //init audioUnit
    CheckError(AudioUnitInitialize(audioUnit), "Initialize audio unit failed ");
    
    
}
- (void)initializeProcessor {
    memSize = ym_9con_queryMem();
    baseAdr = malloc(memSize);
    ym_9con_open(baseAdr);
    ym_song_ini(2, baseAdr);
    
    
    sParamDsp.funEnable = DWN_MIX_ENABLE|ROTATION_ENABLE|DIST_DRC_ENABLE|REVERB_ENABLE;
    sParamDsp.sampleStride = NON_INTERLEAVE_STRIDE;
    sParamDsp.gainRvb = 6;
    sParamDsp.dlyFramN = 13;
    
    sParamDsp.framSize = 512;
}



//start and stop audioUnit
-(void)start {
    CheckError(AudioOutputUnitStart(audioUnit), "audio unit start failed");
}

-(void)stop {
    CheckError(AudioOutputUnitStop(audioUnit), "stop audio unit failed");
}


static OSStatus playbackCallback(void *inRefCon,
                                 AudioUnitRenderActionFlags *ioActionFlags,
                                 const AudioTimeStamp *inTimeStamp,
                                 UInt32 inBusNumber,
                                 UInt32 inNumberFrames,
                                 AudioBufferList *ioData) {
    
    AudioProcessor *audioProcessor = (__bridge AudioProcessor*) inRefCon;
    SInt16 bgmSectionBufferSint16[inNumberFrames *2];
    //total bgm
    bgmTotalBufferSint16  = (SInt16*)audioProcessor.bufferList->mBuffers[0].mData;
    
    for (int i = 0; i < inNumberFrames * 2; i++) {
        bgmSectionBufferSint16[i]  = bgmTotalBufferSint16[audioProcessor.newSampleNumber];
        audioProcessor.newSampleNumber += 1;
        if (audioProcessor.newSampleNumber >= totalFramesInFile * 2 ) {
            audioProcessor.newSampleNumber = 0;
        }
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"inNumberFrames: %d",inNumberFrames);
    });
 //--------------------------------------------
    //将数据分为两个部分.
    SInt16 firstLeft[inNumberFrames];
    SInt16 secondRight[inNumberFrames];
    
    for (int i = 0; i < inNumberFrames; i++) {
        firstLeft[i] = bgmSectionBufferSint16[i];
        secondRight[i] = bgmSectionBufferSint16[i + inNumberFrames];
    }
    
    float firstFloatLeft[inNumberFrames];
    float secondFloatRight[inNumberFrames];

    SuperpoweredShortIntToFloat(firstLeft, firstFloatLeft, inNumberFrames,1);
    SuperpoweredShortIntToFloat(secondRight, secondFloatRight, inNumberFrames,1);
//
    int firstIntLeft[inNumberFrames];
    int secondIntRight[inNumberFrames];
    
    SuperpoweredFloatToInt(firstFloatLeft, firstIntLeft, inNumberFrames,1);
    SuperpoweredFloatToInt(secondFloatRight, secondIntRight, inNumberFrames,1);
    
    //=================================================
    
    sParamDsp.readL = firstIntLeft;
    sParamDsp.readR = secondIntRight;
    sParamDsp.outL = firstIntLeft;
    sParamDsp.outR = secondIntRight;
    
    sParamDsp.angle = 90;
    sParamDsp.distance = 30;
    
    ym_proc_fram(&sParamDsp, baseAdr);
    //=================================================
    
    
    
    SuperpoweredIntToFloat(firstIntLeft, firstFloatLeft, inNumberFrames,1);
    SuperpoweredIntToFloat(secondIntRight, secondFloatRight, inNumberFrames,1);
    
    SuperpoweredFloatToShortInt(firstFloatLeft, firstLeft, inNumberFrames,1);
    SuperpoweredFloatToShortInt(secondFloatRight, secondRight, inNumberFrames,1);
//
    for(int i = 0; i < inNumberFrames; i++) {
        bgmSectionBufferSint16[i] = firstLeft[i];
        bgmSectionBufferSint16[i + inNumberFrames] = secondRight[i];
    }
    
 //--------------------------------------------
    //play
    for (int i=0; i < ioData->mNumberBuffers; i++) {
        AudioBuffer buffer = ioData->mBuffers[i];
        UInt32 size = max(buffer.mDataByteSize, [audioProcessor audioBuffer].mDataByteSize);
        memcpy(buffer.mData, bgmSectionBufferSint16, size);
        buffer.mDataByteSize = size;
    }
    return noErr;
}


AudioBufferList *AudioBufferListCreate(AudioStreamBasicDescription audioFormat, int frameCount) {
    int numberOfBuffers   = audioFormat.mFormatFlags & kAudioFormatFlagIsNonInterleaved ? audioFormat.mChannelsPerFrame : 1; // 1
    int channelsPerBuffer = audioFormat.mFormatFlags & kAudioFormatFlagIsNonInterleaved ? 1 : audioFormat.mChannelsPerFrame; // 2
    int bytesPerBuffer = audioFormat.mBytesPerFrame * frameCount;
    AudioBufferList *audio = (AudioBufferList *)malloc(sizeof(AudioBufferList) + (numberOfBuffers-1)*sizeof(AudioBuffer));
    if ( !audio ) {
        return NULL;
    }
    audio->mNumberBuffers = numberOfBuffers; // 1
    for ( int i=0; i<numberOfBuffers; i++ ) {
        if ( bytesPerBuffer > 0 ) {
            audio->mBuffers[i].mData = calloc(bytesPerBuffer, 1);
            if ( !audio->mBuffers[i].mData ) {
                for ( int j=0; j<i; j++ ) free(audio->mBuffers[j].mData);
                free(audio);
                return NULL;
            }
        } else {
            audio->mBuffers[i].mData = NULL;
        }
        audio->mBuffers[i].mDataByteSize = bytesPerBuffer;     // 4 * total
        audio->mBuffers[i].mNumberChannels = channelsPerBuffer;// 2
    }
    return audio;
}





@end

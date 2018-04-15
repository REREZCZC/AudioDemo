
#import "AudioPlayer.h"

#import <YINMANAUDIOSDK/subrt.h>

#include<string.h>
#import <pthread.h>


#define NUM_FFT 512
#define NUM_FRAM 256
#define MAX_FRAM 360
#define START_ANGL 45


float                delta;
float angle = 45;


unsigned  int       memSize;
int                 sampleRate;
static unsigned int inputChanNum;
void                *pMem = NULL;
static		int		*out_L= NULL;
static		int		*out_R= NULL;
static int *tempDataLeft = NULL;
static int *tempDataRight = NULL;
void *baseAdr;
float SPEED = 20;
float distance;
float _reverber;
float _delay;

static int *processOut = NULL;
static int *processOutChannel_1 = NULL;
static int *processOutChannel_2 = NULL;
struct ctrlDSP	sCtrlDsp;

UInt32 channelCount;
UInt64 total;
AudioUnit     outputUnit;

//struct param_DSP sParamDSP;

//====================================================================================
AudioStreamBasicDescription _outputFormat;
NSURL     *_audioFileURL;
float     *outputBuffer; //left data
float     *holdingBuffer;//right data

static pthread_mutex_t outputAudioFileLock;
ExtAudioFileRef _outputFile;
float currentTime;
dispatch_source_t callbackTimer;
UInt64 totalFramesInFile;

int numbers = 0;
int temp;
//====================================================================================




static OSStatus inputRenderCallback (
                                     
                                     void                        *inRefCon,      // A pointer to a struct containing the complete audio data
                                     //    to play, as well as state information such as the
                                     //    first sample to play on this invocation of the callback.
                                     AudioUnitRenderActionFlags  *ioActionFlags, // Unused here. When generating audio, use ioActionFlags to indicate silence
                                     //    between sounds; for silence, also memset the ioData buffers to 0.
                                     const AudioTimeStamp        *inTimeStamp,   // Unused here.
                                     UInt32                      inBusNumber,    // The mixer unit input bus that is requesting some new
                                     //        frames of audio data to play.
                                     UInt32                      inNumberFrames, // The number of frames of audio to provide to the buffer(s)
                                     //        pointed to by the ioData parameter.
                                     AudioBufferList             *ioData         // On output, the audio data to play. The callback's primary
//        responsibility is to fill the buffer(s) in the
//        AudioBufferList.
) {
    
    
    
    soundStruct    *soundStructPointer   = (soundStruct*) inRefCon;
    UInt32            frameTotalForSound = soundStructPointer->frameCount;
    BOOL              isStereo           = soundStructPointer->isStereo;
    
    // Declare variables to point to the audio buffers. Their data type must match the buffer data type.
    AudioUnitSampleType *dataInFirst;
    AudioUnitSampleType *dataInSecond;
    AudioUnitSampleType *dataInThird;
    AudioUnitSampleType *dataInFouth;

    
    dataInFirst  = soundStructPointer->audioDataChannelFirst;
    dataInSecond = soundStructPointer->audioDataChannelSecond;
    dataInThird  = soundStructPointer->audioDataChannelThird;
    dataInFouth  = soundStructPointer->audioDataChannelFouth;

    // Establish pointers to the memory into which the audio from the buffers should go. This reflects
    //    the fact that each Multichannel Mixer unit input bus has two channels, as specified by this app's
    //    graphStreamFormat variable.
    AudioUnitSampleType *outSamplesChannelFirst;
    AudioUnitSampleType *outSamplesChannelSecond;
    AudioUnitSampleType *outSamplesChannelThird;
    AudioUnitSampleType *outSamplesChannelFouth;
    
    //The audio data to play. left and right
    outSamplesChannelFirst   = (AudioUnitSampleType *) ioData->mBuffers[0].mData;
    outSamplesChannelSecond  = (AudioUnitSampleType *) ioData->mBuffers[1].mData;
    outSamplesChannelThird   = (AudioUnitSampleType *) ioData->mBuffers[2].mData;
    outSamplesChannelFouth   = (AudioUnitSampleType *) ioData->mBuffers[3].mData;
    
    // Get the sample number, as an index into the sound stored in memory,
    //    to start reading data from.
    UInt32 sampleNumber = soundStructPointer->sampleNumber;
    

    int i;
    int j;
    AudioUnitSampleType *allData;
    AudioUnitSampleType *outData;
    AudioUnitSampleType *sanData;
    
    
    allData = (AudioUnitSampleType *)malloc(sizeof(AudioUnitSampleType)*4*inNumberFrames);
    outData = (AudioUnitSampleType *)malloc(sizeof(AudioUnitSampleType)*2*inNumberFrames);
    sanData = (AudioUnitSampleType *)malloc(sizeof(AudioUnitSampleType)*2*inNumberFrames);

    
    
    for (i = 0; i < inNumberFrames; i++) {

        allData[4*i]   = dataInFirst[i+sampleNumber];
        allData[4*i+1] = dataInSecond[i+sampleNumber];
        allData[4*i+2] = dataInThird[i+sampleNumber];
        allData[4*i+3] = dataInFouth[i+sampleNumber];
    }
    

    for (int i = 0; i < 4; i++) {
        ym_proc_fram(outData, &allData[i*1024], 256, &sCtrlDsp, baseAdr);
        memcpy(&sanData[i*512], outData, sizeof(AudioUnitSampleType)*512);

    }
    
    
    
    
    memcpy(outputBuffer, sanData, sizeof(AudioUnitSampleType) *inNumberFrames*2);
    int * tmp     = (int*)outputBuffer;
    
    for(i = 0; i < inNumberFrames*2; i++)
    {
        outputBuffer[i]  = (float)tmp[i] / 65536.0 / 256.0; // Q24 format from kAudioUnitSampleFractionBits = 24
    }
    NSLog(@"saveToFile = %ld",(long)outputBuffer);
    writeNewAuido(outputBuffer, inNumberFrames, 2);
    
    

    
    for (i = 0; i < inNumberFrames; i++) {
        dataInFirst[i+sampleNumber] = sanData[2*i];
        dataInSecond[i+sampleNumber] = sanData[2*i+1];
    }
    

//    for (i = 0; i < inNumberFrames; i++) {
//        dataInFirst[i+sampleNumber] = dataInFirst[i+sampleNumber] + dataInThird[i+sampleNumber];
//        dataInSecond[i+sampleNumber] = dataInSecond[i+sampleNumber] + dataInFouth[i+sampleNumber];
//    
//    }
    

    
    
    
    
    
    //OUT
    // Fill the buffer or buffers pointed at by *ioData with the requested number of samples
    //    of audio from the sound stored in memory.
    
    
        for (UInt32 frameNumber = 0; frameNumber < inNumberFrames; ++frameNumber) {
            
            // 0 ~~ 1024
            outSamplesChannelFirst[frameNumber]  = dataInFirst[sampleNumber];
            outSamplesChannelSecond[frameNumber] = dataInSecond[sampleNumber];


            sampleNumber++;
            
            
            if (sampleNumber >= frameTotalForSound) {
                sampleNumber = 0;
                OSStatus status = AudioOutputUnitStop(outputUnit);
                printf("stop");
                pthread_mutex_lock( &outputAudioFileLock );
                ExtAudioFileDispose(_outputFile);
                pthread_mutex_unlock( &outputAudioFileLock );
                
            }
            
            
        }

    
    
    // Update the stored sample number so, the next time this callback is invoked, playback resumes
    //    at the correct spot.
    soundStructPointer->sampleNumber = sampleNumber;

    free(allData);

    return noErr;
}

@implementation AudioPlayer


- (id) init {
    
    
    
    self = [super init];
    if (!self) return nil;
    
    memset(&soundStructInfo, 0, sizeof(soundStructInfo));
    sampleRate = 44100.0;
    
    packetCount = 0;
    
//     AUChannelInfo *inpu = {-1,-1};
//    inputAndOutputChannelNumber = inpu;
    
    //读取将要处理的文件
    [self readAudioFilesIntoMemory];
    
    //配置Audio Unit
    [self configureUnit];

    //初始化3D音效处理器
    [self initializeProcessor];
    
    //创建输出文件的URL
    NSURL *outputUrl = [self getDocumentPathUrlFromStringPathComponent:@"/3DoutputFile.m4a"];
    
    //使用URL创建文件,并配置一些参数
    [self WithAudioFileURL:outputUrl samplingRate:sampleRate numChannels:2];
    
    return self;
}


//在Document文件夹下面创建一个URL
- (NSURL *) getDocumentPathUrlFromStringPathComponent: (NSString *)pathComponent {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *outputPathString = [documentsDirectory stringByAppendingPathComponent:pathComponent];
    NSURL *outUrl = [NSURL fileURLWithPath:outputPathString];
    
    return outUrl;
}

//读取文件
- (void) readAudioFilesIntoMemory {

    NSURL *guitarLoop = [[NSBundle mainBundle] URLForResource: @"B_form"
                                                withExtension: @"wav"];
    
    ExtAudioFileRef audioFileObject = 0;
    
    OSStatus result = ExtAudioFileOpenURL ((__bridge CFURLRef)guitarLoop, &audioFileObject);
    
    UInt32 frameLengthPropertySize = sizeof (totalFramesInFile);
    
    result =    ExtAudioFileGetProperty (
                                         audioFileObject,  //he extended audio file object to get a property value from.
                                         kExtAudioFileProperty_FileLengthFrames,   //The property whose value you want.
                                         &frameLengthPropertySize,  //On input, the size of the memory pointed to by the outPropertyData parameter. On output, the size of the property value.
                                         &totalFramesInFile  //On output, the property value you wanted to get.
                                         );
    
    total = totalFramesInFile;
    
    // Assign the frame count to the soundStructArray instance variable
    soundStructInfo.frameCount = (UInt32)totalFramesInFile;
    
    // Get the audio file's number of channels.
    AudioStreamBasicDescription fileAudioFormat = {0};
    UInt32 formatPropertySize = sizeof (fileAudioFormat);
    
    result =    ExtAudioFileGetProperty (
                                         audioFileObject,
                                         kExtAudioFileProperty_FileDataFormat,
                                         &formatPropertySize,
                                         &fileAudioFormat
                                         );
    
    channelCount = fileAudioFormat.mChannelsPerFrame;//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    // Allocate memory in the soundStructArray instance variable to hold the left channel,
    //    or mono, audio data

    if (soundStructInfo.audioDataChannelFirst) {
        free(soundStructInfo.audioDataChannelFirst);
    }
    if (soundStructInfo.audioDataChannelSecond) {
        free(soundStructInfo.audioDataChannelSecond);
    }
    if (soundStructInfo.audioDataChannelThird) {
        free(soundStructInfo.audioDataChannelThird);
    }
    if (soundStructInfo.audioDataChannelFouth) {
        free(soundStructInfo.audioDataChannelFouth);
    }
    

    soundStructInfo.audioDataChannelFirst = (AudioUnitSampleType *) calloc(totalFramesInFile, sizeof(AudioUnitSampleType));
    soundStructInfo.audioDataChannelSecond = (AudioUnitSampleType *) calloc(totalFramesInFile, sizeof(AudioUnitSampleType));
    soundStructInfo.audioDataChannelThird = (AudioUnitSampleType *) calloc(totalFramesInFile, sizeof(AudioUnitSampleType));
    soundStructInfo.audioDataChannelFouth = (AudioUnitSampleType *) calloc(totalFramesInFile, sizeof(AudioUnitSampleType));
    

//    AudioStreamBasicDescription importFormat = {0};
    size_t bytesPerSample = sizeof (AudioUnitSampleType);
    
    // Fill the application audio format struct's fields to define a linear PCM,
    //        stereo, noninterleaved stream at the hardware sample rate.
    importFormat.mFormatID          = kAudioFormatLinearPCM;
    importFormat.mFormatFlags       = kAudioFormatFlagsAudioUnitCanonical;
    importFormat.mBytesPerPacket    = (UInt32)bytesPerSample;
    importFormat.mFramesPerPacket   = 1;
    importFormat.mBytesPerFrame     = (UInt32)bytesPerSample;
    importFormat.mBitsPerChannel    = 8 * (UInt32)bytesPerSample;
    importFormat.mSampleRate        = sampleRate;
    importFormat.mChannelsPerFrame  = 4;
    
    soundStructInfo.isStereo = YES;
    
    fileASBD = importFormat;
        
    // Assign the appropriate mixer input bus stream data format to the extended audio
    //        file object. This is the format used for the audio data placed into the audio
    //        buffer in the SoundStruct data structure, which is in turn used in the
    //        inputRenderCallback callback function.
    
   
    result =    ExtAudioFileSetProperty (
                                         audioFileObject,
                                         kExtAudioFileProperty_ClientDataFormat,
                                         sizeof (importFormat),
                                         &importFormat
                                         );

    
    // Set up an AudioBufferList struct, which has two roles:
    //
    //        1. It gives the ExtAudioFileRead function the configuration it
    //            needs to correctly provide the data to the buffer.
    //
    //        2. It points to the soundStructArray[audioFile].audioDataLeft buffer, so
    //            that audio data obtained from disk using the ExtAudioFileRead function
    //            goes to that buffer
    
    // Allocate memory for the buffer list struct according to the number of
    //    channels it represents.

    AudioBufferList *bufferList;
    bufferList = (AudioBufferList *) malloc (sizeof (AudioBufferList) + sizeof (AudioBuffer) * (channelCount - 1));

    // initialize the mNumberBuffers member
    bufferList->mNumberBuffers = channelCount;//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    
    // initialize the mBuffers member to 0
    AudioBuffer emptyBuffer = {0};
    size_t arrayIndex;
    for (arrayIndex = 0; arrayIndex < channelCount; arrayIndex++) {
        bufferList->mBuffers[arrayIndex] = emptyBuffer;
    }
    
    
    //IN
    // set up the AudioBuffer structs in the buffer list
    bufferList->mBuffers[0].mNumberChannels  = 1;
    bufferList->mBuffers[0].mDataByteSize    = totalFramesInFile * sizeof (AudioUnitSampleType);
    bufferList->mBuffers[0].mData            = soundStructInfo.audioDataChannelFirst;
    
    
        bufferList->mBuffers[1].mNumberChannels  = 1;
        bufferList->mBuffers[1].mDataByteSize    = totalFramesInFile * sizeof (AudioUnitSampleType);
        bufferList->mBuffers[1].mData            = soundStructInfo.audioDataChannelSecond;
        
        bufferList->mBuffers[2].mNumberChannels  = 1;
        bufferList->mBuffers[2].mDataByteSize    = totalFramesInFile * sizeof (AudioUnitSampleType);
        bufferList->mBuffers[2].mData            = soundStructInfo.audioDataChannelThird;
        
        bufferList->mBuffers[3].mNumberChannels  = 1;
        bufferList->mBuffers[3].mDataByteSize    = totalFramesInFile * sizeof (AudioUnitSampleType);
        bufferList->mBuffers[3].mData            = soundStructInfo.audioDataChannelFouth;

    
    // Perform a synchronous, sequential read of the audio data out of the file and
    //    into the soundStructArray[audioFile].audioDataLeft and (if stereo) .audioDataRight members.
    UInt32 numberOfPacketsToRead = (UInt32) totalFramesInFile;
    
    //read buffer
    
    result = ExtAudioFileRead (
                               audioFileObject,
                               &numberOfPacketsToRead,
                               bufferList
                               );
 
    free (bufferList);
    
    if (noErr != result) {
        
        // If reading from the file failed, then free the memory for the sound buffer.
        free (soundStructInfo.audioDataChannelFirst);
        soundStructInfo.audioDataChannelFirst = 0;
        
        if (4 == channelCount) {
            free (soundStructInfo.audioDataChannelSecond);
            soundStructInfo.audioDataChannelSecond = 0;
            
            
            free (soundStructInfo.audioDataChannelThird);
            soundStructInfo.audioDataChannelThird = 0;
            
            free (soundStructInfo.audioDataChannelFouth);
            soundStructInfo.audioDataChannelFouth = 0;
            
        }
        
        ExtAudioFileDispose (audioFileObject);            
        return;
    }
    
    // Set the sample index to zero, so that playback starts at the 
    //    beginning of the sound.
    soundStructInfo.sampleNumber = 0;
    
    // Dispose of the extended audio file object, which also
    //    closes the associated file.
    ExtAudioFileDispose (audioFileObject);
    
}


//创建文件,准备写入数据
- (void)WithAudioFileURL:(NSURL *)urlToAudioFile samplingRate:(float)thisSamplingRate numChannels:(UInt32)thisNumChannels {
        
        // Open a reference to the audio file
        _audioFileURL         = urlToAudioFile;
        CFURLRef audioFileRef = (__bridge CFURLRef)_audioFileURL;
        
        AudioStreamBasicDescription outputFileDesc = {48000.0, kAudioFormatMPEG4AAC, 0, 0, 1024, 0, thisNumChannels, 0, 0};
        
        CheckError(ExtAudioFileCreateWithURL(audioFileRef, kAudioFileM4AType, &outputFileDesc, NULL, kAudioFileFlags_EraseFile, &_outputFile), "Creating file");
    
        _outputFormat.mSampleRate       = sampleRate;
        _outputFormat.mFormatID         = kAudioFormatLinearPCM;
        _outputFormat.mFormatFlags      = kAudioFormatFlagIsFloat;
        _outputFormat.mBytesPerPacket   = 4*thisNumChannels;
        _outputFormat.mFramesPerPacket  = 1;
        _outputFormat.mBytesPerFrame    = 4*thisNumChannels;
        _outputFormat.mChannelsPerFrame = thisNumChannels;
        _outputFormat.mBitsPerChannel   = 32;
    
        // Apply the format to our file
        ExtAudioFileSetProperty(_outputFile, kExtAudioFileProperty_ClientDataFormat, sizeof(AudioStreamBasicDescription), &_outputFormat);
        
        
        // Arbitrary buffer sizes that don't matter so much as long as they're "big enough"
       outputBuffer  = (float *)calloc(2*sampleRate, sizeof(float));

    
        pthread_mutex_init(&outputAudioFileLock, NULL);
        
        // mutex here //
        if( 0 == pthread_mutex_trylock( &outputAudioFileLock ) )
        {
            CheckError( ExtAudioFileWriteAsync(_outputFile, 0, NULL), "Initializing audio file");
        }
        pthread_mutex_unlock( &outputAudioFileLock );
}


//将音频数据写入文件
void writeNewAuido(float *newData, UInt32 thisNumFrames, UInt32 thisNumChannels) {
    UInt32 numIncomingBytes = thisNumFrames*thisNumChannels*sizeof(float);
    
    memcpy(outputBuffer, newData, numIncomingBytes);
    
    AudioBufferList outgoingAudio;
    outgoingAudio.mNumberBuffers = 1;
    
    outgoingAudio.mBuffers[0].mNumberChannels = thisNumChannels;
    outgoingAudio.mBuffers[0].mDataByteSize = numIncomingBytes;
    outgoingAudio.mBuffers[0].mData = outputBuffer;
    

    if( 0 == pthread_mutex_trylock( &outputAudioFileLock ) )
    {
        
        ExtAudioFileWriteAsync(_outputFile, thisNumFrames, &outgoingAudio);// async operation
    }
    pthread_mutex_unlock( &outputAudioFileLock );
    
    // Figure out where we are in the file
    SInt64 frameOffset = 0;
    ExtAudioFileTell(_outputFile, &frameOffset);
    currentTime = (float)frameOffset / sampleRate;
    
}


void CheckError(OSStatus error, const char *operation) {
    if (error == noErr) return;
    
    char str[20];
    // see if it appears to be a 4-char-code
    *(UInt32 *)(str + 1) = CFSwapInt32HostToBig(error);
    if (isprint(str[1]) && isprint(str[2]) && isprint(str[3]) && isprint(str[4])) {
        str[0] = str[5] = '\'';
        str[6] = '\0';
    } else
        // no, format it as an integer
        sprintf(str, "%d", (int)error);
    
    fprintf(stderr, "Error: %s (%s)\n", operation, str);
    
    exit(1);
}


- (void)configureUnit {
    
    OSStatus status;
    AudioComponentDescription desc;
    desc.componentType         = kAudioUnitType_Output;
    desc.componentSubType      = kAudioUnitSubType_RemoteIO;
    desc.componentFlags        = 0;
    desc.componentFlagsMask    = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Get component
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    
    // Get audio units
    status = AudioComponentInstanceNew(inputComponent, &outputUnit);
    // Enable IO for recording
    UInt32 flag = 1;
    status = AudioUnitSetProperty(outputUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  0,
                                  &flag,
                                  sizeof(flag));
    UInt32 busCount   = 1;
    status = AudioUnitSetProperty (
                                   outputUnit,
                                   kAudioUnitProperty_ElementCount,
                                   kAudioUnitScope_Input,
                                   0,
                                   &busCount,
                                   sizeof (busCount)
                                   );
    
    // Increase the maximum frames per slice allows the mixer unit to accommodate the
    //    larger slice size used when the screen is locked.
    UInt32 maximumFramesPerSlice = 4096;
    status = AudioUnitSetProperty (
                                   outputUnit,
                                   kAudioUnitProperty_MaximumFramesPerSlice,
                                   kAudioUnitScope_Global,
                                   0,
                                   &maximumFramesPerSlice,
                                   sizeof (maximumFramesPerSlice)
                                   );
    
    AURenderCallbackStruct callbackStruct;
    
    // Set output callback
    callbackStruct.inputProc = &inputRenderCallback;   //AURenderCallbackStruct
    callbackStruct.inputProcRefCon = &soundStructInfo; //Used by a host when registering a callback with the audio unit to provide input
    status = AudioUnitSetProperty(outputUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Input,
                                  0,
                                  &callbackStruct, 
                                  sizeof(callbackStruct));
    
    // Fill the application audio format struct's fields to define a linear PCM,
    //        stereo, noninterleaved stream at the hardware sample rate.
    
    status = AudioUnitSetProperty (
                                   outputUnit,
                                   kAudioUnitProperty_StreamFormat,
                                   kAudioUnitScope_Input,
                                   0,
                                   &fileASBD,
                                   sizeof (fileASBD)
                                   );
    status = AudioUnitSetProperty (
                                   outputUnit,
                                   kAudioUnitProperty_SampleRate,
                                   kAudioUnitScope_Input,
                                   0,
                                   &sampleRate,
                                   sizeof (sampleRate)
                                   );
    

    
    
    
    AUChannelInfo *inputAndOutputChannelNumber = {-1,-1};
    status = AudioUnitSetProperty(outputUnit,
                                  kAudioUnitProperty_SupportedNumChannels,
                                  kAudioUnitScope_Global,
                                  0,
                                  &inputAndOutputChannelNumber,
                                  sizeof(inputAndOutputChannelNumber)
                                  );
    
    
    

    
    status = AudioUnitInitialize(outputUnit);

}


- (void)initializeProcessor {
    inputChanNum = 4;
    memSize = ym_9con_query();
    
    baseAdr = malloc(memSize);
    
    ym_9con_open( baseAdr,memSize);
    
    ym_song_ini(inputChanNum, NON_INTERLEAVE_STRIDE, baseAdr);

}


-(void)passSpeed:(CGFloat)speed {
    SPEED = speed;
}

- (void)passdis:(CGFloat)dis {
    distance = dis;
}


-(void)passReverber:(CGFloat)reverber {
    _reverber = reverber;
}

- (void)passDelay:(CGFloat)delay {
    _delay = delay;
}




- (void)play {
    [self readAudioFilesIntoMemory];
    OSStatus status = AudioOutputUnitStart(outputUnit);
}


- (void)stop {
    NSLog(@"stop");
    OSStatus status = AudioOutputUnitStop(outputUnit);
    soundStructInfo.sampleNumber = 0;
}


-(void)pause{
    OSStatus status = AudioOutputUnitStop(outputUnit);
}


- (void)dealloc{
    if (soundStructInfo.audioDataLeft != NULL) {
        free (soundStructInfo.audioDataLeft);
        soundStructInfo.audioDataLeft = NULL;
    }
    if (soundStructInfo.audioDataRight != NULL) {
        free (soundStructInfo.audioDataRight);
        soundStructInfo.audioDataRight = NULL;
    }
    
}






@end

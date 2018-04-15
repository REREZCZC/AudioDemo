/************************************************************************
 ;	Unpublished work.  Copyright 2016 YinMan Tech.
 ;	All Rights Reserved.
 ;
 ;	File Name:	YinManAudioAPI.h
 ;	Contents:	Audio processing application Programming interface
 ;
 *************************************************************************/
 
typedef enum {
    YinManAudioFs32000 = 0,
    YinManAudioFs44100,
    YinManAudioFs48000,
    YinManAudioFsCount
} YinManAudioFs;

typedef enum {
    YinManAudioMono = 0,
    YinManAudioLeftChannel = 0,
    YinManAudioStereo = 1,
    YinManAudioRightChannel = 1,
    YinManAudioMaxChannelCount = 2
} YinManAudioChannelMode;

typedef enum {
    YinManAudioProcessError_NOERR=0,
    YinManAudioProcessError_INVALID_PTR=1001,
    YinManAudioProcessError_MISMATCH_PARAMS=1002,
    YinManAudioProcessError_EXCEED_RANGE
} YinManAudioProcessError;

#define DEFAULT_BUFFER_SAMPLES  (256)   // The default number of samples in one frame to be processed

class ymKeepLeft {
public:
    ymKeepLeft();
    virtual ~ymKeepLeft();
    YinManAudioProcessError ymKeepLeftProcess(unsigned int *in, unsigned int *out, unsigned int nSamples, unsigned int nChannels, unsigned int modeEnable, unsigned int interleave);
    YinManAudioProcessError ymKeepLeftProcessShort(unsigned short *in, unsigned short *out, unsigned int nSamples, unsigned int nChannels, unsigned int modeEnable, unsigned int interleave);
    YinManAudioProcessError ymMuteProcessShort(unsigned short *in, unsigned short *out, unsigned int nSamples, unsigned int nChannels, unsigned int modeEnable, unsigned int interleave);
    YinManAudioProcessError ymMuteProcess(unsigned int *in, unsigned int *out, unsigned int nSamples, unsigned int nChannels, unsigned int modeEnable, unsigned int interleave);
};


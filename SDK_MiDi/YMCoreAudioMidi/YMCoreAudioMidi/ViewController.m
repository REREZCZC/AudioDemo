//
//  ViewController.m
//  YMCoreAudioMidi
//
//  Created by zhicheng ren on 2017/12/19.
//  Copyright © 2017年 yinkman. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#define BASECENTERY 120
@interface ViewController ()<UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource>
@property (readwrite) AUGraph   processingGraph;
@property (readwrite) AudioUnit samplerUnit;
@property (readwrite) AudioUnit ioUnit;
@end

@implementation ViewController
@synthesize processingGraph     = _processingGraph;
@synthesize samplerUnit         = _samplerUnit;
@synthesize ioUnit              = _ioUnit;

int noteValue;
bool pieceOfMusicModel;
UInt8 midiChannelInUse = 0;
AUGraph graph = 0;
AudioUnit synthUnit;
AUSamplerBankPresetData bpdata;
bool playing;
dispatch_queue_t q;
int program;

enum {
    kMidiMessage_ControlChange      = 0xB,
    kMidiMessage_ProgramChange      = 0xC,
    kMidiMessage_BankMSBControl     = 10,
    kMidiMessage_BankLSBControl     = 32,
    kMidiMessage_NoteOn             = 0x9,
    kMIDIMessage_NoteOff            = 0x8
};


- (void)viewDidLoad {
    [super viewDidLoad];
    pieceOfMusicModel = YES;
    q = dispatch_queue_create("my_concurrent_queue", DISPATCH_QUEUE_CONCURRENT);
    devicesArray = [[NSMutableArray alloc] initWithObjects:@" 1   Acoustic Grand Piano    大钢琴",@" 2    Bright Acoustic Piano    亮音钢琴",@" 3    Electric Grand Piano    大电钢琴",@" 4    Honky-tonk Piano    酒吧钢琴",@" 5    Electric Piano 1    电钢琴1",@" 6    Electric Piano 2    电钢琴2",@" 7    Harpsichord    大键琴",@" 8    Clavinet    电翼琴",@" 9    Celesta    钢片琴",@" 10    Glockenspiel    钟琴",@" 11    Musical box    音乐盒",@" 12    Vibraphone    颤音琴",@" 13    Marimba    马林巴琴",@" 14    Xylophone    木琴",@" 15    Tubular Bell    管钟",@" 16    Dulcimer    洋琴",@" 17    Drawbar Organ    音栓风琴",@" 18    Percussive Organ    敲击风琴",@" 19    Rock Organ    摇滚风琴",@" 20    Church organ    教堂管风琴",@" 21    Reed organ    簧风琴",@" 22    Accordion    手风琴",@" 23    Harmonica    口琴",@" 24    Tango Accordion    探戈手风琴",@" 25    Acoustic Guitar(nylon)    木吉他（尼龙弦）",@" 26    Acoustic Guitar(steel)    木吉他（钢弦）",@" 27    Electric Guitar(jazz)    电吉他（爵士）",@" 28    Electric Guitar(clean)    电吉他（清音）",@" 29    Electric Guitar(muted)    电吉他（闷音）",@" 30    Overdriven Guitar    电吉他（驱动音效）",@" 31    Distortion Guitar    电吉他（失真音效）",@" 32    Guitar harmonics    吉他泛音",@" 33    Acoustic Bass    贝斯",@" 34    Electric Bass(finger)    电贝斯（指奏）",@" 35    Electric Bass(pick)    电贝斯（拨奏）",@" 36    Fretless Bass    无品贝斯",@" 37    Slap Bass 1    捶鈎贝斯",@" 38    Slap Bass 2    捶鈎贝斯",@" 39    Synth Bass 1    合成贝斯1",@" 40    Synth Bass 2    合成贝斯2",@" 41    Violin    小提琴",@" 42    Viola    中提琴",@" 43    Cello    大提琴",@" 44   Contrabass    低音大提琴",@" 45    Tremolo Strings    颤弓弦乐",@" 46    Pizzicato Strings    弹拨弦乐",@" 47    Orchestral Harp    竖琴",@" 48    Timpani    定音鼓",@" 49    String Ensemble 1    弦乐合奏1",@" 50    String Ensemble 2    弦乐合奏2",@" 51    Synth Strings 1    合成弦乐1",@" 52    Synth Strings 2    合成弦乐2",@" 53    Voice Aahs    人声啊",@" 54    Voice Oohs    人声喔",@" 55    Synth Voice    合成人声",@" 56    Orchestra Hit    交响打击乐",@" 57    Trumpet    小号",@" 58    Trombone    长号",@" 59    Tuba    大号（吐巴号、低音号）",@" 60    Muted Trumpet    闷音小号",@" 61    French horn    法国号（圆号）",@" 62    Brass Section    铜管乐",@" 63    Synth Brass 1    合成铜管1",@" 64    Synth Brass 2    合成铜管2",@" 65    Soprano Sax    高音萨克斯风",@" 66    Alto Sax    中音萨克斯风",@" 67    Tenor Sax    次中音萨克斯风",@" 68    Baritone Sax    上低音萨克斯风",@" 69    Oboe    双簧管",@" 70    English Horn    英国管",@" 71    Bassoon    低音管（巴颂管）",@" 72    Clarinet    单簧管（黑管、竖笛）",@" 73    Piccolo    短笛",@" 74    Flute    长笛",@" 75    Recorder    竖笛",@" 76    Pan Flute    排笛",@" 77   Blown Bottle    瓶笛",@" 78    Shakuhachi    尺八",@" 79    Whistle    哨子",@" 80    Ocarina    陶笛",@" 81    Lead 1(square)    方波",@" 82    Lead 2(sawtooth)    锯齿波",@" 83    Lead 3(calliope)    汽笛风琴",@" 84    Lead 4(chiff)    合成吹管",@" 85    Lead 5(charang)    合成电吉他",@" 86    Lead 6(voice)    人声键盘",@" 87    Lead 7(fifths)    五度音",@" 88    Lead 8(bass + lead)    贝斯吉他合奏",@" 89    Pad 1(new age)    新世纪",@" 90    Pad 2(warm)    温暖",@" 91    Pad 3(polysynth)    多重合音",@" 92    Pad 4(choir)    人声合唱",@" 93    Pad 5(bowed)    玻璃",@" 94    Pad 6(metallic)    金属",@" 95    Pad 7(halo)    光华",@" 96    Pad 8(sweep)    扫掠",@" 97    FX 1(rain)    雨",@" 98    FX 2(soundtrack)    电影音效",@" 99    FX 3(crystal)    水晶",@" 100    FX 4(atmosphere)    气氛",@" 101    FX 5(brightness)    明亮",@" 102    FX 6(goblins)    魅影",@" 103    FX 7(echoes)    回音",@" 104    FX 8(sci-fi)    科幻",@" 105    Sitar    西塔琴",@" 106    Banjo    五弦琴（斑鸠琴）",@" 107    Shamisen    三味线",@" 108    Koto    十三弦琴（古筝）",@" 109    Kalimba    卡林巴铁片琴",@" 110    Bagpipe    苏格兰风笛",@" 111    Fiddle    古提琴",@" 112    Shanai    兽笛，发声机制类似唢呐",@" 113    Tinkle Bell    叮当铃",@" 114    Agogo    阿哥哥鼓",@" 115    Steel Drums    钢鼓",@" 116    Woodblock    木鱼",@" 117    Taiko Drum    太鼓",@" 118    Melodic Tom    定音筒鼓",@" 119    Synth Drum    合成鼓",@" 120    Reverse Cymbal    逆转钹声",@" 121    Guitar Fret Noise    吉他滑弦杂音",@" 122    Breath Noise    呼吸杂音",@" 123    Seashore    海岸",@" 124    Bird Tweet    鸟鸣",@" 125    Telephone Ring    电话铃声",@" 126    Helicopter    直升机",@" 127    Applause    拍手",@" 128    Gunshot    枪声" , nil];
    
    _segment = [[UISegmentedControl alloc] initWithItems:@[@"一段音乐",@"单点"]];
    _segment.frame = CGRectMake(0, 0, self.view.frame.size.width - 40, 35);
    _segment.center = CGPointMake(self.view.frame.size.width /2, 60);
    _segment.selectedSegmentIndex = 0;
    [_segment addTarget:self action:@selector(segmentDidChangeValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_segment];
    
    _playButton = [[UIButton alloc] init];
    _playButton.frame = CGRectMake(0,0 , 70, 35);
    _playButton.backgroundColor = [UIColor orangeColor];
    _playButton.layer.borderWidth = 1.5;
    _playButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _playButton.layer.cornerRadius = 6;
    [_playButton setTitle:@"Play" forState:UIControlStateNormal];
    [_playButton addTarget:self action:@selector(playButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    _playButton.center = CGPointMake(self.view.frame.size.width/4-30, BASECENTERY);
    [self.view addSubview:_playButton];
    
    _deviceName = [[UILabel alloc] init];
    _deviceName.text = @"Instrument";
    _deviceName.frame = CGRectMake(0, 0, 220, 35);
    _deviceName.layer.borderWidth = 1.5;
    _deviceName.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _deviceName.layer.cornerRadius = 6;
    _deviceName.textAlignment = NSTextAlignmentCenter;
    _deviceName.center = CGPointMake(self.view.frame.size.width/2 + 50, BASECENTERY);
    [self.view addSubview:_deviceName];
    
    _noteValueSlider = [[UISlider alloc] init];
    _noteValueSlider.frame = CGRectMake(25, 0, 240, 35);
    _noteValueSlider.center = CGPointMake(self.view.bounds.size.width / 2 - 30, BASECENTERY + 60);
    _noteValueSlider.maximumValue = 127;
    _noteValueSlider.minimumValue = 0;
    _noteValueSlider.value = 60;
    [_noteValueSlider addTarget:self action:@selector(noteValueDidchanged:) forControlEvents:UIControlEventTouchDragInside];
    [self.view addSubview: _noteValueSlider];

    
    _currentNoteValueLabel = [[UILabel alloc] init];
    _currentNoteValueLabel.frame = CGRectMake(0, 0, 50, 35);
    _currentNoteValueLabel.center = CGPointMake(_noteValueSlider.frame.size.width + _noteValueSlider.frame.origin.x + 40, BASECENTERY + 60);
    _currentNoteValueLabel.textAlignment = NSTextAlignmentCenter;
    _currentNoteValueLabel.layer.borderWidth = 1.5;
    _currentNoteValueLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _currentNoteValueLabel.layer.cornerRadius = 6;
    _currentNoteValueLabel.text = [NSString stringWithFormat:@"%.f",_noteValueSlider.value];
    _currentNoteValueLabel.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_currentNoteValueLabel];
    

    
    deviceNameTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, self.view.frame.size.height-200)];
    deviceNameTable.backgroundColor = [UIColor lightGrayColor];
    deviceNameTable.delegate = self;
    deviceNameTable.dataSource =self;
    [self.view addSubview:deviceNameTable];
    noteValue = _noteValueSlider.value;
}





- (void) playButtonDidTap:(UIButton* )button {
    if (!button.selected) {
        if (!pieceOfMusicModel) {//单点模式
            dispatch_async(q, ^{
                if (graph) {
                    DisposeAUGraph (graph);
                }
                
                [self createSinglerPressModelGraph];
                UInt32 onVelocity = 127;
                UInt32 noteOnCommand =     kMidiMessage_NoteOn << 4 | midiChannelInUse;
                MusicDeviceMIDIEvent(synthUnit, noteOnCommand, noteValue, onVelocity, 0);
            });
            
        }else {//一段音乐模式
            if (_processingGraph) {
                AUGraphStop(_processingGraph);
                DisposeAUGraph(_processingGraph);
            }
            noteValue = [_currentNoteValueLabel.text intValue];
            [self midiTest];
            [self play];
        }
    }else {
        if (!pieceOfMusicModel) {
        }else {
            [self stop];
        }
    }
}





-(void) midiTest {
    OSStatus result = noErr;
    
    [self createAUGraph];
    [self configureAndStartAudioProcessingGraph: self.processingGraph];
    
    // Create a client
    MIDIClientRef virtualMidi;
    result = MIDIClientCreate(CFSTR("Virtual Client"),
                              MyMIDINotifyProc,//An optional (may be NULL) block
                              NULL,
                              &virtualMidi);
    
    NSAssert( result == noErr, @"MIDIClientCreate failed. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    MIDIEndpointRef virtualEndpoint;
    NSString *virtualDestination = @"Virtual Destination";
    
    result = MIDIDestinationCreate(virtualMidi,(__bridge CFStringRef _Nonnull)(virtualDestination), MyMIDIReadProc, self.samplerUnit, &virtualEndpoint);
    
    NSAssert( result == noErr, @"MIDIDestinationCreate failed. Error code: %d '%.4s'", (int) result, (const char *)&result);

    NewMusicSequence(&ms);
    
    NSString *midiFilePath = [[NSBundle mainBundle]
                              pathForResource:@"simpletest"
                              ofType:@"mid"];
    
    NSURL * midiFileURL = [NSURL fileURLWithPath:midiFilePath];
    MusicSequenceFileLoad(ms, (__bridge CFURLRef) midiFileURL, 0, 0);
    NewMusicPlayer(&mp);
    
    MusicSequenceSetMIDIEndpoint(ms, virtualEndpoint);
    
    NSURL *presetURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"FantaGM32" ofType:@"sf2"]];
    
    [self loadFromDLSOrSoundFont: (NSURL *)presetURL withPatch: (int)deviceNumber];
    
    MusicPlayerSetSequence(mp, ms);
    MusicPlayerPreroll(mp);
    [self setLongestTrackLength];
}

- (BOOL) createAUGraph {
    
    OSStatus result = noErr;
    AUNode samplerNode, ioNode;
    
    AudioComponentDescription cd = {};
    cd.componentManufacturer     = kAudioUnitManufacturer_Apple;
    
    result = NewAUGraph (&_processingGraph);
    NSCAssert (result == noErr, @"Unable to create an AUGraph object. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    cd.componentType = kAudioUnitType_MusicDevice; // type - music device
    cd.componentSubType = kAudioUnitSubType_Sampler; // sub type - sampler to convert our MIDI
    result = AUGraphAddNode (self.processingGraph, &cd, &samplerNode);
    NSCAssert (result == noErr, @"Unable to add the Sampler unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    cd.componentType = kAudioUnitType_Output;  // Output
    cd.componentSubType = kAudioUnitSubType_RemoteIO;  // Output to speakers
    result = AUGraphAddNode (self.processingGraph, &cd, &ioNode);
    NSCAssert (result == noErr, @"Unable to add the Output unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AUGraphOpen (self.processingGraph);
    NSCAssert (result == noErr, @"Unable to open the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AUGraphConnectNodeInput (self.processingGraph, samplerNode, 0, ioNode, 0);
    NSCAssert (result == noErr, @"Unable to interconnect the nodes in the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AUGraphNodeInfo (self.processingGraph, samplerNode, 0, &_samplerUnit);
    NSCAssert (result == noErr, @"Unable to obtain a reference to the Sampler unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    result = AUGraphNodeInfo (self.processingGraph, ioNode, 0, &_ioUnit);
    NSCAssert (result == noErr, @"Unable to obtain a reference to the I/O unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    return YES;
}

- (void) configureAndStartAudioProcessingGraph: (AUGraph) graph {
    
    OSStatus result = noErr;
    if (graph) {
        
        // Initialize the audio processing graph.
        result = AUGraphInitialize (graph);
        NSAssert (result == noErr, @"Unable to initialze AUGraph object. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        // Start the graph
        result = AUGraphStart (graph);
        NSAssert (result == noErr, @"Unable to start audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        // Print out the graph to the console
        CAShow (graph);
    }
}

-(OSStatus) loadFromDLSOrSoundFont: (NSURL *)bankURL withPatch: (int)presetNumber {
    
    OSStatus result = noErr;
    
    // fill out a bank preset data structure
    AUSamplerBankPresetData bpdata;
    bpdata.bankURL  = (__bridge CFURLRef) bankURL;
    bpdata.bankMSB  = kAUSampler_DefaultMelodicBankMSB;
    bpdata.bankLSB  = kAUSampler_DefaultBankLSB;
    bpdata.presetID = (UInt8) presetNumber;
    
    // set the kAUSamplerProperty_LoadPresetFromBank property
    result = AudioUnitSetProperty(self.samplerUnit,
                                  kAUSamplerProperty_LoadPresetFromBank,
                                  kAudioUnitScope_Global,
                                  0,
                                  &bpdata,
                                  sizeof(bpdata));
    
    // check for errors
    NSCAssert (result == noErr,
               @"Unable to set the preset property on the Sampler. Error code:%d '%.4s'",
               (int) result,
               (const char *)&result);
    
    
    NSDictionary *classData;
    UInt32 size = sizeof(CFPropertyListRef);
    
    AudioUnitGetProperty(self.samplerUnit,
                         kAudioUnitProperty_ClassInfo,
                         kAudioUnitScope_Global,
                         0,
                         &classData,
                         &size);
    
    _deviceName.text = [[classData valueForKey:@"Instrument"] valueForKey:@"name"];
    
    return result;
}



- (void) createSinglerPressModelGraph {
    
    OSStatus result;
    //create the nodes of the graph
    AUNode synthNode, limiterNode, outNode;
    
    AudioComponentDescription cd;
    cd.componentManufacturer = kAudioUnitManufacturer_Apple;
    cd.componentFlags = 0;
    cd.componentFlagsMask = 0;
    
    result = NewAUGraph (&graph);
    
    cd.componentType = kAudioUnitType_MusicDevice;
    cd.componentSubType = kAudioUnitSubType_Sampler;
    result = AUGraphAddNode (graph, &cd, &synthNode);
    
    cd.componentType = kAudioUnitType_Effect;
    cd.componentSubType = kAudioUnitSubType_PeakLimiter;
    result = AUGraphAddNode (graph, &cd, &limiterNode);
    
    cd.componentType = kAudioUnitType_Output;
    cd.componentSubType = kAudioUnitSubType_RemoteIO;
    result = AUGraphAddNode (graph, &cd, &outNode);
    
    result = AUGraphOpen (graph);
    
    result = AUGraphConnectNodeInput (graph, synthNode, 0, limiterNode, 0);
    result = AUGraphConnectNodeInput (graph, limiterNode, 0, outNode, 0);
    // ok we're good to go - get the Synth Unit...
    result = AUGraphNodeInfo(graph, synthNode, 0, &synthUnit);
    
    NSURL *presetURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"FantaGM32" ofType:@"sf2"] ];
    
    bpdata.bankURL  = (__bridge CFURLRef) presetURL;
    bpdata.bankMSB  = kAUSampler_DefaultMelodicBankMSB;
    bpdata.bankLSB  = kAUSampler_DefaultBankLSB;
    bpdata.presetID = (UInt8) deviceNumber;
    
    AudioUnitSetProperty(synthUnit,
                         kAUSamplerProperty_LoadPresetFromBank,
                         kAudioUnitScope_Global,
                         0,
                         &bpdata,
                         sizeof(bpdata));
    
    AUGraphInitialize(graph);
    result = MusicDeviceMIDIEvent(synthUnit,
                                  kMidiMessage_ControlChange << 4 | midiChannelInUse,
                                  kMidiMessage_BankMSBControl,
                                  0,
                                  0);
    
    result = MusicDeviceMIDIEvent(synthUnit,
                                  kMidiMessage_ProgramChange << 4 | midiChannelInUse,
                                  0/*prog change num*/,
                                  0,
                                  0);
    
    CAShow (graph);
    result = AUGraphStart (graph);
}



void MyMIDINotifyProc (const MIDINotification  *message, void *refCon) {
    printf("MIDI Notify, messageId=%d,", message->messageID);
}

static void MyMIDIReadProc(const MIDIPacketList *pktlist,
                           void *refCon,
                           void *connRefCon) {
    
    
    AudioUnit player = (AudioUnit) refCon;
    
    MIDIPacket *packet = (MIDIPacket *)pktlist->packet;
    for (int i=0; i < pktlist->numPackets; i++) {
        Byte midiStatus = packet->data[0];
        Byte midiCommand = midiStatus >> 4;
        
        if (midiCommand == 0x09) {
//            Byte note = packet->data[1] & 0x7F;
            Byte velocity = packet->data[2] & 0x7F;
            int noteNumber = ((int) noteValue) % 12;
            NSString *noteType;
            switch (noteNumber) {
                case 0:
                    noteType = @"C";
                    break;
                case 1:
                    noteType = @"C#";
                    break;
                case 2:
                    noteType = @"D";
                    break;
                case 3:
                    noteType = @"D#";
                    break;
                case 4:
                    noteType = @"E";
                    break;
                case 5:
                    noteType = @"F";
                    break;
                case 6:
                    noteType = @"F#";
                    break;
                case 7:
                    noteType = @"G";
                    break;
                case 8:
                    noteType = @"G#";
                    break;
                case 9:
                    noteType = @"A";
                    break;
                case 10:
                    noteType = @"Bb";
                    break;
                case 11:
                    noteType = @"B";
                    break;
                default:
                    break;
            }
            OSStatus result = noErr;
            result = MusicDeviceMIDIEvent (player, midiStatus, noteValue, velocity, 0);
        }
        packet = MIDIPacketNext(packet);
    }
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = devicesArray[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return devicesArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    deviceNumber = indexPath.row;
    _deviceName.text = devicesArray[indexPath.row];
}


- (Float64)getTime {
    MusicTimeStamp beats = 0;
    MusicPlayerGetTime (mp, &beats);
    Float64 time;
    MusicSequenceGetSecondsForBeats(ms, beats, &time);
    return time;
}

- (void)setLongestTrackLength {
    UInt32 trackCount;
    MusicSequenceGetTrackCount(ms, &trackCount);
    
    MusicTimeStamp longest = 0;
    for (int i = 0; i < trackCount; i++) {
        MusicTrack t;
        MusicSequenceGetIndTrack(ms, i, &t);
        
        MusicTimeStamp len;
        UInt32 sz = sizeof(MusicTimeStamp);
        MusicTrackGetProperty(t, kSequenceTrackProperty_TrackLength, &len, &sz);
        if (len > longest) {
            longest = len;
        }
    }
    Float64 longestTime;
    MusicSequenceGetSecondsForBeats(ms, longest, &longestTime);
    longestTrackLength = longestTime;
}

- (void)play {
    MusicPlayerStart(mp);
    playing = YES;
    [self updateUI:playing];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        while (playing) {
            if ([self getTime] >= longestTrackLength) {
                dispatch_sync(dispatch_get_main_queue(), ^(){
                    playing = NO;
                    [self updateUI:playing];
                });
                
            }
            [NSThread sleepForTimeInterval:.01];
        }
    });
}
- (void)stop {
    playing = NO;
    [self updateUI:playing];
    MusicPlayerStop(mp);
    DisposeMusicSequence(ms);
}

- (void) updateUI:(BOOL)isPlaying {
    [_playButton setTitle: isPlaying ? @"Stop" : @"Play" forState: isPlaying ? UIControlStateSelected : UIControlStateNormal];
    _playButton.selected = isPlaying ? YES : NO;
    _playButton.layer.borderColor = isPlaying ? [UIColor orangeColor].CGColor : [UIColor lightGrayColor].CGColor;
    _playButton.backgroundColor = isPlaying ? [UIColor lightGrayColor] : [UIColor orangeColor] ;
}

- (void) segmentDidChangeValue: (UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {//一段音乐
        pieceOfMusicModel = YES;
    }else {//单点模式
        if (playing) {
            [self stop];
        }
        pieceOfMusicModel = NO;
    }
}


- (void) noteValueDidchanged: (UISlider *)slider {
    noteValue = slider.value;
    _currentNoteValueLabel.text = [NSString stringWithFormat:@"%.f",slider.value];
}


@end

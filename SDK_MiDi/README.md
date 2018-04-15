###YMCoreAudioMidi
功能: midi 音频合成, 乐器切换
![](/Users/renzhicheng/Code/ymSDKMake/SDK_MiDi/screenshoot.PNG
)
使用过程: 
* 在下方列表中选择需要合成的乐器
* 点击开始按钮
* 可以在当前乐器, 查看当前程序合成的乐器名称.

###一段音乐模式
一 .创建 AudioGraph
	1.设置 AudioComponentDescription 参数
	2.添加midi node, componentType = KAudioUnitType_MusicDevice, componentSubType = kAudioUnitSubType_Smapler
	3.添加 io node
	4.连接 midi node 和 io node
	5.open audioGraph
	6.获得 midi node 和 io node 信息(unit)
	7. Initialize audio graph
	8. start audio graph

二. Midi
	1.create midi client
	2.create midi destination - midi read proc

三. sequecnce
	1. new music sequence
	2. load midi file from bundle
	3. MusicSequenceFileLoad
	4. new music player
	5. music sequence set Midi endpoint
	6. load sf2 file - setup AUSamplerbackPresetData
	7. MusicPlayerSetSequence
	8. MusicPlayerPreroll

四. play / stop
	1. play: MusicPlyerStart
	2. stop: MusicPlayerStop, DisposeMusicSequence.

###单点模式
一. Audio graph
	1. AudioComponentDescription
	2. new audioGraph
	3. midiNode, limiterNode, ioNode
	4. open audioGraph
	5. connect node
	6. get AudioUnit from node
	
二. load sf2 file set PresetData
	1. load sf2 from bundle 
	2. set preset Data to midi unit
	3. Initialize audio graph
	4. send music device midi event
	5. Start audioGraph
	
三. play
KMidiMessage_NoteOn = 0x9;
UInt32 noteOnCommand = KMidiMessage_NoteOn << 4 | midiChannelinUse;
MusicDeviceMIDIEvent(midiUnit, noteOnCommand, noteValue, onVelocity, 0);
	
	


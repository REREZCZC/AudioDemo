// This object handles Superpowered.
// Compare the source to CoreAudio.mm and see how much easier it is to understand.

@interface Superpowered: NSObject {
    
@public
    bool playing;
    uint64_t avgUnitsPerSecond, maxUnitsPerSecond;
    
}

- (void)toggle; // Start/stop Superpowered.
- (bool)toggleFx:(int)index; // Enable/disable fx.
- (void)playerSetTemp:(float)tempValue;
- (void)playerSetPitch:(int)pitchValue;
@end

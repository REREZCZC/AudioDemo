#import "ViewController.h"

#import "Superpowered.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <mach/mach_time.h>

@implementation ViewController {

    UIButton *playPause;
    UISlider *seekSlider;
    Superpowered *superpowered;
    bool SuperpoweredEnabled, fxEnabled[NUMFXUNITS], canCompare;

    int config;
    double ticksToCPUPercent;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    canCompare = true;
    config = 0;
    for (int n = 0; n < NUMFXUNITS; n++) fxEnabled[n] = false;
    
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    double ticksToSeconds = 1e-9 * ((double)timebase.numer) / ((double)timebase.denom);
    ticksToCPUPercent = ticksToSeconds * 100.0;
    
    superpowered = [[Superpowered alloc] init];
    
    SuperpoweredEnabled = true;
    [superpowered toggle];
}

static NSString *fxNames[2] = { @"Time stretching", @"Pitch shifting" };
- (IBAction)sliderValueChanged:(UISlider *)sender forEvent:(UIEvent *)event {
    _indicatorValue.text = [NSString stringWithFormat:@"%f",sender.value];
    [superpowered playerSetTemp:sender.value];
}
- (IBAction)pitchSliderValueChanged:(UISlider *)sender {
    [superpowered playerSetPitch:sender.value];
}





@end

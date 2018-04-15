#import "ViewController.h"
#import "AudioPlayer.h"
@interface ViewController ()
{
    AudioPlayer *player;
}

@end

@implementation ViewController

@synthesize slider;

- (void)viewDidLoad {
    [super viewDidLoad];
    player = [[AudioPlayer alloc]init];
    // Do any additional setup after loading the view, typically from a nib.
    [self initSliderViews];
    
}

-(void)initSliderViews{
    //初始化slider
    
    UILabel *angleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 150, 300, 30)];
    angleLabel.text = @"Angle change rate ";
    [self.view addSubview:angleLabel];
    
    UILabel *disLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 260, 100, 30)];
    disLabel.text = @"Distance";
    [self.view addSubview:disLabel];
    
    UILabel *reverbLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 350, 100, 30)];
    reverbLabel.text = @"Reverber";
    [self.view addSubview:reverbLabel];
    
    UILabel *delayLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 440, 100, 30)];
    delayLabel.text = @"Delay";
    [self.view addSubview:delayLabel];
    

    slider = [[UISlider alloc]initWithFrame:CGRectMake(30, 200, 325, 40)];
    slider.minimumValue = 50;//最小值
    slider.maximumValue = 300;//最大值
    slider.value = 50;//执行初始值
    //设置响应事件(此操作同：使用xib中时将事件与操作IBAction进行关联)
    [slider addTarget:self //事件委托对象
               action:@selector(sliderValueChanged) //处理事件的方法
     forControlEvents:UIControlEventValueChanged//具体事件
     ];
    //加入到view中
    [self.view addSubview:slider];
    

    
    _disSlider = [[UISlider alloc]initWithFrame:CGRectMake(30, 300, 325, 40)];
    _disSlider.minimumValue = 6;//最小值
    _disSlider.maximumValue = 36;//最大值
    _disSlider.value = 6;//执行初始值
    //设置响应事件(此操作同：使用xib中时将事件与操作IBAction进行关联)
    [_disSlider addTarget:self //事件委托对象
               action:@selector(disSliderValueChanged) //处理事件的方法
     forControlEvents:UIControlEventValueChanged//具体事件
     ];
    //加入到view中
    [self.view addSubview:_disSlider];
    
    
    _reverberSlider = [[UISlider alloc]initWithFrame:CGRectMake(30, 400, 325, 40)];
    _reverberSlider.minimumValue = 0;//最小值
    _reverberSlider.maximumValue = 8;//最大值
    _reverberSlider.value = 0;//执行初始值
    //设置响应事件(此操作同：使用xib中时将事件与操作IBAction进行关联)
    [_reverberSlider addTarget:self //事件委托对象
                   action:@selector(reverberSliderValueChanged) //处理事件的方法
         forControlEvents:UIControlEventValueChanged//具体事件
     ];
    //加入到view中
    [self.view addSubview:_reverberSlider];
    
    
    _delaySlider = [[UISlider alloc]initWithFrame:CGRectMake(30, 500, 325, 40)];
    _delaySlider.minimumValue = 0;//最小值
    _delaySlider.maximumValue = 30;//最大值
    _delaySlider.value = 0;//执行初始值
    //设置响应事件(此操作同：使用xib中时将事件与操作IBAction进行关联)
    [_delaySlider addTarget:self //事件委托对象
                        action:@selector(delaySliderValueChanged) //处理事件的方法
              forControlEvents:UIControlEventValueChanged//具体事件
     ];
    //加入到view中
    [self.view addSubview:_delaySlider];
    
}

-(void)sliderValueChanged{

    NSLog(@"%f",slider.value);
    [player passSpeed:slider.value];
}
- (void)disSliderValueChanged {
    NSLog(@"distance = %f",_disSlider.value);
    [player passdis:_disSlider.value];
}


- (void)reverberSliderValueChanged {
    NSLog(@"reverber = %f",_reverberSlider.value);
    [player passReverber:_reverberSlider.value];
}


- (void)delaySliderValueChanged {
    NSLog(@"delay = %f",_delaySlider.value);
    [player passDelay:_delaySlider.value];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)play:(id)sender {
    [player play];
}

- (IBAction)stop:(id)sender {
    [player stop];
}
- (IBAction)pause:(id)sender {
    [player pause];
}
@end

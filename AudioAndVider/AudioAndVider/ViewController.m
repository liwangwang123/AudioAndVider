//
//  ViewController.m
//  AudioAndVider
//
//  Created by 王力 on 15/10/21.
//  Copyright (c) 2015年 王力. All rights reserved.
//
//录音--播放
#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

#define kRecordAudioFile @"myRecord.caf"

@interface ViewController () <AVAudioRecorderDelegate>

//录音机
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
//播放器
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
//录音声波监控
@property (nonatomic, strong) NSTimer *timer;

@property (weak, nonatomic) IBOutlet UIButton *record;
@property (weak, nonatomic) IBOutlet UIButton *pause;
@property (weak, nonatomic) IBOutlet UIButton *resume;
@property (weak, nonatomic) IBOutlet UIButton *stop;
@property (weak, nonatomic) IBOutlet UIProgressView *audioPower;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setAudioSession];
}

- (void)setAudioSession {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    //设置为播放和录音状态, 以便可以再录制完成之后可以播放
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session setActive:YES error:nil];

}
//获得存储路径
- (NSURL *)getSavePath {
    NSString *url = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    url = [url stringByAppendingString:kRecordAudioFile];
    NSURL *urlPath = [NSURL URLWithString:url];
    return urlPath;
}
//录音文件设置
- (NSDictionary *)getAudioSetting {
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];//录音格式
    [dicM setObject:@(8000) forKey:AVSampleRateKey];//采样率
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];//设置声道
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];//采样点位数 为8 16 24 32
    [dicM setObject:@"YES" forKey:AVLinearPCMIsFloatKey];//是否采用浮点数采样
    
    return dicM;
}
//创建录音机
- (AVAudioRecorder *)audioRecorder {
    if (!_audioPlayer) {
        NSURL *url = [self getSavePath];
        NSDictionary *dic = [self getAudioSetting];
        NSError *error = nil;
        
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:dic error:&error];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;//如果要监控声波, 必须设置为yes
        if (error) {
            NSLog(@"创建录音机时发生错误, 错误信息: %@", error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

- (AVAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
        NSURL *url = [self getSavePath];
        NSError *error = nil;
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        _audioPlayer.numberOfLoops = 0;
        [_audioPlayer prepareToPlay];
        if (error) {
            NSLog(@"播放过程中发生错误: 错误信息%@", error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    }
    return _timer;
}
//录音波状态设置
- (void)audioPowerChange {
    [self.audioRecorder updateMeters];//更新测量值
    float power = [self.audioRecorder averagePowerForChannel:0];//取得第一个通道音频,注意音频强度范围-160到0
    CGFloat progress = (1.0 / 160.0) * (power + 160.0);
    [self.audioPower setProgress:progress];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)recordClick:(UIButton *)sender {
    if (![self.audioRecorder isRecording]) {
        [self.audioRecorder record];
        self.timer.fireDate = [NSDate distantFuture];
    }
}

//暂停
- (IBAction)pauseClick:(UIButton *)sender {
    if ([self.audioRecorder isRecording]) {
        [self.audioRecorder pause];
        self.timer.fireDate = [NSDate distantFuture];
    }
}
//恢复
- (IBAction)resumeClick:(UIButton *)sender {
    [self recordClick:sender];
}
//停止
- (IBAction)stopClick:(UIButton *)sender {
    [self.audioRecorder stop];
    self.timer.fireDate = [NSDate distantFuture];
    self.audioPower.progress = 0.0;
}
#pragma mark -- AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (![self.audioPlayer isPlaying]) {
        [self.audioPlayer play];
    }
    NSLog(@"录音完成,开始播放");
}

@end

































































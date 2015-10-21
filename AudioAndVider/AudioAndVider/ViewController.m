//
//  ViewController.m
//  AudioAndVider
//
//  Created by 王力 on 15/10/21.
//  Copyright (c) 2015年 王力. All rights reserved.
//
//音效播放
#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self playSoundEffect:@"videoRing.caf"];
}
//音效播放完成
void soundCompleteCallback(SystemSoundID soundID,void * clientData){
    NSLog(@"播放完成...");
}

//播放音效文件
- (void)playSoundEffect:(NSString *)name {
    NSString *audioFile = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSURL *fileUrl = [NSURL URLWithString:audioFile];
    //获得系统声音ID
    SystemSoundID soundID = 0;
    /**
     *
     *  @param inFileURL        inFileURL 音频文件url
     *  @param outSystemSoundID 声音ID
     *
     *  @return 此函数会将音效文件,加入到系统音频服务中,并返回一个长整形ID
     */
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    //如果需要在播放完之后执行某些操作, 可以调用如下方法注册一个完成回调函数
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    //播放音频
    AudioServicesPlaySystemSound(soundID);
    AudioServicesPlayAlertSound(soundID);//播放音效并震动
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

































































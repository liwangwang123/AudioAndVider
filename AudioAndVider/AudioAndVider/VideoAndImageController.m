//
//  VideoAndImageController.m
//  AudioAndVider
//
//  Created by 王力 on 15/10/21.
//  Copyright (c) 2015年 王力. All rights reserved.
//

#import "VideoAndImageController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoAndImageController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>


/**< 是否录制视频 */
@property (nonatomic, assign) BOOL isVideo;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIImageView *photo;//图片展示图
@property (nonatomic, strong) AVPlayer *player;//播放器, 视频录制完成之后, 用于播放视频

@end

@implementation VideoAndImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    // Do any additional setup after loading the view.
    _isVideo = YES;
}
//拍照
- (IBAction)takeClick:(UIButton *)sender {
    [self presentViewController:self.imagePicker animated:YES completion:^{
        
    }];
}

#pragma mark - UIImagePickerControllerDelegate
//完成
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {//如果是拍照
        UIImage *image;
        //如果允许编辑则获得编辑后的照片, 否则获取原始照片
        if (self.imagePicker.allowsEditing) {
            image = [info objectForKey:UIImagePickerControllerEditedImage];//修改之后的图片
        } else {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];//原始图片
        }
        [self.photo setImage:image];//显示照片
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);//保存到相簿
        
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {//如果是录制视频
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];//视频路径
        NSString *urlString = [url path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlString)) {
            //保存视频到相簿, 注意也可以使用ALAssetsLibrary来保存
            UISaveVideoAtPathToSavedPhotosAlbum(urlString, self, @selector(video: didFinishSavingWithError: contextInfo:), nil);//保存视频到相簿
        }
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"取消");
}

- (UIImagePickerController *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;//设置image来源,摄像头
        _imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;//使用那个摄像头,(后置)
        if (self.isVideo) {
            _imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
            _imagePicker.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;
            _imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;//设置摄像头模式(拍照, 录视频)
            
        } else {
            _imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        }
        _imagePicker.allowsEditing = YES;//允许编辑
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}
//视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"保存视频过程中发生错误:错误信息:%@", error.localizedDescription);
    } else {
        NSLog(@"保存成功");
        NSURL *url = [NSURL fileURLWithPath:videoPath];
        _player = [AVPlayer playerWithURL:url];
        AVPlayerLayer *playLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        playLayer.frame = self.photo.frame;
        [self.photo.layer addSublayer:playLayer];
        [playLayer player];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end






































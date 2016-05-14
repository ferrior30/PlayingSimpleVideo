//
//  ViewController.m
//  PlayingSimpleVideo
//
//  Created by ChenWei on 16/5/10.
//  Copyright © 2016年 cw. All rights reserved.
//

#import "ViewController.h"
#import "CWPlayerLayer.h"
#import "CWSlider.h"
@import AVFoundation;

@interface ViewController ()
{
    AVPlayer *_player;
    id<NSObject> _timeObserverToken;
}
@property (weak, nonatomic) IBOutlet UIButton *rewindButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
/** 播放进度条 */
@property (weak, nonatomic) IBOutlet CWSlider *progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *startTiemLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationTimeLabel;

@property (strong, nonatomic) AVURLAsset *asset;
@property (strong, nonatomic) AVPlayerItem *playerItem;


/** AVPlayer */
@property (weak, nonatomic) IBOutlet CWPlayerLayer *playerLayer;
@property (weak, nonatomic) IBOutlet UILabel *loadedTimeRange;

@end

/** KVO context */
static int *ViewControllerKVOContext = 0;
static NSString *const keyPathAsset = @"asset";
static NSString *const keyPathPlayerRate = @"player.rate";
static NSString *const keyPathPlayerCurrentItemStatus = @"player.currentItem.status";
static NSString *const keyPathPlayerCurrentItemDuration = @"player.currentItem.duration";
@implementation ViewController

// MARK: UI Handle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AVPlayerItemDidPlayToEndTimeNotification object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayToEndTimeNotification) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    /**
     *  当player的属性发生变化时更新UI
     */
    [self addObserver:self forKeyPath:keyPathAsset options:NSKeyValueObservingOptionNew context:ViewControllerKVOContext];
    [self addObserver:self forKeyPath:keyPathPlayerRate options:NSKeyValueObservingOptionNew context:ViewControllerKVOContext];
    [self addObserver:self forKeyPath:keyPathPlayerCurrentItemStatus options:NSKeyValueObservingOptionNew context:ViewControllerKVOContext];
    [self addObserver:self forKeyPath:keyPathPlayerCurrentItemDuration options:NSKeyValueObservingOptionNew context:ViewControllerKVOContext];
    
    // 创建player(self.player是懒加载的）
    self.playerLayer.player = self.player;
    
    NSURL *movieURL = [NSURL URLWithString:@"http://wvideo.spriteapp.cn/video/2016/0405/5703818976ef5_wpd.mp4"];
   
    self.asset = [AVURLAsset URLAssetWithURL:movieURL options:nil];

    // 利用AVPlayer的方法周期性的更新UI
    __weak typeof(self) weakSelf = self;
    // 如果不用_timeObserverToken接收返回值，该方法将无效
    _timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
       // 更新UI
        weakSelf.progressSlider.value = CMTimeGetSeconds(time);
        weakSelf.startTiemLabel.text = [NSString stringWithFormat:@"%.0f", CMTimeGetSeconds(weakSelf.player.currentTime)];
    }];
//    [self.progressSlider addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchUpInside];
//    __weak typeof(self) weakSelf = self;
    self.progressSlider.block = ^{[weakSelf.player pause];};
    self.progressSlider.block2 = ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.player play];
        });
    };
}

// MARK: - NSNotification
- (void)didPlayToEndTimeNotification {
    self.currenTime = kCMTimeZero;
    [self.player pause];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSError *error = nil;
    if ([self.asset.URL checkResourceIsReachableAndReturnError:&error]){
        NSLog(@"资料可用");
    }else {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"当前资源不能播放" message:error.description preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alertVC dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alertVC addAction:cancelAction];
        
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_timeObserverToken) {
        [self.player removeTimeObserver:_timeObserverToken];
        _timeObserverToken = nil;
    }
    
    [self.player pause];
    
    [self removeObserver:self forKeyPath:keyPathAsset context:ViewControllerKVOContext];
    [self removeObserver:self forKeyPath:keyPathPlayerRate context:ViewControllerKVOContext];
    [self removeObserver:self forKeyPath:keyPathPlayerCurrentItemStatus context:ViewControllerKVOContext];
    [self removeObserver:self forKeyPath:keyPathPlayerCurrentItemDuration context:ViewControllerKVOContext];
}

// MARK: - Properties
- (AVPlayer *)player {
    if (_player == nil) {
        _player = [[AVPlayer alloc] init];
    }
    return _player;
}

- (void)setCurrenTime:(CMTime)currenTime {
    [self.player  seekToTime:currenTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
}

- (CMTime)currenTime {
    return  self.playerItem.currentTime;
}

- (void)setPlayerItem:(AVPlayerItem *)newPlayerItem {
    if (_playerItem != newPlayerItem) {
        _playerItem = newPlayerItem;
        
        [self.player replaceCurrentItemWithPlayerItem:_playerItem];
    }
}

// Will attempt load and test these asset keys before playing
+ (NSArray *)assetKeysRequiredToPlay {
    return @[@"playable", @"hasProtectedContent"];
}

// MARK: - ASSet Loading
/** ASSet Loading */
- (void)asynchronouslyLoadURLAsset:(AVURLAsset *)asset {
    // 异步加载asset的信息
    [self.asset loadValuesAsynchronouslyForKeys:ViewController.assetKeysRequiredToPlay completionHandler:^{
        NSLog(@"asynchronouslyLoadURLAsset = %@", [NSThread currentThread]);
        // 获取到asset信息；回到主线程处理
        dispatch_async(dispatch_get_main_queue(), ^{
            // 正在播放的asset与返回的asset信息不是同一个asset, 退出等待asset更新后重新返回。
            if (asset != self.asset) {
                return ;
            }
            
            // 追踪的key没有成功加载
            for (NSString *key in [self.class assetKeysRequiredToPlay]) {
                NSError *error = nil;
                if ([asset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed) {
                    NSString *message = @"key加载失败，资源不能利用";
                    [self handleErrorWithMessage:message error:error];
                    
                    return;
                }
            }
            
            // key 加载成功，key有值，可以拿到key到判断
            if (!asset.playable || asset.hasProtectedContent) { // 不能播放
                NSString *message = [NSString stringWithFormat:@"资源不要播放或者是受保护的"];
                [self handleErrorWithMessage:message error:nil];
                
                return;
            }else { // 可以播放 -> 创建playerItem
                self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
            }
        });
    
    }];
}

// MARK: - IBActions
- (IBAction)rewindPlay:(UIButton *)sender {
    self.player.rate = -1;
}

- (IBAction)pausePlay:(UIButton *)sender {
  
    [self.player pause];
    
}
- (IBAction)forwardPlay:(UIButton *)sender {
    [self.player play];

}

- (IBAction)sliderDidChange:(UISlider *)sender {
    CMTime time = CMTimeMake(sender.value, 1);
    // 与上面的方法有区别，seconds = frame桢数/ timeScale
//    CMTimeMakeWithSeconds(<#Float64 seconds#>, <#int32_t preferredTimeScale#>)
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];

    
}

// MARK: - KV observation
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
   // KVO 不是我们的
    if (context != ViewControllerKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    // asset重新设置的时候才会调用
    if (keyPath == keyPathAsset) {
        if (self.asset) {
            [self asynchronouslyLoadURLAsset:self.asset];
        }
    }else if (keyPath == keyPathPlayerRate) {
        CGFloat newRate = [change[NSKeyValueChangeNewKey] floatValue];
        if (newRate == 0) {
            NSLog(@"%f", newRate);
            NSLog(@"current %lld,  -- %lld", self.currenTime.value, self.playerItem.duration.value);
            if (self.currenTime.value > 0 && CMTimeGetSeconds(self.currenTime) < CMTimeGetSeconds(self.playerItem.duration)) { // 在中间位置暂停时
                self.pauseButton.enabled = NO;
                self.rewindButton.enabled = YES;
                self.playButton.enabled = YES;
            }else if (self.currenTime.value == self.playerItem.duration.value) { // 在尾部暂停
                self.rewindButton.enabled = YES;
                self.playButton.enabled = NO;
            }else { // 在头部暂停
                self.rewindButton.enabled = NO;
                self.playButton.enabled = YES;
            }
        }else if (newRate > 0) { // 正在前进播放
            self.playButton.enabled = NO;
            self.pauseButton.enabled = YES;
            self.rewindButton.enabled = YES;
        }else { // 正在后退播放
            self.rewindButton.enabled = NO;
            self.pauseButton.enabled = YES;
            self.playButton.enabled = YES;
        }
    }else if (keyPath == keyPathPlayerCurrentItemDuration) { // 只有当currentItem改变时才会执行一次
        NSValue *newDurationValue = change[NSKeyValueChangeNewKey];
        CMTime newDuration = [newDurationValue isKindOfClass:[NSValue class]] ? newDurationValue.CMTimeValue : kCMTimeZero;
        
        BOOL hasValidDuration = CMTIME_IS_NUMERIC(newDuration) && newDuration.value != 0;
        
        // slider设置
        // maximumValue
        double newDurationSeconds = hasValidDuration ? CMTimeGetSeconds(newDuration) : 0.0;
        self.progressSlider.maximumValue = newDurationSeconds;
        // 初始位置
        self.progressSlider.value = hasValidDuration ? CMTimeGetSeconds(self.currenTime) : 0.0;
        
        // 影片的总时长Label和初始位置Label
        int minutes = trunc(newDurationSeconds / 60);
        int seconds = trunc(newDurationSeconds - minutes * 60);
        self.durationTimeLabel.text = hasValidDuration ? [NSString stringWithFormat:@"%d:%02d",minutes, seconds] : @"-- : --";
        
        self.startTiemLabel.text = hasValidDuration ? @"0.0" : @"--: --";
        
    }else if (keyPath == keyPathPlayerCurrentItemStatus) {
        // 处理AVPlayerItemStatusFailed的情况
        NSNumber *itemStatusAsNumber = change[NSKeyValueChangeNewKey];
        
        NSInteger statsus = ([itemStatusAsNumber isKindOfClass:[NSNumber class]]) ? itemStatusAsNumber.integerValue : AVPlayerItemStatusUnknown;
        if (statsus == AVPlayerItemStatusFailed) {
            [self handleErrorWithMessage:self.playerItem.error.description error:self.playerItem.error];
        }
        if (statsus == AVPlayerItemStatusReadyToPlay) {
            self.playButton.enabled = YES;
            self.pauseButton.enabled = NO;
            self.rewindButton.enabled = NO;
        }
    }
}

// MARK: - Error Handle
- (void)handleErrorWithMessage:(NSString *)messge error:(NSError *)error {
    NSLog(@"Error occuree with message: %@, error: %@.", messge, error);
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"error" message:messge preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertVC addAction:cancelAction];
    
    [self.navigationController presentViewController:alertVC animated:YES completion:nil];
}

@end

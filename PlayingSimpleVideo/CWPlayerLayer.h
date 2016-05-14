//
//  CWPlayerLayer.h
//  PlayingSimpleVideo
//
//  Created by ChenWei on 16/5/11.
//  Copyright © 2016年 cw. All rights reserved.

//
/**
 摘要:view（包含一个AVPlayerLayer)
 */

@import UIKit;
@import AVFoundation;

@class AVPlayer;


@interface CWPlayerLayer : UIView
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic,readonly) AVPlayerLayer *playerLayer;
@end

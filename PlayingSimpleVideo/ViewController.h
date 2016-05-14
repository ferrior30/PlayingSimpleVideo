//
//  ViewController.h
//  PlayingSimpleVideo
//
//  Created by ChenWei on 16/5/10.
//  Copyright © 2016年 cw. All rights reserved.
//

@import UIKit;
@import CoreMedia.CMTime;

@class AVPlayer;

@interface ViewController : UIViewController

@property (assign, nonatomic) CMTime currenTime;

@property (strong, nonatomic) AVPlayer *player;
@end


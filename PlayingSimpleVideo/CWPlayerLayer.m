//
//  CWPlayerLayer.m
//  PlayingSimpleVideo
//
//  Created by ChenWei on 16/5/11.
//  Copyright © 2016年 cw. All rights reserved.
//

#import "CWPlayerLayer.h"

@implementation CWPlayerLayer

+ (Class)layerClass {
    
    return [AVPlayerLayer class];
}

- (void)setPlayer:(AVPlayer *)player {
    self.playerLayer.player = player;
}

- (AVPlayer *)player {
    return self.playerLayer.player;
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}
@end

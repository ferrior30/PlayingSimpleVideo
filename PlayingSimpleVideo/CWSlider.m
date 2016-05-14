//
//  CWSlider.m
//  PlayingSimpleVideo
//
//  Created by ChenWei on 16/5/14.
//  Copyright © 2016年 cw. All rights reserved.
//
#import "ViewController.h"
#import "CWSlider.h"


@implementation CWSlider
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"begin");
    self.block();

    [super touchesBegan:touches withEvent:event];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.block2();
    [super touchesEnded:touches withEvent:event];
}
@end

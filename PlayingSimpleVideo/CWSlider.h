//
//  CWSlider.h
//  PlayingSimpleVideo
//
//  Created by ChenWei on 16/5/14.
//  Copyright © 2016年 cw. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^block)();
@interface CWSlider : UISlider
@property (copy, nonatomic) void (^block)();
@property (copy, nonatomic) void (^block2)();
@end

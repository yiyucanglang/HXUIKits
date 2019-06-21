//
//  HXRespondAreaExpandButton.m
//  ParentDemo
//
//  Created by James on 2019/6/19.
//  Copyright © 2019 DaHuanXiong. All rights reserved.
//

#import "HXRespondAreaExpandButton.h"

@implementation HXRespondAreaExpandButton

//Apple的iOS人机交互设计指南中指出，按钮点击热区应不小于44x44pt，否则这个按钮就会让用户觉得“很难用”，因为明明点击上去了，却没有任何响应。

//但我们有时做自定义Button的时候，设计图上的给出按钮尺寸明显要小于这个数。例如我之前做过的自定义Slider上的Thumb只有12x12pt，做出来后我发现自己根本点不到按钮……

//这个问题在WWDC 2012 Session 216视频中提到了一种解决方式。它重写了按钮中的pointInside方法，使得按钮热区不够44×44大小的先自动缩放到44×44，再判断触摸点是否在新的热区内。
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect bounds = self.bounds;
    //若原热区小于44x44，则放大热区，否则保持原大小不变
    CGFloat widthDelta = MAX(44.0 - bounds.size.width, 0);
    CGFloat heightDelta = MAX(44.0 - bounds.size.height, 0);
    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    return CGRectContainsPoint(bounds, point);
}


@end

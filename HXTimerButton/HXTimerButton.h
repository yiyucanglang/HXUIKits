//
//  HXTimerButton.h
//  ZMParentsProject
//
//  Created by James on 18/01/2018.
//  Copyright © 2018 Sea. All rights reserved.
//

#import <UIKit/UIKit.h>

//sample code :
//[[HXTimerButton alloc] initWithNormalTitle:@"获取验证码" titleFont:kZMPFont(14) normalTitleColor:kZMPBtnRedBgColor runningTitleColor:kZMPNineLevelGray countDownValue:60 runningformatTitle:@"(%@)s 重新获取"];

@interface HXTimerButton : UIView

- (instancetype _Nullable)initWithNormalTitle:(NSString * _Nonnull)normalTitle
                          titleFont:(UIFont * _Nonnull)titleFont
                   normalTitleColor:(UIColor * _Nonnull)normalTitleColor
                  runningTitleColor:(UIColor * _Nonnull)runningTitleColor
                     countDownValue:(NSInteger )countDownValue
               runningformatTitle:(NSString * _Nonnull)formatTitle;

- (void)start;

- (void)stop;

- (void)addTarget:(nullable id)target action:(SEL _Nonnull )action forControlEvents:(UIControlEvents)controlEvents;

- (void)setAlignment:(UIControlContentHorizontalAlignment)alignment;
@end

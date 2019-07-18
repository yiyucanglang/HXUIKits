//
//  HXCommonShareView.h
//  ParentDemo
//
//  Created by James on 2019/6/19.
//  Copyright © 2019 DaHuanXiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, HXCommonShareViewPlatform) {
    HXCommonShareViewPlatform_WeChat = 1 << 0,
    HXCommonShareViewPlatform_WeChatTimeLine = 1 << 1,
    HXCommonShareViewPlatform_QQ = 1 << 2,
    HXCommonShareViewPlatform_Sina = 1 << 3,
    HXCommonShareViewPlatform_All = HXCommonShareViewPlatform_WeChat|HXCommonShareViewPlatform_WeChatTimeLine|HXCommonShareViewPlatform_QQ|HXCommonShareViewPlatform_Sina,
};

typedef void(^HXShareCompletionHandler)(HXCommonShareViewPlatform platForm, id _Nullable bindingData);

@interface HXCommonShareView : UIView


//default:183
@property (nonatomic, assign) CGFloat   bottomContainerViewHeight;

//default:29
@property (nonatomic, assign) CGFloat   platformContainerViewTopMargin;

////default:29
//@property (nonatomic, assign) CGFloat   platformContainerViewTopMargin;


- (void)showInView:(UIView *)targetView
          platform:(HXCommonShareViewPlatform)platform
       bindingData:(id _Nullable)bindingData
 completionHandler:(HXShareCompletionHandler _Nullable)completionHandler;

- (void)dismiss;

- (void)configDefaultItemViewWithImage:(UIImage *)image
                                 title:(NSString * _Nullable)title
                       imgTextDistance:(CGFloat)distance
                              platform:(HXCommonShareViewPlatform)platform;

//must called before showInView if this method invoked
- (void)customLayout:(void(^)(UIView *bottomContainerView))layoutBlock;

- (void)customItemView:(UIView *)itemView associatedWithPlatform:(HXCommonShareViewPlatform)platform;
@end

NS_ASSUME_NONNULL_END

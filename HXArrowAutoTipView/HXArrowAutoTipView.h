//
//  HXArrowAutoTipView.h
//  ParentDemo
//
//  Created by James on 2019/7/16.
//  Copyright © 2019 DaHuanXiong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>

typedef NS_ENUM(NSInteger, HXArrowDirection) {
    HXArrowDirectionDown,
    HXArrowDirectionUp,
    HXArrowDirectionLeft,
    HXArrowDirectionRight,
};

//only use for HXArrowDirectionDown||HXArrowDirectionUp
typedef NS_ENUM(NSInteger, HXArrowTipAlignStyle) {
    HXArrowTipAlignStyleLeft,
    HXArrowTipAlignStyleCenter,
    HXArrowTipAlignStyleRight,
};


NS_ASSUME_NONNULL_BEGIN

@interface HXArrowAutoTipView : UIView

//this will be added to containerView
@property (nonatomic, strong, readonly) UIView  *customContentView;

@property (nonatomic, strong, readonly) UIView  *containerView;

//default : 12
@property (nonatomic, assign) CGFloat   triangleEdgeWidth;

//default : 6;
@property (nonatomic, assign) CGFloat   triangleHeight;

//default : 5
@property (nonatomic, assign) CGFloat   marginToAnchorView;

//default : 0 use for algin  + outside - inside noti: this property useless when HXArrowTipAlignStyleCenter
@property (nonatomic, assign) CGFloat   edgeMargin;

//default NO
@property (nonatomic, assign) BOOL   forbiddenBgAreaTouch;

//HXArrowDirectionDown
@property (nonatomic, assign) HXArrowDirection   arrowDirection;

//defult 0(will not auto dismiss)
@property (nonatomic, assign) NSInteger   autoDissmissDuration;

- (void)bindingCustomContentView:(UIView *)customContentView addtionalLayout:(void (^)(MASConstraintMaker *make, UIView *containerView))layout;

//config must be set before this method invoked
/**
 show tip For anchorView

 @param anchorView anchorView
 @param align tip Algin to anchorView
 tipSuperView : keywindow
 */
- (void)showWithAnchorView:(UIView *)anchorView
                     align:(HXArrowTipAlignStyle)align;


- (void)showWithAnchorView:(UIView *)anchorView
                     align:(HXArrowTipAlignStyle)align
              tipSuperView:(UIView *)tipSuperView;

- (void)dimiss:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END

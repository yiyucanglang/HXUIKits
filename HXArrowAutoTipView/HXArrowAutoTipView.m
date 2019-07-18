//
//  HXArrowAutoTipView.m
//  ParentDemo
//
//  Created by James on 2019/7/16.
//  Copyright © 2019 DaHuanXiong. All rights reserved.
//


#import "HXArrowAutoTipView.h"
#import <QuartzCore/QuartzCore.h>

@interface HXArrowAutoTipView()
<
    CAAnimationDelegate
>
@property (nonatomic, strong) UIView  *customContentView;
@property (nonatomic, strong) UIView  *mainContainerView;
@property (nonatomic, strong) UIView  *containerView;
@property (nonatomic, strong) CAShapeLayer    *arrowShapeLayer;
@property (nonatomic, strong) UIBezierPath    *arrowPath;
@property (nonatomic, assign) CGFloat   triangleLeftMargin;
@property (nonatomic, weak)   UIView    *anchorView;
@property (nonatomic, strong) UIView  *maskView;
@property (nonatomic, strong) UIView  *anchorCopyView;
@property (nonatomic, weak)   UIView   *superView;

@property (nonatomic, assign) HXArrowTipAlignStyle   alignStyle;
@property (nonatomic, strong) NSTimer  *timer;

@end

@implementation HXArrowAutoTipView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.triangleEdgeWidth  = 12;
        self.triangleHeight     = 6;
        self.marginToAnchorView = 5;
        [self _UIConfig];
    }
    return self;
}

#pragma mark - System Method
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width  = self.mainContainerView.frame.size.width;
    CGFloat height = self.mainContainerView.frame.size.height;
    
    [self _calculateArrowLeftMargin];
    CGFloat margin = self.triangleLeftMargin;
    
    
    CGPoint dotOne;
    CGPoint dotTwo;
    CGPoint dotThree;
    switch (self.arrowDirection) {
        case HXArrowDirectionDown:
            height -= self.triangleHeight;
            dotOne   = CGPointMake(margin, height);
            dotTwo   = CGPointMake(margin + self.triangleEdgeWidth/2.0, height + self.triangleHeight);
            dotThree = CGPointMake(margin + self.triangleEdgeWidth, height);
            break;
        case HXArrowDirectionUp:
            height -= self.triangleHeight;
            dotOne   = CGPointMake(margin, 0);
            dotTwo   = CGPointMake(margin + self.triangleEdgeWidth/2.0, -self.triangleHeight);
            dotThree = CGPointMake(margin + self.triangleEdgeWidth, 0);
            break;
        case HXArrowDirectionLeft:
            width -= self.triangleHeight;
            dotOne   = CGPointMake(0, margin);
            dotTwo   = CGPointMake(-self.triangleHeight, margin + self.triangleEdgeWidth/2.0);
            dotThree = CGPointMake(0, margin + self.triangleEdgeWidth);
            break;
        case HXArrowDirectionRight:
            width -= self.triangleHeight;
            dotOne   = CGPointMake(width, margin);
            dotTwo   = CGPointMake(width + self.triangleHeight, margin + self.triangleEdgeWidth/2.0);
            dotThree = CGPointMake(width, margin + self.triangleEdgeWidth);
            break;
            
        default:
            break;
    }
    [self.arrowPath removeAllPoints];
    [self.arrowPath moveToPoint:dotOne];
    [self.arrowPath addLineToPoint:dotTwo];
    [self.arrowPath addLineToPoint:dotThree];
    [self.arrowPath closePath];
    
    self.arrowShapeLayer.path = self.arrowPath.CGPath;
    self.arrowShapeLayer.fillColor = self.containerView.backgroundColor.CGColor;
    
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self _stopTimer];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.forbiddenBgAreaTouch) {
        return [super pointInside:point withEvent:event];
    }
    if ([self.mainContainerView pointInside:point withEvent:event]) {
        return YES;
    }
    [self dimiss:NO];
    return NO;
}

#pragma mark - Public Method

- (void)bindingCustomContentView:(UIView *)customContentView addtionalLayout:(void (^)(MASConstraintMaker * _Nonnull, UIView * _Nonnull))layout {
    
    [customContentView removeFromSuperview];
    self.customContentView = customContentView;
    [self.containerView addSubview:customContentView];
    
    [customContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        layout(make, self.containerView);
    }];
}

- (void)showWithAnchorView:(UIView *)anchorView align:(HXArrowTipAlignStyle)align {
    
    [self showWithAnchorView:anchorView align:align tipSuperView:[self getVCOfTargetView:anchorView].view ?: [UIApplication sharedApplication].keyWindow];
}

- (void)showWithAnchorView:(UIView *)anchorView align:(HXArrowTipAlignStyle)align tipSuperView:(nonnull UIView *)tipSuperView {
    
    self.alignStyle = align;
    self.anchorView = anchorView;
    [self _reloadUI];
    
    self.superView = tipSuperView;
    
    CGRect convertRect = [anchorView.superview convertRect:anchorView.frame toView:self.superView];
    
    if (!CGRectIntersectsRect(self.superView.bounds, convertRect)) {
        return;
    }
    
    self.anchorCopyView.frame = convertRect;
    [self addSubview:self.anchorCopyView];
    
    [self.superView addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.superView);
    }];
    
    switch (self.arrowDirection) {
        case HXArrowDirectionDown:
            {
                [self _layoutForArrowDown];
            }
            break;
        case HXArrowDirectionUp:
            {
                [self _layoutForArrowUp];
            }
            break;
        case HXArrowDirectionLeft:
            {
                [self _layoutForArrowLeft];
            }
            break;
        case HXArrowDirectionRight:
            {
                [self _layoutForArrowRight];
            }
            break;
            
        default:
            break;
    }
    
    if (self.autoDissmissDuration > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.autoDissmissDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dimiss:YES];
        });
    }
    
    [self _startTimer];
    
}


- (void)dimiss:(BOOL)animated {
    if (animated) {
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = @1.0;
        scaleAnimation.toValue = @0.80;
        scaleAnimation.duration = 0.10;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.fillMode = kCAFillModeForwards;
        
        CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        alphaAnimation.fromValue = @1.0;
        alphaAnimation.toValue = @0.0;
        alphaAnimation.duration = 0.10;
        alphaAnimation.removedOnCompletion = NO;
        alphaAnimation.fillMode = kCAFillModeForwards;
        
        
        CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
        group.animations = @[scaleAnimation, alphaAnimation];
        group.removedOnCompletion = NO;
        group.delegate = self;
        
        [self.containerView.layer addAnimation:group forKey:@"dimissAnimationKey"];
        
    } else {
        [self removeFromSuperview];
    }
}


#pragma mark - Override
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - Private Method
- (void)_UIConfig {
    [self addSubview:self.maskView];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self addSubview:self.mainContainerView];
    
    [self.mainContainerView addSubview:self.containerView];
}

- (void)_reloadUI {
    
    switch (self.arrowDirection) {
        case HXArrowDirectionDown:
        {
            [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.top.right.equalTo(self.mainContainerView);
                make.bottom.equalTo(self.mainContainerView).with.offset(- self.triangleHeight);
            }];
        }
            break;
        case HXArrowDirectionUp:
        {
            [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.right.equalTo(self.mainContainerView);
                make.top.equalTo(self.mainContainerView).with.offset(self.triangleHeight);
            }];
        }
            break;
        case HXArrowDirectionLeft:
        {
            [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.right.equalTo(self.mainContainerView);
                make.left.equalTo(self.mainContainerView).with.offset(self.triangleHeight);
            }];
        }
            break;
        case HXArrowDirectionRight:
        {
            [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.left.equalTo(self.mainContainerView);
                make.right.equalTo(self.mainContainerView).with.offset(-self.triangleHeight);
            }];
        }
            break;
        default:
            break;
    }
}

- (void)_layoutForArrowDown {
    [self.mainContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.alignStyle == HXArrowTipAlignStyleLeft) {
            make.left.equalTo(self.anchorCopyView).with.offset(-self.edgeMargin);
        }
        else if(self.alignStyle == HXArrowTipAlignStyleRight) {
            make.right.equalTo(self.anchorCopyView).with.offset(self.edgeMargin);
        }
        else {
            make.centerX.equalTo(self.anchorCopyView);
        }
        
        make.bottom.equalTo(self.anchorCopyView.mas_top).with.offset(-self.marginToAnchorView);
    }];
}

- (void)_layoutForArrowUp {
    [self.mainContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.alignStyle == HXArrowTipAlignStyleLeft) {
            make.left.equalTo(self.anchorCopyView).with.offset(-self.edgeMargin);
        }
        else if(self.alignStyle == HXArrowTipAlignStyleRight) {
            make.right.equalTo(self.anchorCopyView).with.offset(self.edgeMargin);
        }
        else {
            make.centerX.equalTo(self.anchorCopyView);
        }
        
        make.top.equalTo(self.anchorCopyView.mas_bottom).with.offset(self.marginToAnchorView);
    }];
}

- (void)_layoutForArrowLeft {
    [self.mainContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.anchorCopyView);
        make.left.equalTo(self.anchorCopyView.mas_right).with.offset(self.marginToAnchorView);
    }];
}

- (void)_layoutForArrowRight {
    [self.mainContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.anchorCopyView);
        make.right.equalTo(self.anchorCopyView.mas_left).with.offset(-self.marginToAnchorView);
    }];
}

#pragma mark -
- (void)_calculateArrowLeftMargin {
    
    CGFloat width  = self.anchorView.frame.size.width;
    CGFloat height = self.anchorView.frame.size.height;
    
    if (self.arrowDirection == HXArrowDirectionDown || self.arrowDirection == HXArrowDirectionUp) {
        if (self.alignStyle == HXArrowTipAlignStyleCenter) {
            
            self.triangleLeftMargin = width/2.0 - self.triangleEdgeWidth/2.0 + (self.mainContainerView.frame.size.width - width)/2;
        }
        else if(self.alignStyle == HXArrowTipAlignStyleLeft) {
            self.triangleLeftMargin = width/2.0 - self.triangleEdgeWidth/2.0 + self.edgeMargin;
        }
        else {
            self.triangleLeftMargin = self.mainContainerView.frame.size.width - width/2.0 - self.triangleEdgeWidth/2.0 - self.edgeMargin;
        }
        
    }
    else {
        self.triangleLeftMargin = height/2.0 - self.triangleEdgeWidth/2.0 + (self.mainContainerView.frame.size.height - height)/2;
    }
}



- (void)_dismissAnimated {
    [self dimiss:YES];
}

- (void)_startTimer {
    [self _stopTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(_updateUI) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)_stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)_updateUI {
    CGRect convertRect = [self.anchorView.superview convertRect:self.anchorView.frame toView:self.superView];
    self.anchorCopyView.frame = convertRect;
}

- (UIViewController *)getVCOfTargetView:(UIView *)targetView {
    for (UIView *view = targetView; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

#pragma mark - Delegate
#pragma mark CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self removeFromSuperview];
}

#pragma mark - Setter And Getter
- (UIView *)mainContainerView {
    if (!_mainContainerView) {
        _mainContainerView = [[UIView alloc] init];
    }
    return _mainContainerView;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
    }
    return _containerView;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_dismissAnimated)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}



- (UIBezierPath *)arrowPath {
    if (!_arrowPath) {
        _arrowPath = [[UIBezierPath alloc] init];
    }
    return _arrowPath;
}


- (CAShapeLayer *)arrowShapeLayer
{
    if (!_arrowShapeLayer) {
        _arrowShapeLayer = [[CAShapeLayer alloc]init];
        [self.containerView.layer addSublayer:_arrowShapeLayer];
    }
    
    return _arrowShapeLayer;
}

- (UIView *)anchorCopyView {
    if (!_anchorCopyView) {
        _anchorCopyView = [[UIView alloc] init];
        _anchorCopyView.userInteractionEnabled = NO;
    }
    return _anchorCopyView;
}



- (void)setForbiddenBgAreaTouch:(BOOL)forbiddenBgAreaTouch {
    _forbiddenBgAreaTouch = forbiddenBgAreaTouch;
    self.maskView.userInteractionEnabled = !forbiddenBgAreaTouch;
}


#pragma mark - Dealloc

@end
//fillMode的作用就是决定当前对象过了非active时间段的行为. 比如动画开始之前,动画结束之后
//kCAFillModeRemoved 这个是默认值,也就是说当动画开始前和动画结束后,动画对layer都没有影响,动画结束后,layer会恢复到之前的状态
//kCAFillModeForwards 当动画结束后,layer会一直保持着动画最后的状态
//kCAFillModeBackwards 这个和kCAFillModeForwards是相对的,就是在动画开始前,你只要将动画加入了一个layer,layer便立即进入动画的初始状态并等待动画开始.你可以这样设定测试代码,将一个动画加入一个layer的时候延迟5秒执行.然后就会发现在动画没有开始的时候,只要动画被加入了layer,layer便处于动画初始状态
//kCAFillModeBoth 理解了上面两个,这个就很好理解了,这个其实就是上面两个的合成.动画加入后开始之前,layer便处于动画初始状态,动画结束后layer保持动画最后的状态.

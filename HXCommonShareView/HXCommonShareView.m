//
//  HXCommonShareView.m
//  ParentDemo
//
//  Created by James on 2019/6/19.
//  Copyright © 2019 DaHuanXiong. All rights reserved.
//

#import "HXCommonShareView.h"
#import <HXKitComponent/HXImgtextCombineView.h>
#import <Masonry/Masonry.h>

@interface HXCommonShareView()

@property (nonatomic, strong) UIView *bottomContainerView;
@property (nonatomic, strong) MASConstraint *bottomBottomConstraint;

@property (nonatomic, strong) MASConstraint *bottomContainerViewHeightConstraint;
@property (nonatomic, strong) MASConstraint *platformContainerViewTopMarginConstraint;

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) UIView  *platformContainerView;
@property (nonatomic, strong) UIView  *weChatBtn;
@property (nonatomic, strong) UIView  *weChatTimeLineBtn;
@property (nonatomic, strong) UIView  *qqBtn;
@property (nonatomic, strong) UIView  *sinaBtn;

@property (nonatomic, strong) id  bindingData;
@property (nonatomic, copy) HXShareCompletionHandler  handler;

@end

@implementation HXCommonShareView

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self UIConfig];
    }
    return self;
}

- (void)UIConfig {
    
    self.bottomContainerViewHeight = 183;
    self.platformContainerViewTopMargin = 29;
    
    [self addSubview:self.maskView];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self addSubview:self.bottomContainerView];
    [self.bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        self.bottomContainerViewHeightConstraint =  make.height.equalTo(@(self.bottomContainerViewHeight));
        make.top.equalTo(self.mas_bottom).priorityMedium();
        self.bottomBottomConstraint = make.bottom.equalTo(self).with.offset(0);
        [self.bottomBottomConstraint deactivate];
    }];
    
    
    
    
    self.platformContainerView = [UIView new];
    [self.bottomContainerView addSubview:self.platformContainerView];
    [self.platformContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
       self.platformContainerViewTopMarginConstraint =  make.top.equalTo(self.bottomContainerView).with.offset(self.platformContainerViewTopMargin);
        make.left.right.equalTo(self.bottomContainerView);
    }];
    
    
    
    UIButton *cancelBtn = [UIButton new];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [cancelBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomContainerView addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(50));
        make.left.right.bottom.equalTo(self.bottomContainerView);
    }];
    
    UIView *line = [UIView new];
    line.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1];
    [self.bottomContainerView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(cancelBtn);
        make.height.equalTo(@(.5));
    }];
}

#pragma mark - System Method

#pragma mark - Public Method
- (void)showInView:(UIView *)targetView platform:(HXCommonShareViewPlatform)platform bindingData:(id)bindingData completionHandler:(HXShareCompletionHandler)completionHandler {
    
    self.handler = completionHandler;
    
    
    self.bindingData = bindingData;
    [self.bottomContainerViewHeightConstraint setOffset:self.bottomContainerViewHeight];
    [self.platformContainerViewTopMarginConstraint setOffset:self.platformContainerViewTopMargin];
    
    if (self.platformContainerView.superview) {//not custom config
        NSMutableArray *platArr = [NSMutableArray array];
        if (platform & HXCommonShareViewPlatform_WeChat) {
            [platArr addObject:self.weChatBtn];
            [self.platformContainerView addSubview:self.weChatBtn];
        }
        if (platform & HXCommonShareViewPlatform_WeChatTimeLine) {
            [platArr addObject:self.weChatTimeLineBtn];
            [self.platformContainerView addSubview:self.weChatTimeLineBtn];
        }
        if (platform & HXCommonShareViewPlatform_QQ) {
            [platArr addObject:self.qqBtn];
            [self.platformContainerView addSubview:self.qqBtn];
        }
        if (platform & HXCommonShareViewPlatform_Sina) {
            [platArr addObject:self.sinaBtn];
            [self.platformContainerView addSubview:self.sinaBtn];
        }
        
        [platArr mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
        //设置array的垂直方向的约束
        [platArr mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.platformContainerView);
            make.bottom.lessThanOrEqualTo(self.platformContainerView);
        }];
    }
    
    [targetView addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(targetView);
    }];
    
    
    self.maskView.alpha = 0.0;
    [self.bottomBottomConstraint deactivate];
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.35 animations:^{
        self.maskView.alpha = 0.6;
        [self.bottomBottomConstraint activate];
        [self layoutIfNeeded];
    }];
}

- (void)dismiss {
    self.handler = nil;
    [UIView animateWithDuration:0.35 animations:^{
        self.maskView.alpha = 0.0;
        [self.bottomBottomConstraint deactivate];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)customLayout:(void (^)(UIView * _Nonnull))layoutBlock {
    for (UIView *item in self.bottomContainerView.subviews) {
        [item removeFromSuperview];
    }
    layoutBlock(self.bottomContainerView);
}

- (void)bindingActionInView:(UIView *)targetView platform:(HXCommonShareViewPlatform)platform {
    
    for (UIGestureRecognizer *ges in [targetView.gestureRecognizers copy]) {
        [targetView removeGestureRecognizer:ges];
    }
    
    SEL sel;
    if (platform == HXCommonShareViewPlatform_WeChat) {
        sel = @selector(weChat);
    }
    else if (platform == HXCommonShareViewPlatform_WeChatTimeLine){
        sel = @selector(weChatTimeLine);
    }
    else if (platform == HXCommonShareViewPlatform_QQ){
        sel = @selector(qq);
    }
    else if (platform == HXCommonShareViewPlatform_Sina){
        sel = @selector(sina);
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:sel];
    targetView.userInteractionEnabled = YES;
    [targetView addGestureRecognizer:tap];
}

#pragma mark - Override

#pragma mark - Private Method
- (void)weChat {
    if (self.handler) {
        self.handler(HXCommonShareViewPlatform_WeChat);
    }
    
    [self dismiss];
}

- (void)weChatTimeLine {
    if (self.handler) {
        self.handler(HXCommonShareViewPlatform_WeChatTimeLine);
    }
    
    [self dismiss];
}

- (void)qq {
    if (self.handler) {
        self.handler(HXCommonShareViewPlatform_QQ);
    }
    
    [self dismiss];
}

- (void)sina {
    if (self.handler) {
        self.handler(HXCommonShareViewPlatform_Sina);
    }
    
    [self dismiss];
}

- (UIImage *)imageInSpecificBundleWithName:(NSString *)imageName {
    
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[HXCommonShareView class]] pathForResource:@"HXShareResources" ofType:@"bundle"]];
    
    return [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
    
}
#pragma mark - Delegate

#pragma mark - Setter And Getter
- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor blackColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

- (UIView *)bottomContainerView {
    if (!_bottomContainerView) {
        _bottomContainerView = [[UIView alloc] init];
        _bottomContainerView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomContainerView;
}


- (UIView *)weChatBtn {
    if (!_weChatBtn) {
        HXImgTextCombineView *_weChatImgText = [[HXImgTextCombineView alloc] init];
        _weChatImgText.imageView.image = [self imageInSpecificBundleWithName:@"wechat"];
        _weChatImgText.titleLB.text = @"微信好友";
        _weChatImgText.titleLB.font = [UIFont systemFontOfSize:12];
        _weChatImgText.titleLB.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1];;
        _weChatImgText.style = ImgTextStyleImgTop;
        _weChatImgText.distance = 5;
        [_weChatImgText reloadUI];
        [_weChatImgText addTargetForClickEvent:self action:@selector(weChat)];
        
        _weChatBtn = _weChatImgText;
    }
    return _weChatBtn;
}

- (UIView *)weChatTimeLineBtn {
    if (!_weChatTimeLineBtn) {
        HXImgTextCombineView *_weChatTimeLineImgText = [[HXImgTextCombineView alloc] init];
        _weChatTimeLineImgText.imageView.image = [self imageInSpecificBundleWithName:@"timeline"];
        _weChatTimeLineImgText.titleLB.text = @"朋友圈";
        _weChatTimeLineImgText.titleLB.font = [UIFont systemFontOfSize:12];
        _weChatTimeLineImgText.titleLB.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1];;
        _weChatTimeLineImgText.style = ImgTextStyleImgTop;
        _weChatTimeLineImgText.distance = 5;
        [_weChatTimeLineImgText reloadUI];
        [_weChatTimeLineImgText addTargetForClickEvent:self action:@selector(weChatTimeLine)];
        
        _weChatTimeLineBtn = _weChatTimeLineImgText;
    }
    return _weChatTimeLineBtn;
}

- (UIView *)qqBtn {
    if (!_qqBtn) {
        HXImgTextCombineView *_qqImgText = [[HXImgTextCombineView alloc] init];
        _qqImgText.imageView.image = [self imageInSpecificBundleWithName:@"qq"];
        _qqImgText.titleLB.text = @"QQ";
        _qqImgText.titleLB.font = [UIFont systemFontOfSize:12];
        _qqImgText.titleLB.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1];;
        _qqImgText.style = ImgTextStyleImgTop;
        _qqImgText.distance = 5;
        [_qqImgText reloadUI];
        [_qqImgText addTargetForClickEvent:self action:@selector(qq)];
        
        _qqBtn = _qqImgText;
    }
    return _qqBtn;
}

- (UIView *)sinaBtn {
    if (!_sinaBtn) {
        HXImgTextCombineView *_sinaImgText = [[HXImgTextCombineView alloc] init];
        
        _sinaImgText.imageView.image = [self imageInSpecificBundleWithName:@"sina"];
        _sinaImgText.titleLB.text = @"微博";
        _sinaImgText.titleLB.font = [UIFont systemFontOfSize:12];
        _sinaImgText.titleLB.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1];
        _sinaImgText.style = ImgTextStyleImgTop;
        _sinaImgText.distance = 5;
        [_sinaImgText reloadUI];
        [_sinaImgText addTargetForClickEvent:self action:@selector(sina)];
        
        _sinaBtn = _sinaImgText;
        
    }
    return _sinaBtn;
}



#pragma mark - Dealloc
@end





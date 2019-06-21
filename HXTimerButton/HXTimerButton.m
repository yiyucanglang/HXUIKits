//
//  HXTimerButton.m
//  ZMParentsProject
//
//  Created by James on 18/01/2018.
//  Copyright © 2018 Sea. All rights reserved.
//

#import "HXTimerButton.h"
#import <Masonry/Masonry.h>
@interface HXTimerButton()
@property (nonatomic, strong) UIButton  *timerBtn;
@property (nonatomic, strong) NSTimer   *timer;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, strong) NSString  *formatTitle;
@end

@implementation HXTimerButton

#pragma mark - Life Cycle
- (instancetype)initWithNormalTitle:(NSString *)normalTitle titleFont:(UIFont *)titleFont normalTitleColor:(UIColor *)normalTitleColor runningTitleColor:(UIColor *)runningTitleColor countDownValue:(NSInteger)countDownValue runningformatTitle:(NSString *)formatTitle {
    if (self = [super init]) {
        
        NSAssert(normalTitle && formatTitle && normalTitleColor && runningTitleColor, @"参数不应为空");
        
        self.totalCount               = countDownValue;
        self.formatTitle              = formatTitle;
        self.timerBtn.titleLabel.font = titleFont;
        [self.timerBtn setTitle:normalTitle forState:UIControlStateNormal];
        [self.timerBtn setTitleColor:normalTitleColor forState:UIControlStateNormal];
        [self.timerBtn setTitleColor:runningTitleColor forState:UIControlStateDisabled];
        
        [self UILayout];
        
    }
    return self;
}

#pragma mark - System Mehthod
- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self stop];
}

#pragma mark - Private Method
- (void)UILayout {
    [self addSubview:self.timerBtn];
    [self.timerBtn setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.timerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)handleCountDown {
    
    self.count--;
    if (self.count <= 0) {
        [self stop];
    }
    else {
        [self.timerBtn setTitle:[NSString stringWithFormat:self.formatTitle, @(self.count)] forState:UIControlStateDisabled];
    }
}

#pragma mark - Public Method
- (void)start {
    
    [self stop];
    
    
    self.count = self.totalCount;
    self.timerBtn.enabled = NO;
    [self.timerBtn setTitle:[NSString stringWithFormat:self.formatTitle, @(self.count)] forState:UIControlStateDisabled];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleCountDown) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stop {
    [self.timer invalidate];
    self.timer = nil;
    self.timerBtn.enabled = YES;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    [self.timerBtn addTarget:target action:action forControlEvents:controlEvents];
}

- (void)setAlignment:(UIControlContentHorizontalAlignment)alignment {
    self.timerBtn.contentHorizontalAlignment = alignment;
}

#pragma mark - Delegate


#pragma mark - Getter And Setter
- (UIButton *)timerBtn {
    if (!_timerBtn) {
        _timerBtn = [[UIButton alloc] init];
    }
    return _timerBtn;
}

#pragma mark - Dealloc
@end

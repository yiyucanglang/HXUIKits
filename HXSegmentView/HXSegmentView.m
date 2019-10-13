//
//  HXSegmentView.m
//  ParentDemo
//
//  Created by James on 2019/9/27.
//  Copyright © 2019 DaHuanXiong. All rights reserved.
//

#import "HXSegmentView.h"
@interface HXSegmentView()
@property (nonatomic, strong) NSArray  *titleArr;
@property (nonatomic, strong) UIView  *sliderView;
@property (nonatomic, strong) UIButton  *currentSelectedBtn;
@property (nonatomic, assign) CGFloat   titleWidth;
@end

@implementation HXSegmentView

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame titleArr:(NSArray *)titleArr {
    NSAssert(titleArr.count > 1, @"标题数量");
    self.titleArr = titleArr;
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)UIConfig {
    CGFloat width  = (self.frame.size.width/self.titleArr.count);
    CGFloat hegiht = self.frame.size.height;
    
    self.titleWidth = width;
    
    self.clipsToBounds = YES;
    self.layer.cornerRadius = self.frame.size.height/2;
    
    [self addSubview:self.sliderView];
    self.sliderView.frame = CGRectMake(0, 0, width, hegiht);
    
    
    for (NSInteger i = 0; i < self.titleArr.count; i++) {
        UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        titleBtn.frame = CGRectMake(i * width, 0, width, hegiht);
        titleBtn.adjustsImageWhenDisabled    = NO;
        titleBtn.adjustsImageWhenHighlighted = NO;
         titleBtn.tintAdjustmentMode = NO;
        titleBtn.tag = 666 + i;
        titleBtn.titleLabel.font = self.titleFont;
        [titleBtn setTitleColor:self.normalTitleColor forState:UIControlStateNormal];
        [titleBtn addTarget:self action:@selector(_selected:) forControlEvents:UIControlEventTouchUpInside];
        [titleBtn setTitle:self.titleArr[i] forState:UIControlStateNormal];
        if (i == 0) {
            titleBtn.selected = YES;
            self.currentSelectedBtn = titleBtn;
        }
        
        [self addSubview:titleBtn];
    }
    
    [self reloadUI];
}

#pragma mark - System Method

#pragma mark - Public Method
- (void)reloadUI {
    
    self.sliderView.backgroundColor = self.sliderColor;
    
    for (NSInteger i = 0; i < self.titleArr.count; i++) {
        UIButton *titleBtn = (UIButton *)[self viewWithTag:i + 666];
        [titleBtn setTitleColor:self.normalTitleColor forState:UIControlStateNormal];
        [titleBtn setTitleColor:self.normalTitleColor forState:UIControlStateHighlighted];
        
        [titleBtn setTitleColor:self.selectedTitleColor forState:UIControlStateSelected];
        [titleBtn setTitleColor:self.selectedTitleColor forState:UIControlStateSelected | UIControlStateHighlighted];
        titleBtn.titleLabel.font = self.titleFont;
    }
    
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = self.normalTitleColor.CGColor;
}

- (void)switchToIndex:(NSInteger)index {
    UIButton *selectedBtn = [self viewWithTag:index + 666];
    [self _selected:selectedBtn];
}

#pragma mark - Override

#pragma mark - Private Method
- (void)_selected:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    
    self.currentSelectedBtn.selected = NO;
    
    sender.selected = YES;
    self.currentSelectedBtn = sender;
    
    NSInteger index = sender.tag - 666;
    
    CGRect sliderFrame = self.sliderView.frame;
    sliderFrame.origin.x = index * self.titleWidth;
    
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.15 animations:^{
        
        self.sliderView.frame = sliderFrame;
    } completion:^(BOOL finished) {
        
        
        self.userInteractionEnabled = YES;
    }];
    
    
    [self updateActionType:0 userInfo:@{indexKey : @(index), titleKey : sender.currentTitle?:@""}];
}

#pragma mark - Delegate

#pragma mark - Setter And Getter
- (UIColor *)sliderColor {
    if (!_sliderColor) {
        _sliderColor = [[UIColor alloc] initWithRed:239/255.0 green:76/255.0 blue:79/255.0 alpha:1];
    }
    return _sliderColor;
}

- (UIColor *)normalTitleColor {
    if (!_normalTitleColor) {
        _normalTitleColor = [[UIColor alloc] initWithRed:239/255.0 green:76/255.0 blue:79/255.0 alpha:1];
    }
    return _normalTitleColor;
}

- (UIColor *)selectedTitleColor {
    if (!_selectedTitleColor) {
        _selectedTitleColor = [UIColor whiteColor];
    }
    return _selectedTitleColor;
}

- (UIFont *)titleFont {
    if (!_titleFont) {
        _titleFont = [UIFont systemFontOfSize:14];
    }
    return _titleFont;
}

- (UIView *)sliderView {
    if (!_sliderView) {
        _sliderView = [UIView new];
        _sliderView.layer.cornerRadius = self.frame.size.height/2;
        _sliderView.layer.masksToBounds = YES;
        _sliderView.backgroundColor = self.sliderColor;
    }
    return _sliderView;
}




#pragma mark - Dealloc
@end

//
//  HXSegmentView.h
//  ParentDemo
//
//  Created by James on 2019/9/27.
//  Copyright © 2019 DaHuanXiong. All rights reserved.
//

#import <HXConvenientListView/HXConvenientListView.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *indexKey = @"indexKey";

static NSString *titleKey = @"titleKey";

@interface HXSegmentView : HXBaseConvenientView


/**
 rgba(239, 76, 79, 1)
 */
@property (nonatomic, strong) UIColor  *sliderColor;


/**
 rgba(239, 76, 79, 1)
 */
@property (nonatomic, strong) UIColor  *normalTitleColor;

/**
 whiteColor
 */
@property (nonatomic, strong) UIColor  *selectedTitleColor;

/**
 [UIFont systemFontOfSize:14]
 */
@property (nonatomic, strong) UIFont   *titleFont;


@property (nonatomic, strong, readonly) NSArray  *titleArr;

- (instancetype)initWithFrame:(CGRect)frame titleArr:(NSArray *)titleArr NS_DESIGNATED_INITIALIZER;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;


/**
 refresh UI
 @warning when UI Config Opetion changed must call this
 */
- (void)reloadUI;

- (void)switchToIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END

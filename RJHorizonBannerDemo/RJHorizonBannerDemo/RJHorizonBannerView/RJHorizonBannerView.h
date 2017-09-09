//
//  RJHorizonMsgShowView.h
//  FamilyDoctor
//
//  Created by Po on 2017/4/13.
//  Copyright © 2017年 Po. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RJHorizonBannerView : UIView
@property (strong, nonatomic) UIScrollView      * scrollView;
@property (strong, nonatomic) UIPageControl     * pageControl;


@property (assign, nonatomic) BOOL                isAutoScroll;         //自动滚动（default is YES）

/**
 创建视图
 */
- (void)build;


/**
 设置图片

 @param datas 文件数据
 */
- (void)setImagesFileName:(NSArray *)datas;


/**
 设置图片

 @param urls 网络数据
 */
- (void)setImagesUrls:(NSArray *)urls;


/**
 开始计时器
 */
- (void)startTimer;

/**
 结束计时器
 */
- (void)endTimer;


/**
 设置滚动时间间隔

 @param intevalTime 滚动的时间间隔
 */
- (void)setScrollIntevalTime:(CGFloat)intevalTime;


/**
 设置点击回调
 */
- (void)setSelectedBlock:(void(^)(NSInteger count))block;
@end

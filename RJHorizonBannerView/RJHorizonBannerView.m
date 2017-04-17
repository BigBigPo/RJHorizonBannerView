//
//  RJHorizonMsgShowView.m
//  FamilyDoctor
//
//  Created by Po on 2017/4/13.
//  Copyright © 2017年 Po. All rights reserved.
//

#import "RJHorizonBannerView.h"
#import "UIImageView+WebCache.h"

typedef NS_ENUM(NSUInteger, RJDragType) {
    RJDragTypeNone = 0,         //无手势
    RJDragTypeTouching,         //有手势
    RJDragTypeWait              //等待
};

typedef void(^SelectedBlock)(NSInteger count);

@interface RJHorizonBannerView () <UIScrollViewDelegate>
@property (strong, nonatomic) NSArray * imagesArray;
@property (strong, nonatomic) NSArray * imageViewArray;

@property (assign, nonatomic) BOOL isNetResource;           //网络资源
@property (assign, nonatomic) CGFloat intevalTime;          //间隔时间
@property (assign, nonatomic) RJDragType dragType;          //拖动状态
@property (assign, nonatomic) NSInteger waitTime;           //延时次数
@property (assign, nonatomic) NSInteger currentPage;          //当前页面


@property (strong, nonatomic) dispatch_source_t   timer;    //计时器
@property (copy, nonatomic) SelectedBlock selectedBlock;    //点击回调Block
@end

@implementation RJHorizonMsgShowView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initData];
    }
    return self;
}

#pragma mark - user-define initialization
- (void)initData {
    _currentPage = 0;
    _intevalTime = 3.0;
    _dragType = RJDragTypeNone;
    _waitTime = 0;
    _isAutoScroll = YES;
    
}

- (void)initInterface {

    [self getScrollView];
    [self getPageControl];
    
    NSMutableArray * temp = [NSMutableArray array];
    for (NSInteger i = 0; i < 3; i ++) {
        CGRect rect = self.bounds;
        rect.origin.x = rect.size.width * i;
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:rect];
        [_scrollView addSubview:imageView];
        [temp addObject:imageView];
    }
    _imageViewArray = [NSArray arrayWithArray:temp];
}

#pragma mark - event
- (void)scrollEvent {
    if (_dragType == RJDragTypeTouching) {
        return;
    } else if (_dragType == RJDragTypeWait) {
        if (_waitTime != 0) {
            _waitTime -= 1;
            return;
        }
        _dragType = RJDragTypeNone;
    }
    
    
    RJWeak(self)
    [UIView animateWithDuration:0.5 animations:^{
        [weakself.scrollView setContentOffset:CGPointMake(SCWidth * 2, 0)];
    } completion:^(BOOL finished) {
        if (finished) {
            NSInteger num = weakself.currentPage + 1;
            weakself.currentPage = [weakself checkNumWithPage:num];
            [weakself reSetPosition];
        }
    }];
}

- (void)tapEvent:(UITapGestureRecognizer *)tap {
    if (_selectedBlock) {
        _selectedBlock(_currentPage);
    }
}

#pragma mark - function
- (void)build {
    [self initInterface];
}

- (void)reloadData {
    
    [_pageControl setNumberOfPages:_imagesArray.count];
    _currentPage = 0;

    [self reSetPosition];
    if (_isAutoScroll) {
        [self startTimer];
    }
}

- (void)startTimer {
    [self endTimer];
    
    RJWeak(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_intevalTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakself.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
        dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, _intevalTime * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(_timer, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself scrollEvent];
            });
        });
        dispatch_resume(_timer);
    });
    
}

- (void)endTimer {
    if (_timer) {
        dispatch_source_cancel(_timer);
    }
}

- (void)reSetPosition {
    for (NSInteger count = 0; count < _imageViewArray.count; count ++) {
        UIImageView * imageView = _imageViewArray[count];
        NSInteger num = _currentPage - 1 + count;
        if (num < 0 ) {
            num = _imagesArray.count + num;
        } else if (num >= _imagesArray.count) {
            num = 0;
        }
        [self setImageView:imageView withImageNum:num];
    }
    
    [_pageControl setCurrentPage:_currentPage];
    [_scrollView setContentOffset:CGPointMake(_scrollView.bounds.size.width, 0)];
}

#pragma mark - delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _dragType = RJDragTypeTouching;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _dragType = RJDragTypeWait;
    if (_waitTime == 0) {
        _waitTime += 1;
    }
    
    NSInteger num = _currentPage;
    if (_scrollView.contentOffset.x == 0) {
        num -= 1;
    } else if (_scrollView.contentOffset.x == _scrollView.bounds.size.width * 2) {
        num += 1;
    }

    if (num != _currentPage) {
        _currentPage = [self checkNumWithPage:num];
        [self reSetPosition];
    }
    
    
//    if (_isAutoScroll) {
//        RJWeak(self)
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_intevalTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [weakself startTimer];
//        });
//    }
    
}
#pragma mark - notification

#pragma mark - setter
- (void)setImagesFileName:(NSArray *)datas {
    _isNetResource = NO;
    _imagesArray = [NSArray arrayWithArray:datas];
    [self reloadData];
}

- (void)setImagesUrls:(NSArray *)urls {
    _isNetResource = YES;
    _imagesArray = [NSArray arrayWithArray:urls];
    [self reloadData];
}

- (void)setIsAutoScroll:(BOOL)isAutoScroll {
    if (_isAutoScroll == isAutoScroll) {
        return;
    }
    
    _isAutoScroll = isAutoScroll;
    if (_isAutoScroll) {
        [self startTimer];
    } else {
        if (_timer) {
            dispatch_source_cancel(_timer);
        }
    }
}

- (void)setScrollIntevalTime:(CGFloat)intevalTime {
    _intevalTime = intevalTime;
    if (_isAutoScroll && _timer) {
        dispatch_source_cancel(_timer);
        [self startTimer];
    }
}

- (void)setImageView:(UIImageView *)imageView withImageNum:(NSInteger)count {
    if (_isNetResource) {
        [imageView sd_setImageWithURL:_imagesArray[count] placeholderImage:nil];
    } else {
        [imageView setImage:RJImage(_imagesArray[count])];
    }
}

- (void)setSelectedBlock:(void(^)(NSInteger count))block {
    _selectedBlock = nil;
    _selectedBlock = block;
    
}

#pragma mark - getter
- (UIScrollView *)getScrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [_scrollView setContentSize:CGSizeMake(self.bounds.size.width * 3, 0)];
        [_scrollView setBackgroundColor:[UIColor blackColor]];
        [_scrollView setDelegate:self];
        [_scrollView setPagingEnabled:YES];
        [_scrollView setBounces:NO];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [self addSubview:_scrollView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)];
        tap.numberOfTapsRequired = 1;
        [_scrollView addGestureRecognizer:tap];
    }
    return _scrollView;
}

- (UIPageControl *)getPageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        [_pageControl setCenter:CGPointMake(_scrollView.frame.size.width / 2, _scrollView.frame.size.height - 20)];
        [_pageControl setNumberOfPages:_imagesArray.count];
        [_pageControl setCurrentPage:0];
        //_pageControl.transform=CGAffineTransformScale(CGAffineTransformIdentity, 2, 2);
        [self addSubview:_pageControl];
    }
    return _pageControl;
}

- (NSInteger)checkNumWithPage:(NSInteger)page {
    if (page < 0) {
        page = _imagesArray.count + page;
    } else if (page >= _imagesArray.count) {
        page = 0;
    }
    return page;
}
@end

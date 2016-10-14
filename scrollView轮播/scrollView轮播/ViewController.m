//
//  ViewController.m
//  scrollView轮播
//
//  Created by 杨雪原 on 2016/9/26.
//  Copyright © 2016年 杨雪原. All rights reserved.
//
//  ScrollView 极限优化  只需2个UIImageView即可
//  因为我们最多同时能看到的图片数是2张
//

#import "ViewController.h"

@interface ViewController ()<UIScrollViewDelegate>

@property CGFloat width;
@property CGFloat height;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (assign, nonatomic) NSInteger currentIndex;

@property (assign, nonatomic) NSInteger nextIndex;
// banner图片的数量
@property (assign, nonatomic) NSInteger count;

@property (strong, nonatomic) NSTimer *timer;
// 一直在中间的imageView
@property (strong, nonatomic) UIImageView *centerView;
// 左边或右边的imageView
@property (strong, nonatomic) UIImageView *reuseView;

@end

@implementation ViewController

/*
    Xcode 8, iOS 10 之后 一些地方有一些变化， 要从storyboard中拿到一些控件的尺寸 不能再从viewDidLoad中获取了
    否则获取到的尺寸一定时错误的  有一些控件尺寸默认时1000， 而是到viewDidLayoutSubviews，
 */

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _width = _scrollView.frame.size.width;
    _height = _scrollView.frame.size.height;
    
    // 设置scrollview可以滚动区域大小
    _scrollView.contentSize = CGSizeMake(_width*3, _height);
    
    // 设置偏移量
    _scrollView.contentOffset = CGPointMake(_width, 0);
    
    _centerView = [[UIImageView alloc] initWithFrame:CGRectMake(_width, 0, _width, _height)];
    _reuseView = [[UIImageView alloc] init];
    
    // 把centerView初始为第一张图片
    _centerView.image = [UIImage imageNamed:@"0"];
    
    [self.scrollView addSubview:_centerView];
    [self.scrollView addSubview:_reuseView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currentIndex = 0;
    _nextIndex = 0;
    _count = 5;
    
    // ScrollView代理协议
    _scrollView.delegate = self;
    
    _pageControl.numberOfPages = _count;
    _pageControl.currentPage = 0;

    [self startNSTimer];
}
// 定时器banner自动轮播滚动
- (void)startNSTimer
{
    // 这里timer会被加入到当前线程的RunLoop中 模式默认为NSDefaultRunLoopMode
    //而如果当前线程就是主线程，也就是UI线程时，某些UI事件，比如UIScrollView的拖动操作，会将Run Loop切换成NSEventTrackingRunLoopMode模式，在这个过程中，默认的NSDefaultRunLoopMode模式中注册的事件是不会被执行的
    _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(changeImg) userInfo:nil repeats:YES];
    
    // 使用NSRunLoopCommonModes模式，把timer加入到当前Run Loop中
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes]; 
}

- (void)changeImg
{
    CGPoint point = _scrollView.contentOffset;
    point.x += _width;
    [_scrollView setContentOffset:point animated:YES];
}

- (void)endNSTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float x = _scrollView.contentOffset.x;
    NSLog(@"---%f", x);
    // 向右滚动
    if (x > _width) {
        // 定位reuseView
        _reuseView.frame = CGRectMake(_width*2, 0, _width, _height);
        // 算出下一页
        _nextIndex = (_currentIndex + 1) % _count;
        _reuseView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld", (long)_nextIndex]];
        if (x >= _width*2) {
            scrollView.contentOffset = CGPointMake(_width, 0);
            // 更换中心位置图片
            _centerView.image = _reuseView.image;
            // 三目 判断所有图片滚动完返回第一张
            _currentIndex = ++_currentIndex>_count -1 ? 0:_currentIndex;
        }
    }
    // 向左滚动
    if (x < _width) {
        _reuseView.frame = CGRectMake(0, 0, _width, _height);
        _nextIndex = (_currentIndex + _count -1) % _count;
        _reuseView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld", (long)_nextIndex]];
        if (x <= 0) {
            scrollView.contentOffset = CGPointMake(_width, 0);
            _centerView.image = _reuseView.image;
            _currentIndex = --_currentIndex<0 ? (_count -1):_currentIndex;
        }
    }
    
    _pageControl.currentPage = _currentIndex;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startNSTimer];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self endNSTimer];
}
@end

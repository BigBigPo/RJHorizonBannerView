//
//  ViewController.m
//  RJHorizonBannerDemo
//
//  Created by Po on 2017/9/8.
//  Copyright © 2017年 Po. All rights reserved.
//

#import "ViewController.h"
#import "RJHorizonBannerView.h"
@interface ViewController ()

@property (strong, nonatomic) RJHorizonBannerView * bannerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:[self getBannerView]];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_bannerView build];
    
}

- (RJHorizonBannerView *)getBannerView {
    if (!_bannerView) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        _bannerView = [[RJHorizonBannerView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 400)];
        //http://mtl.ttsqgs.com/images/img/8888/1.jpg
        [_bannerView setImagesFileName:@[@"1",@"2", @"3", @"4",@"5"]];
    }
    return _bannerView;
}


@end

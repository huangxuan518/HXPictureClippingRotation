//
//  ViewController.m
//  HXPictureClippingRotation
//
//  Created by 黄轩 on 16/3/15.
//  Copyright © 2016年 黄轩 blog.libuqing.com. All rights reserved.
//

#import "ViewController.h"
#import "HXCutPictureViewController.h"

@interface ViewController ()

@property (nonatomic,strong) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //去裁剪界面按钮
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"裁剪图片" style:UIBarButtonItemStyleDone target:self action:@selector(gotoCutPhotoViewController)];
    self.navigationItem.rightBarButtonItem = item;
    
    //裁剪完成图片显示
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width/2)];
    _imageView.layer.borderWidth = 1;
    _imageView.layer.borderColor = [UIColor orangeColor].CGColor;
    [self.view addSubview:_imageView];
}

//去图片裁剪页面
- (void)gotoCutPhotoViewController {
    HXCutPictureViewController *vc = [[HXCutPictureViewController alloc] initWithCropImage:[UIImage imageNamed:@"927_v36.jpg"]  cropSize:_imageView.frame.size title:@"裁剪" isLast:YES];
    vc.completion = ^(HXCutPictureViewController *vc, UIImage *finishImage) {
        _imageView.image = finishImage;
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

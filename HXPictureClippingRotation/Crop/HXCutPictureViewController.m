//
//  HXCutPictureViewController.m
//  HXPictureClippingRotation
//
//  Created by 黄轩 on 16/3/15.
//  Copyright © 2016年 黄轩 blog.libuqing.com. All rights reserved.
//

#import "HXCutPictureViewController.h"
#import "HXImageCropper.h"
#import "UIImage-Extension.h"

@interface HXCutPictureViewController ()

@property (nonatomic,strong) HXImageCropper *cropperView;

@end

@implementation HXCutPictureViewController

- (instancetype)initWithCropImage:(UIImage*)cropImage cropSize:(CGSize)cropSize title:(NSString *)title isLast:(BOOL)isLast {
	if (self = [super init]) {
        
        self.title = title;
        
        NSString *rightTitle;
        if (isLast) {
            rightTitle = @"确认";
        } else {
            rightTitle = @"下一张";
        }
        
        //导航
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:rightTitle style:UIBarButtonItemStyleDone target:self action:@selector(nextButtonAction:)];
        self.navigationItem.rightBarButtonItem = item;
        
        //裁剪View
        _cropperView = [[HXImageCropper alloc] initWithCropImage:cropImage cropSize:cropSize];
        [self.view addSubview:_cropperView];
        
        //旋转按钮
        UIImage *image = [UIImage imageNamed:@"rotate"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];//button的类型
        button.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 64 - button.frame.size.height - 28,50, 50);//button的frame
        button.center = CGPointMake(self.view.center.x,self.view.center.y);
        button.frame = CGRectMake(button.frame.origin.x, [[UIScreen mainScreen] bounds].size.height - 64 - button.frame.size.height - 28,50, 50);//button的frame
        button.backgroundColor = [UIColor clearColor];
        [button setImage:image forState:UIControlStateNormal];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        button.contentVerticalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.imageEdgeInsets = UIEdgeInsetsMake(0,13,0,0);
        [button setTitle:@"旋转" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleEdgeInsets = UIEdgeInsetsMake(30, -20, 0, 0);
        [button addTarget:self action:@selector(rotateCropViewClockwise:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:button];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
}

#pragma mark - Action

//完成裁剪
- (void)nextButtonAction:(UIButton *)sender {
    if (_completion) {
        _completion(self,[_cropperView getCroppedImage]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

//旋转
- (void)rotateCropViewClockwise:(id)senders {
    [_cropperView actionRotate];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end

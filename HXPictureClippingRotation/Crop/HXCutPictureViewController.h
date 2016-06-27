//
//  HXCutPictureViewController.h
//  HXPictureClippingRotation
//
//  Created by 黄轩 on 16/3/15.
//  Copyright © 2016年 黄轩 blog.libuqing.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXCutPictureViewController : UIViewController

@property (nonatomic,copy) void (^completion)(HXCutPictureViewController *vc, UIImage *finishImage);

/**
 *  图片裁剪界面初始化
 *
 *  @param cropImage 需要裁剪的图片
 *  @param cropSize  裁剪框的size
 *  @param title     裁剪界面的标题
 *  @param isLast    是否最后一张 最后一张的裁剪按钮文本显示不一样
 *
 *  @return <#return value description#>
 */
- (instancetype)initWithCropImage:(UIImage*)cropImage cropSize:(CGSize)cropSize title:(NSString *)title isLast:(BOOL)isLast;

@end



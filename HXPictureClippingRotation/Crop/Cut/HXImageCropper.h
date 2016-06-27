//
//  HXImageCropper.h
//  HXPictureClippingRotation
//
//  Created by 黄轩 on 16/3/15.
//  Copyright © 2016年 黄轩 blog.libuqing.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXImageCropper : UIView

/**
 *  图片裁剪初始化
 *
 *  @param cropImage 需要裁剪的图片
 *  @param cropSize  裁剪框的size 目前裁剪框的宽度为屏幕宽度
 *
 *  @return <#return value description#>
 */
- (id)initWithCropImage:(UIImage*)cropImage cropSize:(CGSize)cropSize;

- (UIImage*)getCroppedImage;//获取裁剪后的图片

- (void) actionRotate;//旋转

- (id)init __deprecated_msg("Use `- (id)initWithCropImage:(UIImage*)cropImage cropSize:(CGSize)cropSize`");
- (id)initWithFrame:(CGRect)frame __deprecated_msg("Use `- (id)initWithCropImage:(UIImage*)cropImage cropSize:(CGSize)cropSize`");

@end

//
//  HXImageCropper.m
//  HXPictureClippingRotation
//
//  Created by 黄轩 on 16/3/15.
//  Copyright © 2016年 黄轩 blog.libuqing.com. All rights reserved.
//

#define MAX_ZOOMSCALE 3

#import "HXImageCropper.h"
#import "UIImage-Extension.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import <QuartzCore/QuartzCore.h>

@interface HXImageCropper() <UIGestureRecognizerDelegate>

@property (nonatomic,strong) UIImage *inputImage;//输入Image
@property (nonatomic,strong) UIImageView *imgView;
@property (nonatomic,assign) CGRect cropRect;//裁剪的rect
@property (nonatomic,strong) UIView *cropperView;
@property (nonatomic,assign) double imageScale;
@property (nonatomic,assign) double translateX;
@property (nonatomic,assign) double translateY;
@property (nonatomic,assign) CGRect imgViewframeInitValue;
@property (nonatomic,assign) CGPoint imgViewcenterInitValue;
@property (nonatomic,assign) CGSize realCropsize;

@end

@implementation HXImageCropper

#pragma mark - initialize

- (id)init {
    self = [super init];
    if (self) {

    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (id)initWithCropImage:(UIImage*)cropImage cropSize:(CGSize)cropSize {
    self = [super init];
    if(self)
    {
        _translateX =0;
        _translateY =0;
        
        self.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 64);
        
        if(cropImage.size.width <= cropSize.width || cropImage.size.height <= cropSize.height) {
            cropImage = [cropImage resizedImageToFitInSize:CGSizeMake(cropSize.width*1.3, cropSize.height*1.3) scaleIfSmaller:YES];
        }
        
        self.inputImage = cropImage;

        _imageScale = cropSize.width/self.inputImage.size.width ;
        
        CGRect imgViewBound = CGRectMake(0, 0, _inputImage.size.width*_imageScale, _inputImage.size.height*_imageScale);   //이미지가 생성될 사이즈.
        _imgView = [[UIImageView alloc] initWithFrame:imgViewBound];
        _imgView.center = self.center;
        _imgView.image = _inputImage;
        _imgView.backgroundColor = [UIColor whiteColor];
        
        _imgViewframeInitValue = _imgView.frame;
        _imgViewcenterInitValue = _imgView.center;
        _realCropsize = cropSize;
        
        _cropRect = CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height - 64 - cropSize.height)/2, cropSize.width, cropSize.height);
        _cropperView = [[UIView alloc] initWithFrame:_cropRect];
        _cropperView.backgroundColor = [UIColor clearColor];
        _cropperView.layer.borderColor = [UIColor whiteColor].CGColor;
        _cropperView.layer.borderWidth = 1.5;
        
        [self addSubview:_imgView];
        [self addSubview:_cropperView];
        [self setupGestureRecognizer];
        
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, _cropRect.origin.y)];
        topView.backgroundColor = [UIColor blackColor];
        topView.alpha = 0.7;
        topView.userInteractionEnabled = NO;
        
        [self addSubview:topView];
        
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _cropRect.origin.y + _cropRect.size.height, [[UIScreen mainScreen] bounds].size.width, ([[UIScreen mainScreen] bounds].size.height - 64 - _cropRect.size.height)/2)];
        bottomView.backgroundColor = [UIColor blackColor];
        bottomView.alpha = 0.7;
        bottomView.userInteractionEnabled = NO;
        
        [self addSubview:bottomView];
        
        self.clipsToBounds = YES;
    }
    return self;
}


#pragma mark - UIGestureAction

- (void)zoomAction:(UIGestureRecognizer *)sender {
    CGFloat factor = [(UIPinchGestureRecognizer *)sender scale];
    static CGFloat lastScale=1;
    
    if([sender state] == UIGestureRecognizerStateBegan) {
        lastScale =1;
    }
    
    if ([sender state] == UIGestureRecognizerStateChanged
        || [sender state] == UIGestureRecognizerStateEnded) {
        CGRect imgViewFrame = _imgView.frame;
        CGFloat minX,minY,maxX,maxY,imgViewMaxX,imgViewMaxY;
        minX= CGRectGetMinX(_cropRect);
        minY= CGRectGetMinY(_cropRect);
        maxX= CGRectGetMaxX(_cropRect);
        maxY= CGRectGetMaxY(_cropRect);
        
        CGFloat currentScale = [[self.imgView.layer valueForKeyPath:@"transform.scale.x"] floatValue];
        const CGFloat kMaxScale = 2.0;
        CGFloat newScale = 1 -  (lastScale - factor);
        newScale = MIN(newScale, kMaxScale / currentScale);
        
        imgViewFrame.size.width = imgViewFrame.size.width * newScale;
        imgViewFrame.size.height = imgViewFrame.size.height * newScale;
        imgViewFrame.origin.x = self.imgView.center.x - imgViewFrame.size.width/2;
        imgViewFrame.origin.y = self.imgView.center.y - imgViewFrame.size.height/2;
        
        imgViewMaxX= CGRectGetMaxX(imgViewFrame);
        imgViewMaxY= CGRectGetMaxY(imgViewFrame);
        
        NSInteger collideState = 0;
        
        if(imgViewFrame.origin.x >= minX)
        {
            collideState = 1;
        }
        else if(imgViewFrame.origin.y >= minY)
        {
            collideState = 2;
        }
        else if(imgViewMaxX <= maxX)
        {
            collideState = 3;
        }
        else if(imgViewMaxY <= maxY)
        {
            collideState = 4;
        }

        if(collideState >0)
        {
            
            if(lastScale - factor <= 0)
            {
                lastScale = factor;
                CGAffineTransform transformN = CGAffineTransformScale(self.imgView.transform, newScale, newScale);
                self.imgView.transform = transformN;
            }
            else
            {
                lastScale = factor;
                
                CGPoint newcenter = _imgView.center;
                
                if(collideState ==1 || collideState ==3)
                {
                    newcenter.x = _cropperView.center.x;
                }
                else if(collideState ==2 || collideState ==4)
                {
                    newcenter.y = _cropperView.center.y;
                }
                
                [UIView animateWithDuration:0.5f animations:^(void) {
                    
                    self.imgView.center = newcenter;
                    [sender reset];
                    
                } ];
                
            }
            
        }
        else
        {
            CGAffineTransform transformN = CGAffineTransformScale(self.imgView.transform, newScale, newScale);
            self.imgView.transform = transformN;
            lastScale = factor;
        }
        
    }
    
}

- (void)panAction:(UIPanGestureRecognizer *)gesture {
    
    static CGPoint prevLoc;
    CGPoint location = [gesture locationInView:self];
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        prevLoc = location;
    }
    
    if ((gesture.state == UIGestureRecognizerStateChanged) || (gesture.state == UIGestureRecognizerStateEnded))
    {
        
        CGFloat minX,minY,maxX,maxY,imgViewMaxX,imgViewMaxY;
        
        _translateX =  (location.x - prevLoc.x);
        _translateY =  (location.y - prevLoc.y);
        
        CGPoint center = self.imgView.center;
        minX= CGRectGetMinX(_cropRect);
        minY= CGRectGetMinY(_cropRect);
        maxX= CGRectGetMaxX(_cropRect);
        maxY= CGRectGetMaxY(_cropRect);
        
        center.x =center.x +_translateX;
        center.y = center.y +_translateY;
        
        imgViewMaxX= center.x + _imgView.frame.size.width/2;
        imgViewMaxY= center.y+ _imgView.frame.size.height/2;
        
        if(  (center.x - (_imgView.frame.size.width/2) ) >= minX)
        {
            center.x = minX + (_imgView.frame.size.width/2) ;
        }
        if( center.y - (_imgView.frame.size.height/2) >= minY)
        {
            center.y = minY + (_imgView.frame.size.height/2) ;
        }
        if(imgViewMaxX <= maxX)
        {
            center.x = maxX - (_imgView.frame.size.width/2);
        }
        if(imgViewMaxY <= maxY)
        {
            center.y = maxY - (_imgView.frame.size.height/2);
        }
        
        self.imgView.center = center;
        prevLoc = location;
    }
}

- (void)RotationAction:(UIGestureRecognizer *)sender {
    UIRotationGestureRecognizer *recognizer = (UIRotationGestureRecognizer *) sender;
    static CGFloat rot=0;

    if(sender.state == UIGestureRecognizerStateBegan)
    {
        rot = recognizer.rotation;
    }
    
    if(sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged)
    {
        self.imgView.transform = CGAffineTransformRotate(self.imgView.transform, recognizer.rotation - rot);
        rot =recognizer.rotation;
        
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if(self.imgView.frame.size.width < _cropperView.frame.size.width || self.imgView.frame.size.height < _cropperView.frame.size.height)
        {
            double scale = MAX(_cropperView.frame.size.width/self.imgView.frame.size.width,_cropperView.frame.size.height/self.imgView.frame.size.height) + 0.01;
            
            self.imgView.transform = CGAffineTransformScale(self.imgView.transform,scale, scale);
        }
    }
}

- (void)DoubleTapAction:(UIGestureRecognizer *)sender
{
    //双击放大或者还原
    if (self.imgView.transform.a > 1 &&  self.imgView.transform.d > 1) {
        [UIView animateWithDuration:0.2f animations:^(void) {
            self.imgView.transform = CGAffineTransformIdentity;
            self.imgView.center = _cropperView.center;
        } ];
    } else {
        [UIView animateWithDuration:0.2f animations:^(void) {
            self.imgView.transform = CGAffineTransformScale(self.imgView.transform,2.0, 2.0);
            self.imgView.center = _cropperView.center;
        } ];
    }
}


- (void) setupGestureRecognizer
{
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomAction:)];
    [pinchGestureRecognizer setDelegate:self];
    
     UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [panGestureRecognizer setMinimumNumberOfTouches:1];
    [panGestureRecognizer setMaximumNumberOfTouches:1];
    [panGestureRecognizer setDelegate:self];
    
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DoubleTapAction:)];
    [doubleTapGestureRecognizer setDelegate:self];
    doubleTapGestureRecognizer.numberOfTapsRequired =2;
    
    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(RotationAction:)];
    [rotationGestureRecognizer setDelegate:self];
    
    [self addGestureRecognizer:pinchGestureRecognizer];
    [self addGestureRecognizer:panGestureRecognizer];
    [self addGestureRecognizer:doubleTapGestureRecognizer];
    [self addGestureRecognizer:rotationGestureRecognizer];
    
}

- (UIImage*) getCroppedImage {
    double zoomScale = [[self.imgView.layer valueForKeyPath:@"transform.scale.x"] floatValue];
    double rotationZ = [[self.imgView.layer valueForKeyPath:@"transform.rotation.z"] floatValue];
    
    CGPoint cropperViewOrigin = CGPointMake( (_cropperView.frame.origin.x - _imgView.frame.origin.x)  *1/zoomScale ,
                                            ( _cropperView.frame.origin.y - _imgView.frame.origin.y ) * 1/zoomScale
                                            );
    CGSize cropperViewSize = CGSizeMake(_cropperView.frame.size.width * (1/zoomScale) ,_cropperView.frame.size.height * (1/zoomScale));
    
    CGRect CropinView = CGRectMake(cropperViewOrigin.x, cropperViewOrigin.y, cropperViewSize.width  , cropperViewSize.height);
    
    CGSize CropinViewSize = CGSizeMake((CropinView.size.width*(1/_imageScale)),(CropinView.size.height*(1/_imageScale)));
    
    
    if((NSInteger)CropinViewSize.width % 2 == 1)
    {
        CropinViewSize.width = ceil(CropinViewSize.width);
    }
    if((NSInteger)CropinViewSize.height % 2 == 1)
    {
        CropinViewSize.height = ceil(CropinViewSize.height);
    }
    
    CGRect CropRectinImage = CGRectMake((NSInteger)(CropinView.origin.x * (1/_imageScale)) ,(NSInteger)( CropinView.origin.y * (1/_imageScale)), (NSInteger)CropinViewSize.width,(NSInteger)CropinViewSize.height);
    
    UIImage *rotInputImage = [[_inputImage fixOrientation] imageRotatedByRadians:rotationZ];
    UIImage *newImage = [rotInputImage cropImage:CropRectinImage];
    
    if(newImage.size.width != _realCropsize.width)
    {
        newImage = [newImage resizedImageToFitInSize:_realCropsize scaleIfSmaller:YES];
    }
    
    return newImage;
}

- (BOOL) saveCroppedImage:(NSString *) path {
    return [UIImagePNGRepresentation([self getCroppedImage]) writeToFile:path atomically:YES];
}

- (void) actionRotate {
    [UIView animateWithDuration:0.15 animations:^{
        
        self.imgView.transform = CGAffineTransformRotate(self.imgView.transform,-M_PI/2);
        
        if(self.imgView.frame.size.width < _cropperView.frame.size.width || self.imgView.frame.size.height < _cropperView.frame.size.height)
        {
            double scale = MAX(_cropperView.frame.size.width/self.imgView.frame.size.width,_cropperView.frame.size.height/self.imgView.frame.size.height) + 0.01;
            
            self.imgView.transform = CGAffineTransformScale(self.imgView.transform,scale, scale);
            
        }
    }];
}

- (void) actionRestore {
    [UIView animateWithDuration:0.2 animations:^{
        self.imgView.transform = CGAffineTransformIdentity;
        self.imgView.center = _cropperView.center;
    }];
}

@end

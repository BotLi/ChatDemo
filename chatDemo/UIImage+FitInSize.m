//
//  UIImage+FitInSize.m
//  chatDemo
//
//  Created by Li Bot on 2016/7/11.
//  Copyright © 2016年 Li Bot. All rights reserved.
//

#import "UIImage+FitInSize.h"

@implementation UIImage (FitInSize)
-(UIImage*)fitInSize:(CGSize)fitInSize
{
    CGSize newSize = [self makeSize:self.size fitInSize:fitInSize];
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(CGSize)makeSize:(CGSize)originalSize fitInSize:(CGSize)boxSize
{
    if (originalSize.height == 0) {
        originalSize.height = boxSize.height;
    }
    if (originalSize.width == 0) {
        originalSize.width = boxSize.width;
    }
    
    float widthScale = 0;
    float heightScale = 0;
    
    widthScale = boxSize.width/originalSize.width;
    heightScale = boxSize.height/originalSize.height;
    
    float scale = MIN(widthScale, heightScale);
    
    CGSize newSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
    
    return newSize;
}
@end

//
//  ImageUtils.m
//  TesseractSample
//
//  Created by Jillian Crossley on 11/13/2013.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import "ImageUtils.h"
#define IS_RETINA_DISPLAY() [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f

#define DISPLAY_SCALE IS_RETINA_DISPLAY() ? 2.0f : 1.0


@implementation ImageUtils

+ (UIImageView *) imageViewWithImageNamed: (NSString *)imageName{
    return [self imageViewWithImage: [UIImage imageNamed:imageName]];
    
}


+ (UIImageView *) imageViewWithImage:(UIImage*)image{
    UIImage *scaledImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
    
    return  [[UIImageView alloc]initWithImage: scaledImage];
}

+ (UIImage *) scaleImagedName: (NSString *)imageName{
    return [self scaleImage: [UIImage imageNamed:imageName]];
}

+ (UIImage *) scaleImage: (UIImage *)image{
    return  [[UIImage alloc] initWithCGImage:image.CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
}

@end

//
//  ImageUtils.h
//  TesseractSample
//
//  Created by Jillian Crossley on 11/13/2013.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageUtils : NSObject

+ (UIImageView *) imageViewWithImageNamed: (NSString *)imageName;
+ (UIImageView *) imageViewWithImage:(UIImage*)image;

+ (UIImage *) scaleImagedName: (NSString *)imageName;
+ (UIImage *) scaleImage: (UIImage *)image;

@end

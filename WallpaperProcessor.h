//
//  WallpaperProcessor.h
//  TesseractSample
//
//  Created by Jillian Crossley on 2013-09-25.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WallpaperProcessor : NSObject{
}
+ (UIImage *) template;
+ (UIImage *) mask;
+ (void) setTemplate: (UIImage *) screen;
+ (UIImage *)process: (UIImage *)wallpaper;
+(UIImage *)makeThumbnail: (UIImage *)image;



@end

//
//  WallpaperImage.h
//  TesseractSample
//
//  Created by Jillian Crossley on 2013-09-28.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WallpaperImage : UIImage{
    UIImage *wallpaper;
    NSString *docPath;
}

-(id)initWithImage: (UIImage *)image;
- (id)initWithFolderPath: (NSString *)path;
- (UIImage *)getWallpaper;
- (void) saveWallpaper;

@end

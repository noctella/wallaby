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
    UIImage *thumbnail;
    NSString *docPath;
}

-(id)initWithWallpaper: (UIImage *)wallpaperImage andThumbnail: (UIImage *)thumbnailImage;
- (id)initWithFolderPath: (NSString *)path;
- (UIImage *)getWallpaper;
- (UIImage *)getThumbnail;
- (void) saveWallpaper;
- (void) saveThumbnail;

@end

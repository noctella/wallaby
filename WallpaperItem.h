//
//  WallpaperImage.h
//  TesseractSample
//
//  Created by Jillian Crossley on 2013-09-28.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WallpaperItem : UIImageView{
    UIImage *wallpaper;
    UIImage *background;
    UIImage *thumbnail;
    NSString *docPath;
    UIImageView *thumbnailView;
    UIImageView *wallpaperView;
    int index;
    
}

-(id)initWithWallpaper: (UIImage *)wallpaperImage andBackground: (UIImage *) background andThumbnail: (UIImage *)thumbnailImage;
- (id)initWithFolderPath: (NSString *)path;
- (UIImage *)getWallpaper;
- (UIImage *)getThumbnail;
- (UIImage *)getBackground;
- (UIImageView*)getThumbnailView;
- (UIImageView*)getWallpaperView;
- (void) setWallpaper: (UIImage *) image;
- (void) saveData;
- (void) deleteData;
- (void) setThumbnailViewFrame: (CGRect) frame;
- (void) setWallpaperViewFrame: (CGRect) frame;



@end

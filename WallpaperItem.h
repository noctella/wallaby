//
//  WallpaperImage.h
//  TesseractSample
//
//  Created by Jillian Crossley on 2013-09-28.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WallpaperItem : NSObject <NSCopying> {
    int index;
}

@property UIImage* wallpaper;
@property UIImage *thumbnail;
@property UIImage *background;
@property NSString *docPath;
@property UIImageView *thumbnailView;
@property UIImageView *wallpaperView;
@property bool isEditing;
@property bool isLinked;
@property bool isDisposed;
@property int index;


-(id)initWithWallpaper: (UIImage *)wallpaperImage andBackground: (UIImage *) background andThumbnail: (UIImage *)thumbnailImage;
- (id)initWithFolderPath: (NSString *)path;
- (UIImage *)getWallpaper;
- (UIImage *)getThumbnail;
- (UIImage *)getBackground;
- (void) saveData;
- (void) deleteData;
- (void) setThumbnailViewFrame: (CGRect) frame;
- (void) setWallpaperViewFrame: (CGRect) frame;
-(void) loadData;




@end

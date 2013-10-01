//
//  WallpaperImage.m
//  TesseractSample
//
//  Created by Jillian Crossley on 2013-09-28.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import "WallpaperImage.h"
#import "WallpaperDatabase.h"
#define WALLPAPER_IMAGE_FILE @"wallpaper.png"
#define THUMBNAIL_IMAGE_FILE @"thumbnail.png"

@implementation WallpaperImage


-(id)initWithWallpaper: (UIImage *)wallpaperImage andThumbnail: (UIImage *)thumbnailImage{
    self = [super init];
    if(self){
        wallpaper = wallpaperImage;
        thumbnail = thumbnailImage;
    }
    return self;
    
}

- (id)initWithFolderPath:(NSString *)path
{
    self = [super init];
    if(self){
         docPath = path;
    }
    return self;
}

-(UIImage *)getWallpaper{
    if(wallpaper != nil) return wallpaper;
    NSString *wallpaperPath = [docPath stringByAppendingPathComponent:WALLPAPER_IMAGE_FILE];
    return [UIImage imageWithContentsOfFile:wallpaperPath];
}

-(UIImage *)getThumbnail{
    if(thumbnail != nil) return thumbnail;
    NSString *thumbnailPath = [docPath stringByAppendingPathComponent:THUMBNAIL_IMAGE_FILE];
    return [UIImage imageWithContentsOfFile:thumbnailPath];
}

- (BOOL)createDataPath {
    
    if (docPath == nil) {
        docPath = [WallpaperDatabase nextWallpaperPath];
    }
    
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:docPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) {
        NSLog(@"Error creating data path: %@", [error localizedDescription]);
    }
    return success;
    
}

- (void)saveWallpaper {
        
    [self createDataPath];
    
    NSString *wallpaperPath = [docPath stringByAppendingPathComponent:WALLPAPER_IMAGE_FILE];
    NSData *wallpaperImageData = UIImagePNGRepresentation(wallpaper);
    [wallpaperImageData writeToFile:wallpaperPath atomically:YES];
    NSLog(@"%@", wallpaperPath);

    
    //wallpaper = nil;
    
}

- (void)saveThumbnail {
    
    [self createDataPath];
    
    NSString *thumbnailPath = [docPath stringByAppendingPathComponent:THUMBNAIL_IMAGE_FILE];
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnail);
    [thumbnailImageData writeToFile:thumbnailPath atomically:YES];
}
    
@end

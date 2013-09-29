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

@implementation WallpaperImage


-(id)initWithImage: (UIImage *) image{
    self = [super init];
    if(self){
        wallpaper = image;
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
@end

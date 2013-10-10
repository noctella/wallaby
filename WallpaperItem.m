//
//  WallpaperImage.m
//  TesseractSample
//
//  Created by Jillian Crossley on 2013-09-28.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import "WallpaperItem.h"
#import "WallpaperDatabase.h"
#define WALLPAPER_IMAGE_FILE @"wallpaper.png"
#define BACKGROUND_IMAGE_FILE @"background.png"
#define THUMBNAIL_IMAGE_FILE @"thumbnail.png"

@implementation WallpaperItem



-(id)initWithWallpaper: (UIImage *)wallpaperImage andBackground: (UIImage *) backgroundImage andThumbnail: (UIImage *)thumbnailImage{
    self = [super init];
    if(self){
        wallpaper = wallpaperImage;
        background = backgroundImage;
        thumbnail = thumbnailImage;
        
        [self createDataPath];
        [self saveWallpaper];
        [self saveBackground];
        [self saveThumbnail];
        NSLog(@"seet the wallpaper");
        
        thumbnailView = [[UIImageView alloc]initWithImage:thumbnailImage];
        thumbnailView.userInteractionEnabled = YES;
        
        wallpaperView =[[UIImageView alloc]initWithImage:wallpaperImage];
        wallpaperView.userInteractionEnabled = YES;
    }
    return self;
    
}

-(void)setIndex: (NSString *) i{
    index = i;
}

-(int)getIndex{
    return index;
}

-(void)loadData{
    NSLog(@"loading data");

    if(thumbnail == nil){
        thumbnail = [self getThumbnail];
        [thumbnailView setImage:thumbnail];
    
        wallpaper = [self getWallpaper];
        [wallpaperView setImage:wallpaper];
    }
}

- (id)initWithFolderPath:(NSString *)path
{
    self = [super init];
    if(self){
         docPath = path;

        thumbnail = [self getThumbnail];
        
        thumbnailView = [[UIImageView alloc]init];
        [thumbnailView setImage:thumbnail];
        thumbnailView.userInteractionEnabled = YES;
        
        wallpaper = [self getWallpaper];
        wallpaperView = [[UIImageView alloc]init];
        wallpaperView.userInteractionEnabled = YES;
        
    }
    
    return self;
}

-(UIImageView*)getThumbnailView{
    return thumbnailView;
}

- (void) setThumbnailViewFrame: (CGRect) frame{
    thumbnailView.frame = frame;
}

-(UIImageView*)getWallpaperView{
    return wallpaperView;
}

- (void) setWallpaperViewFrame: (CGRect) frame{
    wallpaperView.frame = frame;
}


-(UIImage *)getWallpaper{
    if(wallpaper != nil) return wallpaper;
    NSString *wallpaperPath = [docPath stringByAppendingPathComponent:WALLPAPER_IMAGE_FILE];
    return [UIImage imageWithContentsOfFile:wallpaperPath];
}

-(void) setWallpaper: (UIImage *) image{
    wallpaper = image;
    [wallpaperView setImage:wallpaper];
    [self saveWallpaper];
}

-(UIImage *)getThumbnail{
    if(thumbnail != nil) return thumbnail;
    NSString *thumbnailPath = [docPath stringByAppendingPathComponent:THUMBNAIL_IMAGE_FILE];
    return [UIImage imageWithContentsOfFile:thumbnailPath];
}

-(UIImage *)getBackground{
    if(background != nil) return background;
    NSString *backgroundPath = [docPath stringByAppendingPathComponent:BACKGROUND_IMAGE_FILE];
    return [UIImage imageWithContentsOfFile:backgroundPath];
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

-(void)saveWallpaper {
    NSString *wallpaperPath = [docPath stringByAppendingPathComponent:WALLPAPER_IMAGE_FILE];
    NSData *wallpaperImageData = UIImagePNGRepresentation(wallpaper);
    [wallpaperImageData writeToFile:wallpaperPath atomically:YES];
    NSLog(@"%@", wallpaperPath);
}

-(void) saveBackground {
    NSString *backgroundPath = [docPath stringByAppendingPathComponent:BACKGROUND_IMAGE_FILE];
    NSData *backgroundImageData = UIImagePNGRepresentation(background);
    [backgroundImageData writeToFile:backgroundPath atomically:YES];
    NSLog(@"%@", backgroundPath);
}

-(void) saveThumbnail {
    NSString *thumbnailPath = [docPath stringByAppendingPathComponent:THUMBNAIL_IMAGE_FILE];
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnail);
    [thumbnailImageData writeToFile:thumbnailPath atomically:YES];
}

- (void)saveData {
        
    [self createDataPath];
    
    NSString *wallpaperPath = [docPath stringByAppendingPathComponent:WALLPAPER_IMAGE_FILE];
    NSData *wallpaperImageData = UIImagePNGRepresentation(wallpaper);
    [wallpaperImageData writeToFile:wallpaperPath atomically:YES];
    NSLog(@"%@", wallpaperPath);

    NSString *thumbnailPath = [docPath stringByAppendingPathComponent:THUMBNAIL_IMAGE_FILE];
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnail);
    [thumbnailImageData writeToFile:thumbnailPath atomically:YES];
    
    //wallpaper = nil;
    
}

- (void)deleteData{
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:docPath error:&error];
    if (!success) {
        NSLog(@"Error removing document path: %@", error.localizedDescription);
    }
}

@end

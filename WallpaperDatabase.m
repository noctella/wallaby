//
//  WallpaperDatabase.m
//  TesseractSample
//
//  Created by Jillian Crossley on 2013-09-27.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import "WallpaperDatabase.h"
#import "WallpaperImage.h"
#define HOMESCREEN_IMAGE_FILE @"homescreen.png"

@implementation WallpaperDatabase

+ (NSString *)getPrivateDocsDir {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"Private Documents"];
    
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    
    return documentsDirectory;
    
}


+ (UIImage *) loadHomescreen {
    NSString *documentsDirectory = [WallpaperDatabase getPrivateDocsDir];
    NSLog(@"Loading homescreen from %@", documentsDirectory);
    NSString *fullFolderPath = [documentsDirectory stringByAppendingPathComponent:HOMESCREEN_IMAGE_FILE];
    UIImage *homescreen = [UIImage imageWithContentsOfFile:fullFolderPath];
    NSLog(@"%@", homescreen);
    return homescreen;

}

+ (void) saveHomescreen: (UIImage *) image {
    NSString *documentsDirectory = [WallpaperDatabase getPrivateDocsDir];
    NSString *homescreenPath = [documentsDirectory stringByAppendingPathComponent:HOMESCREEN_IMAGE_FILE];
    NSData *homescreenImageData = UIImagePNGRepresentation(image);
    [homescreenImageData writeToFile:homescreenPath atomically:YES];
}

+ (NSMutableArray *)loadWallpapers {
    
    // Get private docs dir
    NSString *documentsDirectory = [WallpaperDatabase getPrivateDocsDir];
    NSLog(@"Loading wallpapers from %@", documentsDirectory);
    
    // Get contents of documents directory
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (files == nil) {
        NSLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
        return nil;
    }
    
    // Create ScaryBugDoc for each file
    NSMutableArray *wallpapers = [NSMutableArray arrayWithCapacity:files.count];
    for (NSString *file in files) {
        if ([file.pathExtension compare:@"wallpaperImage" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            NSString *fullFolderPath = [documentsDirectory stringByAppendingPathComponent:file];
            WallpaperImage *wallpaperImage = [[WallpaperImage alloc]initWithFolderPath: fullFolderPath];
            [wallpapers addObject:wallpaperImage];
        
        }
    }
    return wallpapers;
    
}

+ (NSString *)nextWallpaperPath {
    
    // Get private docs dir
    NSString *documentsDirectory = [WallpaperDatabase getPrivateDocsDir];
    
    // Get contents of documents directory
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (files == nil) {
        NSLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
        return nil;
    }
    
    // Search for an available name
    int maxNumber = 0;
    for (NSString *file in files) {
        if ([file.pathExtension compare:@"wallpaperImage" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            NSString *fileName = [file stringByDeletingPathExtension];
            maxNumber = MAX(maxNumber, fileName.intValue);
        }
    }
    
    // Get available name
    NSString *availableName = [NSString stringWithFormat:@"%d.wallpaperImage", maxNumber+1];
    return [documentsDirectory stringByAppendingPathComponent:availableName];
    
}

@end

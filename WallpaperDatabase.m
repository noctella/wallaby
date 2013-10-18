//
//  WallpaperDatabase.m
//  TesseractSample
//
//  Created by Jillian Crossley on 2013-09-27.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import "WallpaperDatabase.h"
#import "WallpaperItem.h"
#define TEMPLATE_IMAGE_FILE @"template.png"

@implementation WallpaperDatabase

+ (NSString *)getPrivateDocsDir {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"Private Documents"];
    
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    
    return documentsDirectory;
    
}


+ (UIImage *) loadTemplate {
    NSString *documentsDirectory = [WallpaperDatabase getPrivateDocsDir];
    NSLog(@"Loading template from %@", documentsDirectory);
    NSString *fullFolderPath = [documentsDirectory stringByAppendingPathComponent:TEMPLATE_IMAGE_FILE];
    UIImage *template = [UIImage imageWithContentsOfFile:fullFolderPath];
    return template;

}

+ (void) saveTemplate:(UIImage *)image {
    NSString *documentsDirectory = [WallpaperDatabase getPrivateDocsDir];
    NSString *templatePath = [documentsDirectory stringByAppendingPathComponent:TEMPLATE_IMAGE_FILE];
    NSData *templateImageData = UIImagePNGRepresentation(image);
    [templateImageData writeToFile:templatePath atomically:YES];
    NSLog(@"saved the new template");

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

    NSMutableArray *wallpapers = [NSMutableArray arrayWithCapacity:files.count];
    int i=0;
    for (NSString *file in files) {
        if ([file.pathExtension compare:@"wallpaperImage" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            NSString *fullFolderPath = [documentsDirectory stringByAppendingPathComponent:file];
            WallpaperItem *wallpaperView = [[WallpaperItem alloc]initWithFolderPath: fullFolderPath];
            [wallpaperView setIndex:i ];
            i++;
            [wallpapers addObject:wallpaperView];
        
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

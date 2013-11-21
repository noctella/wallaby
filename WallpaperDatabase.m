//
//  WallpaperDatabase.m
//  TesseractSample
//
//  Created by Jillian Crossley on 2013-09-27.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import "WallpaperDatabase.h"
#import "WallpaperItem.h"
#import "IconItem.h"
#define TEMPLATE_IMAGE_FILE @"template.png"
#define ICON_ITEMS_FILE @"iconItems"

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

+ (void) saveIconItems: (NSMutableArray *) IconItems{
    
   
    // Get private docs dir
    NSString *documentsDirectory = [WallpaperDatabase getPrivateDocsDir];
    NSString *iconItemsPath = [documentsDirectory stringByAppendingPathComponent:ICON_ITEMS_FILE];
     NSError *error;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:iconItemsPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) {
        NSLog(@"Error creating data path: %@", [error localizedDescription]);
    }
    
    int path = 0;
    for(IconItem *item in [IconItem items]){
        NSData *iconItemsData = [NSKeyedArchiver archivedDataWithRootObject:item];
        NSString *availableName = [NSString stringWithFormat:@"%d.iconItem", path];
        NSString *fullPath = [iconItemsPath stringByAppendingPathComponent:availableName];
        [iconItemsData writeToFile:fullPath atomically:YES];
        path++;
    }
    
    NSLog(@"saved icon items");
}

+ (NSMutableArray *) loadIconItems {
    // Get private docs dir
    NSString *documentsDirectory = [WallpaperDatabase getPrivateDocsDir];
    NSString *iconItemsPath = [documentsDirectory stringByAppendingPathComponent:ICON_ITEMS_FILE];
    NSMutableArray *iconItems = [[NSMutableArray alloc]init];

 
    for(int path =0; path< 24; path++){
        NSString *availableName = [NSString stringWithFormat:@"%d.iconItem", path];
        NSString *fullPath = [iconItemsPath stringByAppendingPathComponent:availableName];
       // NSData *itemData = [[NSData alloc]initWithContentsOfFile:fullPath];
       // if(itemData == nil)return nil;
       // NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:itemData];
       // IconItem *item = [[IconItem alloc]initWithCoder:unArchiver];
        IconItem *item = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
        if(item == nil){
          return nil;
        }
        [iconItems addObject:item];
    }
    
    NSLog(@"loaded icon items");
    return iconItems;
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

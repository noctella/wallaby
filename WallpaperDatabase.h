//
//  WallpaperDatabase.h
//  TesseractSample
//
//  Created by Jillian Crossley on 2013-09-27.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WallpaperDatabase : NSObject

+ (NSMutableArray *)loadWallpapers;
+ (NSString *)nextWallpaperPath;

@end

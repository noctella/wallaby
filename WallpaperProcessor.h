//
//  WallpaperProcessor.h
//  TesseractSample
//
//  Created by Jillian Crossley on 2013-09-25.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WallpaperProcessor : NSObject{
    UIImage *homescreen;
    UIImage *mask;
    NSMutableArray *icons;
    NSMutableArray *labels;
    NSMutableArray *labelImages;
}

-(id)initWithHomescreen: (UIImage *)screen;
- (UIImage *)process: (UIImage *)wallpaper;



@end

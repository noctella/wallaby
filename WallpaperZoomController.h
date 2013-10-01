//
//  WallpaperZoomController.h
//  TesseractSample
//
//  Created by Jillian Crossley on 2013-09-19.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WallpaperZoomController : UIViewController{
    __weak IBOutlet UIImageView *ImageView;
   //UIImage *wallpaper;
}


- (IBAction) didTouch: (id) sender;
- (void) setWallpaper: (UIImage*)wallpaper;


@end

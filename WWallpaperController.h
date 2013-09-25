//
//  WWallpaperController.h
//  Wallaby
//
//  Created by Jillian Crossley on 2013-07-12.
//  Copyright (c) 2013 Jillian Crossley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WallpaperZoomController.h"

@interface WWallpaperController : UIViewController
<UIImagePickerControllerDelegate, UIGestureRecognizerDelegate>{
    __weak IBOutlet UIImageView *ImageView;
    UIImage *finalWallpaper;
}

- (IBAction) takePicture:(id) sender;
- (IBAction) didTouch: (UITapGestureRecognizer *)sender;

@end


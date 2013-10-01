//
//  WWallpaperController.h
//  Wallaby
//
//  Created by Jillian Crossley on 2013-07-12.
//  Copyright (c) 2013 Jillian Crossley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WallpaperZoomController.h"
#import "WallpaperProcessor.h"

@interface WWallpaperController : UIViewController
<UIImagePickerControllerDelegate, UIGestureRecognizerDelegate>{
    __weak IBOutlet UIImageView *ImageView;
    IBOutlet UIScrollView *wallpaperScrollView;
    IBOutlet UIScrollView *thumbnailScrollView;
    WallpaperProcessor *wallpaperProcessor;
    NSMutableArray *wallpapers;
    NSString *_docPath;
}

- (IBAction) takePicture:(id) sender;
- (IBAction) didTouchWallpaper: (UITapGestureRecognizer*) sender;
- (IBAction) didTouchThumbnail: (UITapGestureRecognizer *)sender;
@property (nonatomic, weak) id<UIScrollViewDelegate> scrollViewDelegate;
@property (copy) NSString *docPath;

@end


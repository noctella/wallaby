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
#import "InfiniteScrollView.h"
#import "InfiniteThumbnailScrollView.h"

@interface WWallpaperController : UIViewController
<UIImagePickerControllerDelegate, UIGestureRecognizerDelegate>{
    __weak IBOutlet UIImageView *ImageView;
    IBOutlet InfiniteScrollView *wallpaperScrollView;
    IBOutlet InfiniteThumbnailScrollView *thumbnailScrollView;
    WallpaperProcessor *wallpaperProcessor;
    NSString *_docPath;
    IBOutlet UIButton *addWallpaperButton;
    IBOutlet UIButton *changeHomescreenButton;
}

+ (UIImage *) template;
+ (void) setTemplate: (UIImage *)template;
+ (NSMutableArray *) wallpaperItems;


- (IBAction) didTouchWallpaper: (UITapGestureRecognizer*) sender;
- (IBAction) didLongPressThumbnail: (UILongPressGestureRecognizer *) sender;
- (IBAction) didTouchAddWallpaper:(id) sender;
- (IBAction)didTouchDeleteWallpaper:(id) sender;
- (IBAction) didTouchChangeHomescreen: (id) sender;
@property (nonatomic, weak) id<UIScrollViewDelegate> scrollViewDelegate;
@property (copy) NSString *docPath;

@end


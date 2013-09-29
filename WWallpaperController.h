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
    IBOutlet UIScrollView *scrollView;
    WallpaperProcessor *wallpaperProcessor;
    NSMutableArray *wallpapers;
    NSString *_docPath;
}

- (IBAction) takePicture:(id) sender;
- (IBAction) didTouch: (UITapGestureRecognizer *)sender;
//- (void) didTap: (UIImageView*) imageView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (copy) NSString *docPath;
- (void)saveImages;

@end


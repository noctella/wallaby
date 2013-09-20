//
//  WWallpaperController.h
//  Wallaby
//
//  Created by Jillian Crossley on 2013-07-12.
//  Copyright (c) 2013 Jillian Crossley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WWallpaperController : UIViewController
<UIImagePickerControllerDelegate>{
    __weak IBOutlet UIImageView *ImageView;
}

- (IBAction) takePicture:(id) sender;

@end


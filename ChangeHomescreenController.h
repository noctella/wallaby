//
//  ChangeHomescreenController.h
//  TesseractSample
//
//  Created by Jillian Crossley on 2013-10-03.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangeHomescreenController : UIViewController{
    __weak IBOutlet UIImageView *homescreenView;
    //UIImage *wallpaper;
}

- (void) setCurrentHomescreen: (UIImage *)homescreen;
- (IBAction)close:(id)sender;
- (IBAction)newTemplate:(id)sender;

@end

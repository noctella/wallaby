//
//  EditTemplateController.h
//  TesseractSample
//
//  Created by Jillian Crossley on 10/24/2013.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditTemplateController : UIViewController{
    IBOutlet UIImageView *homescreenView;
    UIImage *homescreen;
}

- (void) setCurrentHomescreen: (UIImage *)homescreen;
- (IBAction) didTapApp: (UITapGestureRecognizer *) sender;
- (IBAction)didTouchDoneButton:(id)sender;

@end

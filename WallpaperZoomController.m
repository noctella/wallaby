//
//  WallpaperZoomController.m
//  TesseractSample
//
//  Created by Jillian Crossley on 2013-09-19.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import "WallpaperZoomController.h"

@interface WallpaperZoomController ()

@end



@implementation WallpaperZoomController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) didTouch: (id) sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) setWallpaper: (UIImage*)wallpaper{
    [ImageView setImage: wallpaper];
}

@end

//
//  EditTemplateController.m
//  TesseractSample
//
//  Created by Jillian Crossley on 10/24/2013.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import "EditTemplateController.h"
#import "WallpaperProcessor.h"
#import "WallpaperDatabase.h"
#import "IconItem.h"
#import "objc/runtime.h"

#define IS_RETINA_DISPLAY() [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f

// return the scale value based on device's display (2 retina, 1 other)
#define DISPLAY_SCALE IS_RETINA_DISPLAY() ? 2.0f : 1.0f

@interface EditTemplateController ()

@end

@implementation EditTemplateController

- (id)init{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) setCurrentHomescreen: (UIImage *)homescreen{
    
    
    
    UIImage *scaledHomescreen = [[UIImage alloc] initWithCGImage:homescreen.CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
    
    self->homescreen = scaledHomescreen;

    homescreenView = [[UIImageView alloc]initWithImage:scaledHomescreen];
    [homescreenView setContentMode:UIViewContentModeTop];
    [homescreenView setUserInteractionEnabled:YES];
    [[self view]addSubview:homescreenView];

    //[greyHomescreenView setFrame:<#(CGRect)#>
    
    UIImage *greyHomescreen= [[UIImage alloc] initWithCGImage:[UIImage imageNamed: @"template_grey.png"].CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
    UIImageView *greyHomescreenView = [[UIImageView alloc]initWithImage:greyHomescreen];
    [greyHomescreenView setContentMode:UIViewContentModeTop];

    [[self view]addSubview:greyHomescreenView];
    NSMutableArray *items = [IconItem items];
    for(IconItem *item in items){
        [[item greyIconView]addGestureRecognizer:[item appSelectionTap]];
        [[item appSelectionTap] addTarget:self action:@selector(didTapApp:)];
        [[self view]addSubview:[item greyIconView]];
    }
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [doneButton addTarget:self action:@selector(didTouchDoneButton:) forControlEvents:UIControlEventTouchDown];
    [doneButton setTitle:@"+" forState:UIControlStateNormal];
    doneButton.frame = CGRectMake( 0,0 , 25, 25);
    [[self view ]addSubview:doneButton];
}

- (IBAction)didTouchDoneButton:(id)sender{
    UIImage *template = [WallpaperProcessor processHomescreen:homescreen];
    [WallpaperProcessor setTemplate:template];
    
    [self dismissViewControllerAnimated:YES completion:^(void){
        
    }];
}

- (IBAction) didTapApp: (UITapGestureRecognizer *) sender {
    NSLog(@"didTap app");
    IconItem *item = objc_getAssociatedObject(sender, "iconItem");
    if([item isPresent]){
        [[self view]addSubview:[item greyIconView]];
        [[item greyIconView]addGestureRecognizer:[item appSelectionTap]];
        [[item clearIconView] removeFromSuperview];
        [item setIsPresent:NO];
    }else{
        [[item greyIconView] removeFromSuperview];
        [[self view]addSubview:[item clearIconView]];
        [[item clearIconView] addGestureRecognizer:[item appSelectionTap]];
        [item setIsPresent:YES];
    }

}



- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"view did load");
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

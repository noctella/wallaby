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
#import "ImageUtils.h"


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
    
    
    
    UIImage *scaledHomescreen = [ImageUtils scaleImage:homescreen];
    
    self->homescreen = scaledHomescreen;

    homescreenView = [[UIImageView alloc]initWithImage:scaledHomescreen];
    [homescreenView setContentMode:UIViewContentModeTop];
    [homescreenView setUserInteractionEnabled:YES];
    [[self view]addSubview:homescreenView];

    //[greyHomescreenView setFrame:<#(CGRect)#>
    
    UIImageView *greyHomescreenView = [ImageUtils imageViewWithImageNamed:@"template_grey.png"];
    [greyHomescreenView setContentMode:UIViewContentModeTop];

    [[self view]addSubview:greyHomescreenView];
    NSMutableArray *items = [IconItem items];
    for(IconItem *item in items){
        [[item greyIconTemplateView]addGestureRecognizer:[item appSelectionTap]];
        [[item appSelectionTap] addTarget:self action:@selector(didTapApp:)];
        [[self view]addSubview:[item greyIconTemplateView]];
    }
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [doneButton addTarget:self action:@selector(didTouchDoneButton:) forControlEvents:UIControlEventTouchDown];
    [doneButton setTitle:@"+" forState:UIControlStateNormal];
    doneButton.frame = CGRectMake( 0,0 , 25, 25);
    [[self view ]addSubview:doneButton];
}

- (IBAction)didTouchDoneButton:(id)sender{
    [WallpaperProcessor setTemplateAndIconsWithHomescreen:homescreen];
    [self dismissViewControllerAnimated:YES completion:^(void){
        
    }];
}

- (IBAction) didTapApp: (UITapGestureRecognizer *) sender {
    NSLog(@"didTap app");
    IconItem *item = objc_getAssociatedObject(sender, "iconItem");
    if([item isPresent]){
        [[self view]addSubview:[item greyIconTemplateView]];
        [[item greyIconTemplateView]addGestureRecognizer:[item appSelectionTap]];
        [[item clearIconTemplateView] removeFromSuperview];
        [item setIsPresent:NO];
    }else{
        [[item greyIconTemplateView] removeFromSuperview];
        [[self view]addSubview:[item clearIconTemplateView]];
        [[item clearIconTemplateView] addGestureRecognizer:[item appSelectionTap]];
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

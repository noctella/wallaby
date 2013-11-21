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
         UITapGestureRecognizer *appSelectionTap = [[UITapGestureRecognizer alloc] init];
         objc_setAssociatedObject(appSelectionTap, "iconItem", item, OBJC_ASSOCIATION_ASSIGN);
        
        [appSelectionTap addTarget:self action:@selector(didTapApp:)];
        [item setGreyIconTemplateView:[ImageUtils imageViewWithImageNamed:@"mask_grey.png"]];
        [[item greyIconTemplateView]addGestureRecognizer:appSelectionTap];
        [[item greyIconTemplateView] setFrame:CGRectMake([item iconTemplatePosition].origin.x/2 + 2, [item iconTemplatePosition].origin.y/2 + 2, [item iconTemplatePosition].size.width/2, [item iconTemplatePosition].size.height/2)];
        [[item greyIconTemplateView] setUserInteractionEnabled:YES];
        [[self view]addSubview:[item greyIconTemplateView]];
        
        
        UITapGestureRecognizer *appSelectionTap2 = [[UITapGestureRecognizer alloc] init];
        objc_setAssociatedObject(appSelectionTap2, "iconItem", item, OBJC_ASSOCIATION_ASSIGN);
        
        [appSelectionTap2 addTarget:self action:@selector(didTapApp:)];
        [[item clearIconTemplateView] setUserInteractionEnabled:YES];
        [[item clearIconTemplateView] addGestureRecognizer:appSelectionTap2];
        
        
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
        [[item clearIconTemplateView] removeFromSuperview];
        [item setIsPresent:NO];
    }else{
        [[item greyIconTemplateView] removeFromSuperview];
        [[self view]addSubview:[item clearIconTemplateView]];
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

//
//  ChangeHomescreenController.m
//  TesseractSample
//
//  Created by Jillian Crossley on 2013-10-03.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import "ChangeHomescreenController.h"
#import "WWallpaperController.h"

@interface ChangeHomescreenController ()

@end

@implementation ChangeHomescreenController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setCurrentHomescreen: (UIImage *)homescreen{
    [homescreenView setImage: homescreen];
}

-(IBAction)close:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)newTemplate:(id)sender{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imagePicker setDelegate:self];
    [self presentViewController: imagePicker animated:YES completion:nil];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *newHomescreen = [info objectForKey: UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:^(void){
        UIImage *template = [WallpaperProcessor processHomescreen:newHomescreen];
        [homescreenView setImage:template];
        [WWallpaperController setTemplate:template];
    }];
}
    

@end

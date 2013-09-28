//
//  WWallpaperController.m
//  Wallaby
//
//  Created by Jillian Crossley on 2013-07-12.
//  Copyright (c) 2013 Jillian Crossley. All rights reserved.
//

#import "WWallpaperController.h"
#import "objc/runtime.h"
#import "WallpaperProcessor.h"
#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"

// return true if the device has a retina display, false otherwise
#define IS_RETINA_DISPLAY() [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f

// return the scale value based on device's display (2 retina, 1 other)
#define DISPLAY_SCALE IS_RETINA_DISPLAY() ? 2.0f : 1.0f

// if the device has a retina display return the real scaled pixel size, otherwise the same size will be returned
#define PIXEL_SIZE(size) IS_RETINA_DISPLAY() ? CGSizeMake(size.width/2.0f, size.height/2.0f) : size

#define DISPLAY_WIDTH 640
#define DISPLAY_HEIGHT 1136
#define WALLPAPER_SCALE 3.0
#define WALLPAPER_WIDTH DISPLAY_WIDTH/WALLPAPER_SCALE
#define WALLPAPER_HEIGHT DISPLAY_HEIGHT/WALLPAPER_SCALE
#define WALLPAPER_PADDING 35

@interface WWallpaperController ()

@end

@implementation WWallpaperController
@synthesize scrollView;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"creating view controller");
        numWallpapers = 0;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"view did load");

    UIImage *homescreen = [UIImage imageNamed: @"testLarge.png"];
    
    wallpaperProcessor = [[WallpaperProcessor alloc]initWithHomescreen:homescreen];

    UIImage *image1 = [wallpaperProcessor process: [UIImage imageNamed:@"wallpaper2.PNG"]];
    UIImage *image2 = [wallpaperProcessor process: [UIImage imageNamed:@"wallpaper3.PNG"]];
	UIImage *image3 = [wallpaperProcessor process: [UIImage imageNamed:@"wallpaper4.PNG"]];
    
    
	NSArray *images = [[NSArray alloc] initWithObjects:image1,image2,image3,nil];

    // Now create a UIScrollView to hold the UIImageViews
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,40,325,WALLPAPER_HEIGHT)];

	scrollView.pagingEnabled = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [scrollView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    int numberOfViews = 3;
	for (int i = 0; i < numberOfViews; i++) {
		CGFloat xOrigin = numWallpapers * (WALLPAPER_WIDTH + WALLPAPER_PADDING);
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin,0,WALLPAPER_WIDTH, WALLPAPER_HEIGHT)];
        
		[imageView setImage:[images objectAtIndex:i]];
		[scrollView addSubview:imageView];
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouch:)];
        tap.numberOfTouchesRequired = 1;
        tap.numberOfTapsRequired = 1;
        objc_setAssociatedObject(tap, "image", [images objectAtIndex:i], OBJC_ASSOCIATION_ASSIGN);
        [imageView addGestureRecognizer:tap];
        numWallpapers++;
	}
    
    /*UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
     tap.numberOfTouchesRequired = 1;
     tap.numberOfTapsRequired = 1;
     
     [scrollView addGestureRecognizer:tap];*/
    
    // Set the contentSize equal to the size of the UIImageView
    // scrollView.contentSize = imageView.scrollview.size;
	scrollView.contentSize = CGSizeMake(numWallpapers * (WALLPAPER_WIDTH + WALLPAPER_PADDING), WALLPAPER_HEIGHT);
    
    
	// Finally, add the UIScrollView to the controller's view
    [self.view addSubview:scrollView];
    
    
    // [ImageView initWithImage:finalWallpaper ];
    
    //[ImageView initWithImage:[labelImages objectAtIndex:22] ];
    //[labelImages objectAtIndex:16]

}

-(void) viewDidAppear:(BOOL)animated{
    NSLog(@"view did appear");

    }

- (IBAction) didTouch: (UITapGestureRecognizer*) sender{
    UIImage *wallpaper = objc_getAssociatedObject(sender, "image");
    WallpaperZoomController *zoomController = [[WallpaperZoomController alloc] initWithNibName:@"WallpaperZoomController" bundle:nil];
    
    [self presentViewController: zoomController animated:YES completion: nil];
    [zoomController setWallpaper: wallpaper];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) takePicture: (id) sender{
    // Create the an album controller and image picker
    ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] init];
    ELCImagePickerController *imagePicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    [albumController setParent:imagePicker];
    [imagePicker setDelegate:self];
    
    // Present modally
    [self presentViewController:imagePicker
                       animated:YES
                     completion:nil];    
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
	    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
	
	for(NSDictionary *dict in info) {
        UIImage *image = [wallpaperProcessor process: [dict objectForKey:UIImagePickerControllerOriginalImage]];
        CGFloat xOrigin = numWallpapers * (WALLPAPER_WIDTH + WALLPAPER_PADDING);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin,0,WALLPAPER_WIDTH,WALLPAPER_HEIGHT)];
        
        [imageView setImage:image];
        [scrollView addSubview:imageView];
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouch:)];
        tap.numberOfTouchesRequired = 1;
        tap.numberOfTapsRequired = 1;
        objc_setAssociatedObject(tap, "image", image, OBJC_ASSOCIATION_ASSIGN);
        [imageView addGestureRecognizer:tap];
		[scrollView addSubview:imageView];
        numWallpapers++;
    }
    
    scrollView.contentSize = CGSizeMake(numWallpapers * (WALLPAPER_WIDTH + WALLPAPER_PADDING), WALLPAPER_HEIGHT);
		
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
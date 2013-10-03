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
#import "WallpaperDatabase.h"
#import "WallpaperImage.h"

#define kDataKey        @"Data"
#define kDataFile       @"data.plist"

// return true if the device has a retina display, false otherwise
#define IS_RETINA_DISPLAY() [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f

// return the scale value based on device's display (2 retina, 1 other)
#define DISPLAY_SCALE IS_RETINA_DISPLAY() ? 2.0f : 1.0f

// if the device has a retina display return the real scaled pixel size, otherwise the same size will be returned
#define PIXEL_SIZE(size) IS_RETINA_DISPLAY() ? CGSizeMake(size.width/2.0f, size.height/2.0f) : size

#define DISPLAY_WIDTH 320
#define DISPLAY_HEIGHT 568
#define WALLPAPER_SCALE 0.77
#define WALLPAPER_WIDTH (DISPLAY_WIDTH*WALLPAPER_SCALE)
#define WALLPAPER_HEIGHT (DISPLAY_HEIGHT*WALLPAPER_SCALE)
#define WALLPAPER_PADDING 4
#define STATUS_HEIGHT 23
#define RATIO 2.419

#define THUMBNAIL_SIZE (WALLPAPER_WIDTH/RATIO)

#define WALLPAPER_THUMBNAIL_RATIO (WALLPAPER_WIDTH/THUMBNAIL_SIZE)

@interface WWallpaperController () <UIScrollViewDelegate>

@end

@implementation WWallpaperController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        wallpapers = [WallpaperDatabase loadWallpapers];
        
        NSLog(@"creating view controller");

    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView == wallpaperScrollView){
        [self updateWallpaperContentOffset];
    }else if(scrollView == thumbnailScrollView){
        [self updateThumbnailContentOffset];
    }
    
    
    if ([self.scrollViewDelegate respondsToSelector:_cmd]) {
        [self.scrollViewDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([self.scrollViewDelegate respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:self.scrollViewDelegate];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return ([super respondsToSelector:aSelector] ||
            [self.scrollViewDelegate respondsToSelector:aSelector]);
}

- (void)updateWallpaperContentOffset {
    CGFloat offsetX   = wallpaperScrollView.contentOffset.x;
   thumbnailScrollView.contentOffset = CGPointMake(offsetX/RATIO, 0.0f);
}

- (void)updateThumbnailContentOffset {
    CGFloat offsetX   = thumbnailScrollView.contentOffset.x;
    wallpaperScrollView.contentOffset = CGPointMake(offsetX*RATIO, 0.0f);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"wallpaper width: %f", WALLPAPER_WIDTH);
    
    UIImage *homescreen = [UIImage imageNamed: @"testLarge.png"];
    
    wallpaperProcessor = [[WallpaperProcessor alloc]initWithHomescreen:homescreen];

    // Now create a UIScrollView to hold the UIImageViews
    wallpaperScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,STATUS_HEIGHT,325,WALLPAPER_HEIGHT)];
    thumbnailScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,STATUS_HEIGHT + WALLPAPER_PADDING + WALLPAPER_HEIGHT,325,THUMBNAIL_SIZE)];

    wallpaperScrollView.delegate = self;
	wallpaperScrollView.pagingEnabled = NO;
    //scrollView.showsHorizontalScrollIndicator = NO;
    wallpaperScrollView.showsVerticalScrollIndicator = NO;
    [wallpaperScrollView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    
    thumbnailScrollView.delegate = self;
    thumbnailScrollView.pagingEnabled = NO;
    //scrollView.showsHorizontalScrollIndicator = NO;
     thumbnailScrollView.showsVerticalScrollIndicator = NO;
    [thumbnailScrollView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];

	for (int i = 0; i < [wallpapers count]; i++) {
  
		CGFloat wallpaperXOrigin = ((DISPLAY_WIDTH - WALLPAPER_WIDTH)/2) + i * (WALLPAPER_WIDTH + WALLPAPER_PADDING);
		UIImageView *wallpaperImageView = [[UIImageView alloc] initWithFrame:CGRectMake(wallpaperXOrigin,0,WALLPAPER_WIDTH, WALLPAPER_HEIGHT)];
        //wallpaperImageView
        UIImage *wallpaper = [[wallpapers objectAtIndex:i]getWallpaper];
        [wallpaperImageView setImage:wallpaper];
        [wallpaperScrollView addSubview:wallpaperImageView];
        wallpaperImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *wallpaperTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchWallpaper:)];
        wallpaperTap.numberOfTouchesRequired = 1;
        wallpaperTap.numberOfTapsRequired = 1;
        objc_setAssociatedObject(wallpaperTap, "wallpaperImage", [wallpapers objectAtIndex:i], OBJC_ASSOCIATION_ASSIGN);
        [wallpaperImageView addGestureRecognizer:wallpaperTap];
        
        CGFloat thumbnailXOrigin = ((DISPLAY_WIDTH - THUMBNAIL_SIZE)/2) + (i * (THUMBNAIL_SIZE + WALLPAPER_PADDING));
		UIImageView *thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(thumbnailXOrigin,0,THUMBNAIL_SIZE, THUMBNAIL_SIZE)];
        UIImage *thumbnail = [[wallpapers objectAtIndex:i]getThumbnail];
        [thumbnailImageView setImage:thumbnail];
        [thumbnailScrollView addSubview:thumbnailImageView];
        thumbnailImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *thumbnailTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchThumbnail:)];
        thumbnailTap.numberOfTouchesRequired = 1;
        thumbnailTap.numberOfTapsRequired = 1;
        objc_setAssociatedObject(thumbnailTap, "wallpaperImage", [wallpapers objectAtIndex:i], OBJC_ASSOCIATION_ASSIGN);
        [thumbnailImageView addGestureRecognizer:thumbnailTap];

	}

	wallpaperScrollView.contentSize = CGSizeMake(107 + [wallpapers count] * (WALLPAPER_WIDTH + WALLPAPER_PADDING), WALLPAPER_HEIGHT);
    
     thumbnailScrollView.contentSize = CGSizeMake(107 + [wallpapers count] * (WALLPAPER_WIDTH + WALLPAPER_PADDING), THUMBNAIL_SIZE);

	// Finally, add the UIScrollView to the controller's view
    [self.view addSubview:wallpaperScrollView];
    [self.view addSubview:thumbnailScrollView];

}


-(void) viewDidAppear:(BOOL)animated{
}

- (IBAction) didTouchWallpaper: (UITapGestureRecognizer*) sender{
    WallpaperImage *wallpaperImage = objc_getAssociatedObject(sender, "wallpaperImage");
    UIImage *wallpaper = [wallpaperImage getWallpaper];
    WallpaperZoomController *zoomController = [[WallpaperZoomController alloc] initWithNibName:@"WallpaperZoomController" bundle:nil];
    
    [self presentViewController: zoomController animated:YES completion: nil];
    [zoomController setWallpaper: wallpaper];
}

-(IBAction)didTouchThumbnail:(UITapGestureRecognizer*) sender{
    NSLog(@"touched tumbnail");
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
	   
	for(NSDictionary *dict in info) {
        UIImage *image = [dict objectForKey:UIImagePickerControllerOriginalImage];
        CGFloat wallpaperXOrigin = ((DISPLAY_WIDTH - WALLPAPER_WIDTH)/2) + [wallpapers count] * (WALLPAPER_WIDTH + WALLPAPER_PADDING);
        UIImageView *wallpaperImageView = [[UIImageView alloc] initWithFrame:CGRectMake(wallpaperXOrigin,0,WALLPAPER_WIDTH,WALLPAPER_HEIGHT)];
        
        UIImage *wallpaper = [wallpaperProcessor process: image ];
        UIImage *thumbnail = [wallpaperProcessor makeThumbnail: image];
        WallpaperImage *wallpaperImage = [[WallpaperImage alloc] initWithWallpaper:wallpaper andThumbnail:thumbnail];

        [wallpaperImageView setImage:wallpaper];
        [wallpaperScrollView addSubview:wallpaperImageView];
        wallpaperImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *wallpaperTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchWallpaper:)];
        wallpaperTap.numberOfTouchesRequired = 1;
        wallpaperTap.numberOfTapsRequired = 1;
        objc_setAssociatedObject(wallpaperTap, "wallpaperImage", wallpaperImage, OBJC_ASSOCIATION_ASSIGN);
        [wallpaperImageView addGestureRecognizer:wallpaperTap];
 
        CGFloat thumbnailXOrigin = ((DISPLAY_WIDTH - THUMBNAIL_SIZE)/2) + [wallpapers count] * (THUMBNAIL_SIZE + WALLPAPER_PADDING);
		UIImageView *thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(thumbnailXOrigin,0,THUMBNAIL_SIZE, THUMBNAIL_SIZE)];
        [thumbnailImageView setImage:thumbnail];
        [thumbnailScrollView addSubview:thumbnailImageView];
        thumbnailImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *thumbnailTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchThumbnail:)];
        thumbnailTap.numberOfTouchesRequired = 1;
        thumbnailTap.numberOfTapsRequired = 1;
        objc_setAssociatedObject(thumbnailTap, "wallpaperImage", wallpaperImage, OBJC_ASSOCIATION_ASSIGN);
        [thumbnailImageView addGestureRecognizer:thumbnailTap];
        
        [wallpapers addObject:wallpaperImage];
        [wallpaperImage saveData];

    }
    
    wallpaperScrollView.contentSize = CGSizeMake([wallpapers count] * (WALLPAPER_WIDTH + WALLPAPER_PADDING), WALLPAPER_HEIGHT);
    
    thumbnailScrollView.contentSize = CGSizeMake([wallpapers count] * (THUMBNAIL_SIZE + WALLPAPER_PADDING), THUMBNAIL_SIZE);
		
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

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
#import "WallpaperView.h"
#import "InfiniteScrollView.h"
#import "ChangeHomescreenController.h"

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
#define WALLPAPER_WIDTH 250.0
#define WALLPAPER_HEIGHT (DISPLAY_HEIGHT*WALLPAPER_SCALE)
#define WALLPAPER_PADDING 4.0
#define STATUS_HEIGHT 23
#define RATIO 2.419
#define RATIO_WITH_PADDING ((WALLPAPER_WIDTH + WALLPAPER_PADDING) / (THUMBNAIL_SIZE + WALLPAPER_PADDING))

#define THUMBNAIL_SIZE (WALLPAPER_WIDTH/RATIO)

#define WALLPAPER_THUMBNAIL_RATIO (WALLPAPER_WIDTH/THUMBNAIL_SIZE)

@interface WWallpaperController () <UIScrollViewDelegate>

@end

@implementation WWallpaperController
static UIImage *homescreen;
static NSMutableArray *wallpaperViews;



+ (UIImage *) homescreen
{
    @synchronized(self){
        if(homescreen == nil){
            homescreen = [UIImage alloc];
        }
        return homescreen;
    }
}

+ (void) setHomescreen:(UIImage *)image
{
    @synchronized(self){
        homescreen = image;
        [WallpaperDatabase saveHomescreen: homescreen];
        [WallpaperProcessor setTemplate:homescreen];
        for(WallpaperView *wallpaperView in wallpaperViews){
            [wallpaperView setWallpaper: [WallpaperProcessor process: [wallpaperView getBackground]]];
        }
    }
}

+ (NSMutableArray *) wallpaperViews
{
    @synchronized(self){
        if(wallpaperViews== nil){
            wallpaperViews= [NSMutableArray alloc];
        }
        return wallpaperViews;
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        wallpaperViews = [WallpaperDatabase loadWallpapers];
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
   thumbnailScrollView.contentOffset = CGPointMake(offsetX/RATIO_WITH_PADDING, 0.0f);
}

- (void)updateThumbnailContentOffset {
    CGFloat offsetX   = thumbnailScrollView.contentOffset.x;
    wallpaperScrollView.contentOffset = CGPointMake(offsetX*RATIO_WITH_PADDING, 0.0f);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"wallpaper width: %f", WALLPAPER_WIDTH);
    homescreen = [WallpaperDatabase loadHomescreen];
    
    if (homescreen == nil){
        homescreen = [UIImage imageNamed: @"testLarge.png"];
        [WallpaperDatabase saveHomescreen: homescreen];
        NSLog(@"homescreen was nil :)");
    }
    [WallpaperProcessor setTemplate:homescreen];

    // Now create a UIScrollView to hold the UIImageViews
    wallpaperScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,STATUS_HEIGHT,DISPLAY_WIDTH,WALLPAPER_HEIGHT)];
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

	for (int i = 0; i < [wallpaperViews count]; i++) {
  
		CGFloat wallpaperXOrigin = ((DISPLAY_WIDTH - WALLPAPER_WIDTH)/2) + (i * (WALLPAPER_WIDTH + WALLPAPER_PADDING));
         WallpaperView *wallpaperView = [wallpaperViews objectAtIndex:i];
        [wallpaperView setFrame: CGRectMake(wallpaperXOrigin,0,WALLPAPER_WIDTH, WALLPAPER_HEIGHT)];
        [wallpaperScrollView addSubview:wallpaperView];
      
        UITapGestureRecognizer *wallpaperTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchWallpaper:)];
        wallpaperTap.numberOfTouchesRequired = 1;
        wallpaperTap.numberOfTapsRequired = 1;
        objc_setAssociatedObject(wallpaperTap, "wallpaperImage", [wallpaperViews objectAtIndex:i], OBJC_ASSOCIATION_ASSIGN);
        [wallpaperView addGestureRecognizer:wallpaperTap];
        
        CGFloat thumbnailXOrigin = ((DISPLAY_WIDTH - THUMBNAIL_SIZE)/2) + (i * (THUMBNAIL_SIZE + WALLPAPER_PADDING));
        NSLog(@"starter:%f", (i * (WALLPAPER_WIDTH + WALLPAPER_PADDING)));

		UIImageView *thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(thumbnailXOrigin,0,THUMBNAIL_SIZE, THUMBNAIL_SIZE)];
        UIImage *thumbnail = [[wallpaperViews objectAtIndex:i]getThumbnail];
        [thumbnailImageView setImage:thumbnail];
        [thumbnailScrollView addSubview:thumbnailImageView];
        thumbnailImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *thumbnailTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchThumbnail:)];
        thumbnailTap.numberOfTouchesRequired = 1;
        thumbnailTap.numberOfTapsRequired = 1;
        objc_setAssociatedObject(thumbnailTap, "wallpaperImage", [wallpaperViews objectAtIndex:i], OBJC_ASSOCIATION_ASSIGN);
        [thumbnailImageView addGestureRecognizer:thumbnailTap];

	}

	wallpaperScrollView.contentSize = CGSizeMake(107 + [wallpaperViews count] * (WALLPAPER_WIDTH + WALLPAPER_PADDING), WALLPAPER_HEIGHT);
    
     thumbnailScrollView.contentSize = CGSizeMake(107 + [wallpaperViews count] * (WALLPAPER_WIDTH + WALLPAPER_PADDING), THUMBNAIL_SIZE);
    
    addWallpaperButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [addWallpaperButton addTarget:self action:@selector(didTouchAddWallpaper:) forControlEvents:UIControlEventTouchDown];
    [addWallpaperButton setTitle:@"+" forState:UIControlStateNormal];
    addWallpaperButton.frame = CGRectMake(DISPLAY_WIDTH - 50, DISPLAY_HEIGHT - 50, 25, 25);
    
    changeHomescreenButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [changeHomescreenButton addTarget:self action:@selector(didTouchChangeHomescreen:) forControlEvents:UIControlEventTouchDown];
    [changeHomescreenButton setTitle:@"+" forState:UIControlStateNormal];
    changeHomescreenButton.frame = CGRectMake(DISPLAY_WIDTH - 50, 50, 25, 25);
    
    

	// Finally, add the UIScrollView to the controller's view
    [self.view addSubview:wallpaperScrollView];
    [self.view addSubview:thumbnailScrollView];
    [self.view addSubview:addWallpaperButton];
    [self.view addSubview:changeHomescreenButton];

}


-(void) viewDidAppear:(BOOL)animated{
}

- (IBAction) didTouchAddWallpaper:(id)sender{
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

- (IBAction) didTouchChangeHomescreen: (id) sender {
    ChangeHomescreenController *changeHomescreenController = [[ChangeHomescreenController alloc]initWithNibName:@"ChangeHomescreenController" bundle:nil];
    [self presentViewController:changeHomescreenController animated:YES completion:nil];
    [changeHomescreenController setCurrentHomescreen: homescreen];
}

- (IBAction) didTouchWallpaper: (UITapGestureRecognizer*) sender{
    WallpaperView *wallpaperView = objc_getAssociatedObject(sender, "wallpaperImage");
    UIImage *wallpaper = [wallpaperView getWallpaper];
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

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
	   
	for(NSDictionary *dict in info) {
        UIImage *image = [dict objectForKey:UIImagePickerControllerOriginalImage];
        CGFloat wallpaperXOrigin = ((DISPLAY_WIDTH - WALLPAPER_WIDTH)/2) + [wallpaperViews count] * (WALLPAPER_WIDTH + WALLPAPER_PADDING);
        
        UIImage *wallpaper = [WallpaperProcessor process: image ];
        UIImage *thumbnail = [WallpaperProcessor makeThumbnail: image];
        WallpaperView *wallpaperView = [[WallpaperView alloc] initWithWallpaper:wallpaper andBackground:image andThumbnail:thumbnail];
        [wallpaperView setFrame:CGRectMake(wallpaperXOrigin,0,WALLPAPER_WIDTH,WALLPAPER_HEIGHT)];

        [wallpaperScrollView addSubview:wallpaperView];
        UITapGestureRecognizer *wallpaperTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchWallpaper:)];
        wallpaperTap.numberOfTouchesRequired = 1;
        wallpaperTap.numberOfTapsRequired = 1;
        objc_setAssociatedObject(wallpaperTap, "wallpaperImage", wallpaperView, OBJC_ASSOCIATION_ASSIGN);
        [wallpaperView addGestureRecognizer:wallpaperTap];
 
        CGFloat thumbnailXOrigin = ((DISPLAY_WIDTH - THUMBNAIL_SIZE)/2) + [wallpaperViews count] * (THUMBNAIL_SIZE + WALLPAPER_PADDING);
		UIImageView *thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(thumbnailXOrigin,0,THUMBNAIL_SIZE, THUMBNAIL_SIZE)];
        [thumbnailImageView setImage:thumbnail];
        [thumbnailScrollView addSubview:thumbnailImageView];
        thumbnailImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *thumbnailTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchThumbnail:)];
        thumbnailTap.numberOfTouchesRequired = 1;
        thumbnailTap.numberOfTapsRequired = 1;
        objc_setAssociatedObject(thumbnailTap, "wallpaperImage", wallpaperView, OBJC_ASSOCIATION_ASSIGN);
        [thumbnailImageView addGestureRecognizer:thumbnailTap];
        
        [wallpaperViews addObject:wallpaperView];
        [wallpaperView saveData];

    }
    
    wallpaperScrollView.contentSize = CGSizeMake([wallpaperViews count] * (WALLPAPER_WIDTH + WALLPAPER_PADDING), WALLPAPER_HEIGHT);
    
    thumbnailScrollView.contentSize = CGSizeMake([wallpaperViews count] * (THUMBNAIL_SIZE + WALLPAPER_PADDING), THUMBNAIL_SIZE);
		
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

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
#import "WallpaperItem.h"
#import "InfiniteScrollView.h"
#import "InfiniteThumbnailScrollView.h"
#import "ChangeHomescreenController.h"


#define BUFFER_SIZE 6

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
#define WALLPAPER_PADDING 2.0
#define STATUS_HEIGHT 23
#define RATIO 2.419
#define RATIO_WITH_PADDING ((WALLPAPER_WIDTH + WALLPAPER_PADDING) / (THUMBNAIL_SIZE + WALLPAPER_PADDING))

#define FRONT_BUFFER 107

#define THUMBNAIL_SIZE (WALLPAPER_WIDTH/RATIO)

#define WALLPAPER_THUMBNAIL_RATIO (WALLPAPER_WIDTH/THUMBNAIL_SIZE)

@interface WWallpaperController () <UIScrollViewDelegate>

@end

@implementation WWallpaperController
static UIImage *template;
static NSMutableArray *wallpaperItems;
static NSMutableArray *visibleWallpapers;
static NSMutableArray *wallpaperTapGestureRecognizers;




+ (UIImage *)template
{
    @synchronized(self){
        if(template == nil){
            template = [UIImage alloc];
        }
        return template;
    }
}

+ (void) setTemplate:(UIImage *)image
{
    @synchronized(self){
        template = image;
        [WallpaperProcessor setTemplate:template];
        [WallpaperDatabase saveTemplate: template];
        /*for(WallpaperItem *wallpaperItem in wallpaperItems){
            [wallpaperItem setWallpaper: [WallpaperProcessor process: [wallpaperItem getBackground]]];
        }*/
    }
}

+ (NSMutableArray *) wallpaperItems
{
    @synchronized(self){
        if(wallpaperItems== nil){
            wallpaperItems= [NSMutableArray alloc];
        }
        return wallpaperItems;
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        wallpaperItems = [WallpaperDatabase loadWallpapers];
       
        visibleWallpapers = [[NSMutableArray alloc]init];
        wallpaperTapGestureRecognizers = [[NSMutableArray alloc]initWithCapacity:BUFFER_SIZE];
        NSLog(@"creating view controller");
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    /*if(scrollView == wallpaperScrollView){
        [self updateWallpaperContentOffset];
    }else if(scrollView == thumbnailScrollView){
        [self updateThumbnailContentOffset];
    }*/
    
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
    /*NSInteger visibleWallpaperIndex = offsetX/(WALLPAPER_WIDTH/WALLPAPER_PADDING);
    visibleWallpaperIndex = MIN([wallpaperItems count], visibleWallpaperIndex);
    NSLog(@"visible wallpaper index: %ld", (long)visibleWallpaperIndex);
    NSRange range = [self getPositiveRangeFromValue:visibleWallpaperIndex withSize:BUFFER_SIZE notGreaterThan:[wallpaperItems count]-1];
    
    for(int i= range.location; i<range.location + range.length; i++){
        [[wallpaperItems objectAtIndex:i] loadData];
    }
    wallpaperScrollView.contentOffset = CGPointMake(offsetX*RATIO_WITH_PADDING, 0.0f);*/
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    template = [WallpaperDatabase loadTemplate];
    
    if (template == nil){
        UIImage *homescreen = [UIImage imageNamed: @"testLarge.png"];
        template = [WallpaperProcessor processHomescreen:homescreen];
        [WallpaperProcessor setTemplate:template];
        [WallpaperDatabase saveTemplate: template];
        NSLog(@"homescreen was nil :)");
    }
    [WallpaperProcessor setTemplate:template];

    // Now create a UIScrollView to hold the UIImageViews
   
    thumbnailScrollView = [[InfiniteThumbnailScrollView alloc]initWithWallpaperItems:wallpaperItems];
     wallpaperScrollView = [[InfiniteScrollView alloc]initWithWallpaperItems:wallpaperItems ];
    
    [wallpaperScrollView setDelegate:self];
    
    [wallpaperScrollView setPairedScrollView: thumbnailScrollView];
    [thumbnailScrollView setPairedScrollView:wallpaperScrollView];
    
    [wallpaperScrollView setAvailableWallpaperItems:[thumbnailScrollView availableWallpaperItems]];

	/*for (int i = 0; i < [wallpaperItems count]; i++) {
  

        /*UITapGestureRecognizer *wallpaperTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchWallpaper:)];
        wallpaperTap.numberOfTouchesRequired = 1;
        wallpaperTap.numberOfTapsRequired = 1;
        [visibleWallpaperView addGestureRecognizer:wallpaperTap];
        [wallpaperTapGestureRecognizers addObject:wallpaperTap];
        
        WallpaperItem *wallpaperItem = [wallpaperItems objectAtIndex:i];
        
        CGFloat thumbnailXOrigin = ((DISPLAY_WIDTH - THUMBNAIL_SIZE)/2) + (i * (THUMBNAIL_SIZE + WALLPAPER_PADDING));
        
        [wallpaperItem setThumbnailViewFrame: CGRectMake(thumbnailXOrigin,0,THUMBNAIL_SIZE, THUMBNAIL_SIZE)];
        [thumbnailScrollView addSubview:[wallpaperItem getThumbnailView]];
        
        UILongPressGestureRecognizer *thumbnailLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressThumbnail:)];
        thumbnailLongPress.numberOfTouchesRequired = 1;
        thumbnailLongPress.minimumPressDuration = 1;
        objc_setAssociatedObject(thumbnailLongPress, "wallpaperItem", [wallpaperItems objectAtIndex:i], OBJC_ASSOCIATION_ASSIGN);
        [[wallpaperItem getThumbnailView] addGestureRecognizer:thumbnailLongPress];

	}*/
 
    addWallpaperButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [addWallpaperButton addTarget:self action:@selector(didTouchAddWallpaper:) forControlEvents:UIControlEventTouchDown];
    [addWallpaperButton setTitle:@"+" forState:UIControlStateNormal];
    addWallpaperButton.frame = CGRectMake(DISPLAY_WIDTH - 50, DISPLAY_HEIGHT - 50, 25, 25);
    
    changeHomescreenButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [changeHomescreenButton addTarget:self action:@selector(didTouchChangeTemplate:) forControlEvents:UIControlEventTouchDown];
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

- (IBAction) didTouchChangeTemplate: (id) sender {
    ChangeHomescreenController *changeHomescreenController = [[ChangeHomescreenController alloc]initWithNibName:@"ChangeHomescreenController" bundle:nil];
    [self presentViewController:changeHomescreenController animated:YES completion:nil];
    [changeHomescreenController setCurrentHomescreen: template];
}

- (IBAction) didTouchWallpaper: (UITapGestureRecognizer*) sender{
    NSLog(@"did touch omg");
    WallpaperItem *wallpaperItem = objc_getAssociatedObject(sender, "wallpaperItem");
    UIImage *wallpaper = [wallpaperItem getWallpaper];
    WallpaperZoomController *zoomController = [[WallpaperZoomController alloc] initWithNibName:@"WallpaperZoomController" bundle:nil];
    
    [self presentViewController: zoomController animated:YES completion: nil];
    [zoomController setWallpaper: wallpaper];
}

-(IBAction)didTouchDeleteWallpaper:(id)sender{
    WallpaperItem *wallpaperItem = objc_getAssociatedObject(sender, "wallpaperItem");

    [thumbnailScrollView removeWallpaperItem: wallpaperItem];
    
}


- (void)didReceiveMemoryWarningƒ
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
	   
	for(NSDictionary *dict in info) {
        UIImage *image = [dict objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *wallpaper = [WallpaperProcessor process: image ];
        UIImage *thumbnail = [WallpaperProcessor makeThumbnail: image];
        WallpaperItem *wallpaperItem = [[WallpaperItem alloc] initWithWallpaper:wallpaper andBackground:image andThumbnail:thumbnail];
        [wallpaperItem setIndex:[wallpaperItems count]];
        [wallpaperItems addObject:wallpaperItem];
        [wallpaperItem saveData];

    }		
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

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
#define WALLPAPER_PADDING 4.0
#define STATUS_HEIGHT 23
#define RATIO 2.419
#define RATIO_WITH_PADDING ((WALLPAPER_WIDTH + WALLPAPER_PADDING) / (THUMBNAIL_SIZE + WALLPAPER_PADDING))

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
        visibleWallpapers = [[NSMutableArray alloc]initWithCapacity:BUFFER_SIZE];
        wallpaperTapGestureRecognizers = [[NSMutableArray alloc]initWithCapacity:BUFFER_SIZE];
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
    
    CGFloat minimumVisibleX = CGRectGetMinX([wallpaperScrollView bounds]);
    CGFloat maximumVisibleX = CGRectGetMaxX([wallpaperScrollView bounds]);
    
    [self tileWallpaperViewsFromMinX:minimumVisibleX toMaxX:maximumVisibleX];
}

- (UIImageView *)insertWallpaperView
{
    UIImageView *wallpaperImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WALLPAPER_WIDTH, WALLPAPER_HEIGHT)];
    [wallpaperImageView setImage:[[wallpaperItems objectAtIndex:0]getWallpaper]];
    [wallpaperScrollView addSubview:wallpaperImageView];
    
    return wallpaperImageView;
}

- (CGFloat)placeNewWallpaperImageViewOnRight:(CGFloat)rightEdge
{
    UIImageView *wallpaperImageView = [self insertWallpaperView];
    [visibleWallpapers addObject:wallpaperImageView]; // add rightmost label at the end of the array
    
    CGRect frame = [wallpaperImageView frame];
    frame.origin.x = rightEdge;
    frame.origin.y = [wallpaperScrollView bounds].size.height - frame.size.height;
    [wallpaperImageView setFrame:frame];
    
    return CGRectGetMaxX(frame);
}

- (CGFloat)placeNewWallpaperImageViewOnLeft:(CGFloat)leftEdge
{
    UIImageView *wallpaperImageView = [self insertWallpaperView];
    [visibleWallpapers insertObject:wallpaperImageView atIndex:0]; // add leftmost label at the beginning of the array
    
    CGRect frame = [wallpaperImageView frame];
    frame.origin.x = leftEdge - frame.size.width;
    frame.origin.y = [wallpaperScrollView bounds].size.height - frame.size.height;
    [wallpaperImageView setFrame:frame];
    
    return CGRectGetMinX(frame);
}

- (void)tileWallpaperViewsFromMinX:(CGFloat)minimumVisibleX toMaxX:(CGFloat)maximumVisibleX
{
    // the upcoming tiling logic depends on there already being at least one label in the visibleLabels array, so
    // to kick off the tiling we need to make sure there's at least one label
    if ([visibleWallpapers count] == 0)
    {
        [self placeNewWallpaperImageViewOnRight:minimumVisibleX];
    }
    
    // add labels that are missing on right side
    UIImageView *lastWallpaperImageView = [visibleWallpapers lastObject];
    CGFloat rightEdge = CGRectGetMaxX([lastWallpaperImageView frame]);
    while (rightEdge < maximumVisibleX)
    {
        rightEdge = [self placeNewWallpaperImageViewOnRight:rightEdge];
    }
    
    // add labels that are missing on left side
    UIImageView *firstWallpaperImageView = visibleWallpapers[0];
    CGFloat leftEdge = CGRectGetMinX([firstWallpaperImageView frame]);
    while (leftEdge > minimumVisibleX)
    {
        leftEdge = [self placeNewWallpaperImageViewOnLeft:leftEdge];
    }
    
    // remove labels that have fallen off right edge
    lastWallpaperImageView = [visibleWallpapers lastObject];
    while ([lastWallpaperImageView frame].origin.x > maximumVisibleX)
    {
        [lastWallpaperImageView removeFromSuperview];
        [visibleWallpapers removeLastObject];
        lastWallpaperImageView = [visibleWallpapers lastObject];
    }
    
    // remove labels that have fallen off left edge
    firstWallpaperImageView = visibleWallpapers[0];
    while (CGRectGetMaxX([firstWallpaperImageView frame]) < minimumVisibleX)
    {
        [firstWallpaperImageView removeFromSuperview];
        [visibleWallpapers removeObjectAtIndex:0];
        firstWallpaperImageView = visibleWallpapers[0];
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

- (NSRange)getPositiveRangeFromValue: (int)value withSize: (int)size notGreaterThan: (int) ceil
{
    int min=value;
    int max=value;
    while(size > 0){
        if(min > 0){
            min--;
            size--;
        }
        if(max < ceil-1 && size > 0){
            max++;
            size--;
        }
    }
    NSRange range;
    range.location = min;
    range.length = max-min;
    return range;
}

- (void)updateThumbnailContentOffset {
    CGPoint currentOffset = [wallpaperScrollView contentOffset];
    CGFloat contentWidth = [wallpaperScrollView contentSize].width;
    CGFloat centerOffsetX = (contentWidth - [wallpaperScrollView bounds].size.width) / 2.0;
    CGFloat distanceFromCenter = fabs(currentOffset.x - centerOffsetX);
    
    if (distanceFromCenter > (contentWidth / 4.0))
    {
        wallpaperScrollView.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
        
        // move content by the same amount so it appears to stay still
        for (UIImageView *imageView in visibleWallpapers) {
            [imageView setFrame:CGRectMake(imageView.frame.origin.x + (centerOffsetX - currentOffset.x), imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height)];
        }
    }

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

	for (int i = 0; i < BUFFER_SIZE; i++) {
  
        //WallpaperItem *wallpaperItem = [wallpaperItems objectAtIndex:i];
        
		CGFloat wallpaperXOrigin = ((DISPLAY_WIDTH - WALLPAPER_WIDTH)/2) + (i * (WALLPAPER_WIDTH + WALLPAPER_PADDING));
        
        UIImageView *visibleWallpaperView = [[UIImageView alloc]initWithFrame: CGRectMake(wallpaperXOrigin,0,WALLPAPER_WIDTH, WALLPAPER_HEIGHT)];
        [wallpaperScrollView addSubview:visibleWallpaperView];
        [visibleWallpapers addObject:visibleWallpaperView];
      
        UITapGestureRecognizer *wallpaperTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchWallpaper:)];
        wallpaperTap.numberOfTouchesRequired = 1;
        wallpaperTap.numberOfTapsRequired = 1;
        [visibleWallpaperView addGestureRecognizer:wallpaperTap];
        [wallpaperTapGestureRecognizers addObject:wallpaperTap];
        
        CGFloat thumbnailXOrigin = ((DISPLAY_WIDTH - THUMBNAIL_SIZE)/2) + (i * (THUMBNAIL_SIZE + WALLPAPER_PADDING));

        UIImageView *visibleThumbnailView = [[UIImageView alloc]initWithFrame:CGRectMake(thumbnailXOrigin,0,THUMBNAIL_SIZE, THUMBNAIL_SIZE)];
        [thumbnailScrollView addSubview:visibleThumbnailView];
        
        UILongPressGestureRecognizer *thumbnailLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressThumbnail:)];
        thumbnailLongPress.numberOfTouchesRequired = 1;
        thumbnailLongPress.minimumPressDuration = 1;
        objc_setAssociatedObject(thumbnailLongPress, "wallpaperItem", [wallpaperItems objectAtIndex:i], OBJC_ASSOCIATION_ASSIGN);
        [visibleThumbnailView addGestureRecognizer:thumbnailLongPress];

	}
    
    
    NSRange range = [self getPositiveRangeFromValue:0 withSize:BUFFER_SIZE notGreaterThan:[wallpaperItems count]];
    
    for(int i=0; i< BUFFER_SIZE; i++){
        UIImageView *visibleWallpaperView = [visibleWallpapers objectAtIndex:i];
        [visibleWallpaperView setImage:[[wallpaperItems objectAtIndex:i + range.location]getWallpaper]];
        UITapGestureRecognizer *wallpaperTap = [wallpaperTapGestureRecognizers objectAtIndex:i];
          objc_setAssociatedObject(wallpaperTap, "wallpaperItem", [wallpaperItems objectAtIndex:i], OBJC_ASSOCIATION_ASSIGN);
    }
    

	wallpaperScrollView.contentSize = CGSizeMake(107 + [visibleWallpapers count] * (WALLPAPER_WIDTH + WALLPAPER_PADDING), WALLPAPER_HEIGHT);
    
     thumbnailScrollView.contentSize = CGSizeMake(107 + [visibleWallpapers count] * (WALLPAPER_WIDTH + WALLPAPER_PADDING), THUMBNAIL_SIZE);
    
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
    WallpaperItem *wallpaperItem = objc_getAssociatedObject(sender, "wallpaperItem");
    UIImage *wallpaper = [wallpaperItem getWallpaper];
    WallpaperZoomController *zoomController = [[WallpaperZoomController alloc] initWithNibName:@"WallpaperZoomController" bundle:nil];
    
    [self presentViewController: zoomController animated:YES completion: nil];
    [zoomController setWallpaper: wallpaper];
}

-(IBAction)didLongPressThumbnail:(UILongPressGestureRecognizer*) sender{
    for(WallpaperItem *wallpaperItem in wallpaperItems){
        UIButton *deleteWallpaperButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [deleteWallpaperButton addTarget:self action:@selector(didTouchDeleteWallpaper:) forControlEvents:UIControlEventTouchDown];
        [deleteWallpaperButton setTitle:@"+" forState:UIControlStateNormal];
        deleteWallpaperButton.frame = CGRectMake( 50,50 , 25, 25);
         objc_setAssociatedObject(deleteWallpaperButton, "wallpaperItem", wallpaperItem, OBJC_ASSOCIATION_ASSIGN);
        [[wallpaperItem getThumbnailView]addSubview:deleteWallpaperButton];
    }
}

-(IBAction)didTouchDeleteWallpaper:(id)sender{
    WallpaperItem *wallpaperItem = objc_getAssociatedObject(sender, "wallpaperItem");
    [[wallpaperItem getThumbnailView] removeFromSuperview];
    [[wallpaperItem getWallpaperView] removeFromSuperview];
    [wallpaperItem deleteData];
    int index = [wallpaperItems indexOfObject:wallpaperItem];
    [wallpaperItems removeObject: wallpaperItem];
    NSLog(@"removed it");


    for(int i=index; i< [wallpaperItems count]; i++){
        WallpaperItem *wallpaperItem= [wallpaperItems objectAtIndex:i];
        CGFloat wallpaperXOrigin = ((DISPLAY_WIDTH - WALLPAPER_WIDTH)/2) + (i * (WALLPAPER_WIDTH + WALLPAPER_PADDING));
        [wallpaperItem setWallpaperViewFrame: CGRectMake(wallpaperXOrigin,0,WALLPAPER_WIDTH, WALLPAPER_HEIGHT)];
        
        CGFloat thumbnailXOrigin = ((DISPLAY_WIDTH - THUMBNAIL_SIZE)/2) + (i * (THUMBNAIL_SIZE + WALLPAPER_PADDING));
        
        [wallpaperItem setThumbnailViewFrame:CGRectMake(thumbnailXOrigin,0,THUMBNAIL_SIZE, THUMBNAIL_SIZE)];
  
    }
    
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
        CGFloat wallpaperXOrigin = ((DISPLAY_WIDTH - WALLPAPER_WIDTH)/2) + [wallpaperItems count] * (WALLPAPER_WIDTH + WALLPAPER_PADDING);
        
        UIImage *wallpaper = [WallpaperProcessor process: image ];
        UIImage *thumbnail = [WallpaperProcessor makeThumbnail: image];
        WallpaperItem *wallpaperItem = [[WallpaperItem alloc] initWithWallpaper:wallpaper andBackground:image andThumbnail:thumbnail];
        
        [[wallpaperItem getWallpaperView ] setFrame:CGRectMake(wallpaperXOrigin,0,WALLPAPER_WIDTH,WALLPAPER_HEIGHT)];
        [wallpaperScrollView addSubview: [wallpaperItem getWallpaperView]];
        UITapGestureRecognizer *wallpaperTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchWallpaper:)];
        wallpaperTap.numberOfTouchesRequired = 1;
        wallpaperTap.numberOfTapsRequired = 1;
        objc_setAssociatedObject(wallpaperTap, "wallpaperItem", wallpaperItem, OBJC_ASSOCIATION_ASSIGN);
        [[wallpaperItem getWallpaperView] addGestureRecognizer:wallpaperTap];
 
        CGFloat thumbnailXOrigin = ((DISPLAY_WIDTH - THUMBNAIL_SIZE)/2) + [wallpaperItems count] * (THUMBNAIL_SIZE + WALLPAPER_PADDING);
		[wallpaperItem setThumbnailViewFrame: CGRectMake(thumbnailXOrigin,0,THUMBNAIL_SIZE, THUMBNAIL_SIZE)];
        [thumbnailScrollView addSubview:[wallpaperItem getThumbnailView]];
        UILongPressGestureRecognizer *thumbnailLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressThumbnail:)];
        thumbnailLongPress.numberOfTouchesRequired = 1;
        thumbnailLongPress.minimumPressDuration = 1;
        objc_setAssociatedObject(thumbnailLongPress, "wallpaperItem", wallpaperItem, OBJC_ASSOCIATION_ASSIGN);
        [[wallpaperItem getThumbnailView] addGestureRecognizer:thumbnailLongPress];
        [wallpaperItems addObject:wallpaperItem];
        [wallpaperItem saveData];

    }
    
    wallpaperScrollView.contentSize = CGSizeMake([wallpaperItems count] * (WALLPAPER_WIDTH + WALLPAPER_PADDING), WALLPAPER_HEIGHT);
    
    thumbnailScrollView.contentSize = CGSizeMake([wallpaperItems count] * (THUMBNAIL_SIZE + WALLPAPER_PADDING), THUMBNAIL_SIZE);
		
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

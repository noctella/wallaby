
#define DISPLAY_WIDTH 320
#define DISPLAY_HEIGHT 568
#define WALLPAPER_SCALE 0.77
#define WALLPAPER_WIDTH 250.0
#define WALLPAPER_HEIGHT (DISPLAY_HEIGHT*WALLPAPER_SCALE)
#define WALLPAPER_PADDING 2.0
#define STATUS_HEIGHT 23
#define RATIO 2.419
#define TEST_RATIO 10
#define RATIO_WITH_PADDING ((WALLPAPER_WIDTH + WALLPAPER_PADDING) / (THUMBNAIL_SIZE + WALLPAPER_PADDING))

#define THUMBNAIL_SIZE (WALLPAPER_WIDTH/RATIO)

#define BUFFER_SIZE 10


#import "InfiniteThumbnailScrollView.h"
#import "InfiniteScrollView.h"
#import "WallpaperItem.h"
#import "objc/runtime.h"

@interface InfiniteThumbnailScrollView ()

@end



@implementation InfiniteThumbnailScrollView
@synthesize availableWallpaperItems;

- (id)initWithWallpaperItems:(NSMutableArray*)items;
{
    if ((self = [super init]))
    {
        self.contentSize = CGSizeMake(BUFFER_SIZE * (THUMBNAIL_SIZE + WALLPAPER_PADDING), THUMBNAIL_SIZE);
        self.frame = CGRectMake(0,STATUS_HEIGHT + WALLPAPER_PADDING + WALLPAPER_HEIGHT,325,THUMBNAIL_SIZE);
        wallpaperItems = items;
        thumbnailRightIndex = [wallpaperItems count]/2;
        thumbnailLeftIndex = thumbnailRightIndex - 1;
        scrolledRemotely = true;
        visibleThumbnails = [[NSMutableArray alloc] init];
        isEditing = false;
        availableWallpaperItems = [[NSMutableArray alloc]init];
        
        
        // hide horizontal scroll indicator so our recentering trick is not revealed
        [self setShowsHorizontalScrollIndicator:NO];
        [self setPagingEnabled: NO];
        [self setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    }
    return self;
}


-(void)setPairedScrollView: (InfiniteScrollView *)scrollView{
    pairedScrollView = scrollView;
}

#pragma mark - Layout

- (void) recenterIfNecessary{
        CGPoint currentOffset = [self contentOffset];
        CGFloat contentWidth = [self contentSize].width;
        CGFloat centerOffsetX = (contentWidth - [self bounds].size.width) / 2.0;
        CGFloat distanceFromCenter = fabs(currentOffset.x - centerOffsetX);
    NSLog(@"distance from centre:%f", distanceFromCenter);
    NSLog(@"content width:%f", contentWidth);

    

        if (distanceFromCenter > (contentWidth / 4.0)){
            NSLog(@"distance is greater");
            NSLog(@"number of items in visible:%d", [visibleThumbnails count]);


            self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
            
            // move content by the same amount so it appears to stay still
            for (WallpaperItem *wallpaperItem in visibleThumbnails) {
                UIImageView *imageView = [wallpaperItem thumbnailView];
                NSLog(@"current offset: %f", imageView.frame.origin.x);

                [imageView setFrame:CGRectMake(imageView.frame.origin.x + (centerOffsetX - currentOffset.x), imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height)];
            }
            
            CGPoint bigCurrentOffset = pairedScrollView.contentOffset;
            pairedScrollView.contentOffset = CGPointMake(self.contentOffset.x * RATIO_WITH_PADDING, bigCurrentOffset.y);
            
            NSMutableArray *visibleWallpapers = [pairedScrollView getVisibleWallpapers];
            // move content by the same amount so it appears to stay still
            for (WallpaperItem *wallpaperItem in visibleWallpapers) {
                NSLog(@"reseting shit");

                UIImageView *imageView = [wallpaperItem wallpaperView];
                [imageView setFrame:CGRectMake(imageView.frame.origin.x + (pairedScrollView.contentOffset.x - bigCurrentOffset.x), imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height)];
            }
        }
}


- (void)setScrolledRemotely{
    scrolledRemotely = true;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self recenterIfNecessary];
    //was 153
    [self tileThumbnailViewsFromMinX:0 toMaxX:self.contentSize.width];
    if(!scrolledRemotely){
        [pairedScrollView setContentOffset:CGPointMake(self.contentOffset.x*RATIO_WITH_PADDING, 0.0f)];
        [pairedScrollView setScrolledRemotely];
    }
    scrolledRemotely = false;
   
}

-(IBAction)didLongPressThumbnail:(UILongPressGestureRecognizer*) sender{
    for(WallpaperItem *wallpaperItem in visibleThumbnails){
        NSLog(@"The value of the bool is %@\n", (wallpaperItem.isEditing ? @"YES" : @"NO"));
        if(![wallpaperItem isEditing]){
            UIButton *deleteWallpaperButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
            [deleteWallpaperButton addTarget:self.delegate action:@selector(didTouchDeleteWallpaper:) forControlEvents:UIControlEventTouchDown];
            [deleteWallpaperButton setTitle:@"+" forState:UIControlStateNormal];
            deleteWallpaperButton.frame = CGRectMake( 50,50 , 25, 25);
            objc_setAssociatedObject(deleteWallpaperButton, "wallpaperItem", wallpaperItem, OBJC_ASSOCIATION_ASSIGN);
            [[wallpaperItem thumbnailView]addSubview:deleteWallpaperButton];
            [wallpaperItem setIsEditing:true];
        }
    }
    isEditing = true;
}

-(void)addPressRecognizerToView:(UIImageView *)imageView withAssociatedObject: (WallpaperItem *) wallpaperItem{
    [imageView setUserInteractionEnabled:YES];
    UILongPressGestureRecognizer *thumbnailLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressThumbnail:)];
    thumbnailLongPress.numberOfTouchesRequired = 1;
    thumbnailLongPress.minimumPressDuration = 1;
    objc_setAssociatedObject(thumbnailLongPress, "wallpaperItem", wallpaperItem, OBJC_ASSOCIATION_ASSIGN);
    [imageView addGestureRecognizer:thumbnailLongPress];
}


- (CGFloat)placeNewThumbnailImageViewOnRight:(CGFloat)rightEdge
{
    WallpaperItem *wallpaperItem = [[wallpaperItems objectAtIndex:thumbnailRightIndex]copy];
    [wallpaperItem setThumbnailViewFrame: CGRectMake(rightEdge, 0, THUMBNAIL_SIZE, THUMBNAIL_SIZE)];
    [self addPressRecognizerToView:[wallpaperItem thumbnailView] withAssociatedObject:wallpaperItem];
  
    if(isEditing && ![wallpaperItem isEditing]){
        UIButton *deleteWallpaperButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [deleteWallpaperButton addTarget:self.delegate action:@selector(didTouchDeleteWallpaper:) forControlEvents:UIControlEventTouchDown];
        [deleteWallpaperButton setTitle:@"+" forState:UIControlStateNormal];
        deleteWallpaperButton.frame = CGRectMake( 50,50 , 25, 25);
        objc_setAssociatedObject(deleteWallpaperButton, "wallpaperItem", wallpaperItem, OBJC_ASSOCIATION_ASSIGN);
        [[wallpaperItem thumbnailView]addSubview:deleteWallpaperButton];
        [wallpaperItem setIsEditing:true];
    }
    
    
    NSLog(@"right inserted: %@", wallpaperItem);
    


    [self addSubview:[wallpaperItem thumbnailView]];
    [visibleThumbnails addObject:wallpaperItem];
    [availableWallpaperItems addObject:wallpaperItem];
    thumbnailRightIndex++;
    if(thumbnailRightIndex == [wallpaperItems count])thumbnailRightIndex = 0;
    
    return CGRectGetMaxX([wallpaperItem thumbnailView].frame);
}

- (CGFloat)placeNewThumbnailImageViewOnLeft:(CGFloat)leftEdge
{
     WallpaperItem *wallpaperItem = [[wallpaperItems objectAtIndex:thumbnailLeftIndex]copy];
    [wallpaperItem setThumbnailViewFrame: CGRectMake(leftEdge - THUMBNAIL_SIZE, 0, THUMBNAIL_SIZE, THUMBNAIL_SIZE)];
    [self addPressRecognizerToView:[wallpaperItem thumbnailView] withAssociatedObject: wallpaperItem];
 
    if(isEditing && ![wallpaperItem isEditing]){
        UIButton *deleteWallpaperButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [deleteWallpaperButton addTarget:self.delegate action:@selector(didTouchDeleteWallpaper:) forControlEvents:UIControlEventTouchDown];
        [deleteWallpaperButton setTitle:@"+" forState:UIControlStateNormal];
        deleteWallpaperButton.frame = CGRectMake( 50,50 , 25, 25);
        objc_setAssociatedObject(deleteWallpaperButton, "wallpaperItem", wallpaperItem, OBJC_ASSOCIATION_ASSIGN);
        [[wallpaperItem thumbnailView]addSubview:deleteWallpaperButton];
        [wallpaperItem setIsEditing:true];
    }
    
    NSLog(@"left inserted: %@", wallpaperItem);

    
    [visibleThumbnails insertObject:wallpaperItem atIndex:0]; // add leftmost label at the beginning of the array
    [availableWallpaperItems insertObject:wallpaperItem atIndex:0];

    [self addSubview:[wallpaperItem thumbnailView]];
    thumbnailLeftIndex--;
    if(thumbnailLeftIndex == -1)thumbnailLeftIndex = [wallpaperItems count]-1;
    
    return CGRectGetMinX([wallpaperItem thumbnailView].frame);
}

-(void)removeWallpaperItem: (WallpaperItem *)wallpaperItem{
    //[visibleThumbnails removeObject: wallpaperItem];
    
}

- (void)tileThumbnailViewsFromMinX:(CGFloat)minimumVisibleX toMaxX:(CGFloat)maximumVisibleX
{
    // the upcoming tiling logic depends on there already being at least one label in the visibleLabels array, so
    // to kick off the tiling we need to make sure there's at least one label
    if ([visibleThumbnails count] == 0)
    {
        [self placeNewThumbnailImageViewOnRight:minimumVisibleX + WALLPAPER_PADDING];
    }
    
    // add labels that are missing on right side
    UIImageView *lastthumbnailImageView = [[visibleThumbnails lastObject] thumbnailView];
    CGFloat rightEdge = CGRectGetMaxX([lastthumbnailImageView frame]);  //here's where we'll change the positioning
    NSLog(@"right edg:%f", rightEdge);

    while (rightEdge + WALLPAPER_PADDING < maximumVisibleX)
    {
        NSLog(@"right edg:%f", rightEdge);
        rightEdge = [self placeNewThumbnailImageViewOnRight:rightEdge + WALLPAPER_PADDING];
    }
    
    NSLog(@"number 1: %d", [visibleThumbnails count]);

    
    // add labels that are missing on left side
    UIImageView *firstthumbnailImageView = [visibleThumbnails[0] thumbnailView];
    CGFloat leftEdge = CGRectGetMinX([firstthumbnailImageView frame]);
    while (leftEdge - WALLPAPER_PADDING > minimumVisibleX)
    {
        leftEdge = [self placeNewThumbnailImageViewOnLeft:leftEdge - WALLPAPER_PADDING];
    }
    NSLog(@"number 2: %d", [visibleThumbnails count]);
    
    // remove labels that have fallen off right edge
    lastthumbnailImageView = [[visibleThumbnails lastObject] thumbnailView];
    while ([lastthumbnailImageView frame].origin.x > maximumVisibleX)
    {
        [lastthumbnailImageView removeFromSuperview];
        [visibleThumbnails removeLastObject];
        lastthumbnailImageView = [[visibleThumbnails lastObject]thumbnailView];
    }
    NSLog(@"number 3: %d", [visibleThumbnails count]);
    // remove labels that have fallen off left edge
    WallpaperItem *lastWallpaperItem =visibleThumbnails[0];
    firstthumbnailImageView = [lastWallpaperItem thumbnailView];
    while (CGRectGetMaxX([firstthumbnailImageView frame]) < minimumVisibleX)
    {
        NSLog(@"removed one...");

        [firstthumbnailImageView removeFromSuperview];
        [visibleThumbnails removeObjectAtIndex:0];
        firstthumbnailImageView = [visibleThumbnails[0] thumbnailView];
    }
    NSLog(@"number 4: %d", [visibleThumbnails count]);
}
@end
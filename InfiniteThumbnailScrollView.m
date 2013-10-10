
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

#define BUFFER_SIZE 5


#import "InfiniteThumbnailScrollView.h"
#import "WallpaperItem.h"

@interface InfiniteThumbnailScrollView ()

@end


@implementation InfiniteThumbnailScrollView

- (id)initWithWallpaperItems:(NSMutableArray*)items;
{
    if ((self = [super init]))
    {
        self.contentSize = CGSizeMake(BUFFER_SIZE * (WALLPAPER_WIDTH + WALLPAPER_PADDING), THUMBNAIL_SIZE);
        self.frame = CGRectMake(0,STATUS_HEIGHT + WALLPAPER_PADDING + WALLPAPER_HEIGHT,325,THUMBNAIL_SIZE);
        wallpaperItems = items;
        thumbnailRightIndex = 0;
        thumbnailLeftIndex = [wallpaperItems count]-1;
        oldTrueContentOffsetX=0;
        
        visibleThumbnails = [[NSMutableArray alloc] init];
        
        // hide horizontal scroll indicator so our recentering trick is not revealed
        [self setShowsHorizontalScrollIndicator:NO];
        [self setPagingEnabled: NO];
        [self setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    }
    return self;
}

-(void)setPairedScrollView: (UIScrollView *)scrollView{
    pairedScrollView = scrollView;
}

#pragma mark - Layout

- (void) recenterIfNecessary{
    CGPoint currentOffset = [self contentOffset];
    CGFloat contentWidth = [self contentSize].width;
    CGFloat centerOffsetX = (contentWidth - [self bounds].size.width) / 2.0;
    CGFloat distanceFromCenter = fabs(currentOffset.x - centerOffsetX);
    
    if (distanceFromCenter > (contentWidth / 4.0))
    {
        self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
        oldTrueContentOffsetX = self.contentOffset.x;
        
        // move content by the same amount so it appears to stay still
        for (UIImageView *imageView in visibleThumbnails) {
            [imageView setFrame:CGRectMake(imageView.frame.origin.x + (centerOffsetX - currentOffset.x), imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height)];
        }
    }
    
}
- (void)layoutSubviews
{
    trueContentOffsetX   = self.contentOffset.x;
    pairedScrollView.contentOffset = CGPointMake(pairedScrollView.contentOffset.x + (trueContentOffsetX - oldTrueContentOffsetX)/RATIO_WITH_PADDING, 0.0f);
    oldTrueContentOffsetX = trueContentOffsetX ;
    
    [super layoutSubviews];
    [self recenterIfNecessary];
    [self tileThumbnailViewsFromMinX:0 toMaxX:self.contentSize.width];
    NSLog(@"going to scroll: %f", (trueContentOffsetX - oldTrueContentOffsetX)/RATIO_WITH_PADDING);

    
    
    
}


- (CGFloat)placeNewThumbnailImageViewOnRight:(CGFloat)rightEdge
{
    UIImageView *thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, THUMBNAIL_SIZE, THUMBNAIL_SIZE)];
    [thumbnailImageView setImage:[[wallpaperItems objectAtIndex:thumbnailRightIndex]getThumbnail]];

    [visibleThumbnails addObject:thumbnailImageView]; // add rightmost label at the end of the array
    
    CGRect frame = [thumbnailImageView frame];
    frame.origin.x = rightEdge;
    frame.origin.y = [self bounds].size.height - frame.size.height;
    [thumbnailImageView setFrame:frame];
    [self addSubview:thumbnailImageView];
    thumbnailRightIndex++;
    if(thumbnailRightIndex == [wallpaperItems count])thumbnailRightIndex = 0;
    
    return CGRectGetMaxX(frame);
}

- (CGFloat)placeNewThumbnailImageViewOnLeft:(CGFloat)leftEdge
{
    UIImageView *thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, THUMBNAIL_SIZE, THUMBNAIL_SIZE)];
    [thumbnailImageView setImage:[[wallpaperItems objectAtIndex:thumbnailLeftIndex]getThumbnail]];

    [visibleThumbnails insertObject:thumbnailImageView atIndex:0]; // add leftmost label at the beginning of the array
    
    CGRect frame = [thumbnailImageView frame];
    frame.origin.x = leftEdge - frame.size.width;
    frame.origin.y = [self bounds].size.height - frame.size.height;
    [thumbnailImageView setFrame:frame];
    [self addSubview:thumbnailImageView];
    thumbnailLeftIndex--;
    if(thumbnailLeftIndex == -1)thumbnailLeftIndex = [wallpaperItems count]-1;
    
    return CGRectGetMinX(frame);
}

- (void)tileThumbnailViewsFromMinX:(CGFloat)minimumVisibleX toMaxX:(CGFloat)maximumVisibleX
{
    // the upcoming tiling logic depends on there already being at least one label in the visibleLabels array, so
    // to kick off the tiling we need to make sure there's at least one label
    if ([visibleThumbnails count] == 0)
    {
        [self placeNewThumbnailImageViewOnRight:minimumVisibleX];
    }
    
    // add labels that are missing on right side
    UIImageView *lastthumbnailImageView = [visibleThumbnails lastObject];
    CGFloat rightEdge = CGRectGetMaxX([lastthumbnailImageView frame]);  //here's where we'll change the positioning
    while (rightEdge < maximumVisibleX)
    {
        rightEdge = [self placeNewThumbnailImageViewOnRight:rightEdge];
    }
    
    // add labels that are missing on left side
    UIImageView *firstthumbnailImageView = visibleThumbnails[0];
    CGFloat leftEdge = CGRectGetMinX([firstthumbnailImageView frame]);
    while (leftEdge > minimumVisibleX)
    {
        leftEdge = [self placeNewThumbnailImageViewOnLeft:leftEdge];
    }
    
    // remove labels that have fallen off right edge
    lastthumbnailImageView = [visibleThumbnails lastObject];
    while ([lastthumbnailImageView frame].origin.x > maximumVisibleX)
    {
        [lastthumbnailImageView removeFromSuperview];
        [visibleThumbnails removeLastObject];
        lastthumbnailImageView = [visibleThumbnails lastObject];
    }
    
    // remove labels that have fallen off left edge
    firstthumbnailImageView = visibleThumbnails[0];
    while (CGRectGetMaxX([firstthumbnailImageView frame]) < minimumVisibleX)
    {
        [firstthumbnailImageView removeFromSuperview];
        [visibleThumbnails removeObjectAtIndex:0];
        firstthumbnailImageView = visibleThumbnails[0];
    }
}
@end
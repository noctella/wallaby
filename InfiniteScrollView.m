/*
     File: InfiniteScrollView.m
 Abstract: This view tiles UILabel instances to give the effect of infinite scrolling side to side.
  Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#define DISPLAY_WIDTH 320
#define DISPLAY_HEIGHT 568
#define WALLPAPER_SCALE 0.77
#define WALLPAPER_WIDTH 250.0
#define WALLPAPER_HEIGHT (DISPLAY_HEIGHT*WALLPAPER_SCALE)
#define WALLPAPER_PADDING 2.0
#define STATUS_HEIGHT 23
#define RATIO 2 //2.419
#define RATIO_WITH_PADDING 2
//((WALLPAPER_WIDTH + WALLPAPER_PADDING) / (THUMBNAIL_SIZE + WALLPAPER_PADDING))

#define THUMBNAIL_SIZE (WALLPAPER_WIDTH/RATIO)

#define BUFFER_SIZE 5


#import "InfiniteScrollView.h"
#import "InfiniteThumbnailScrollView.h"
#import "WallpaperItem.h"

@interface InfiniteScrollView ()

@end


@implementation InfiniteScrollView

- (id)initWithWallpaperItems:(NSMutableArray*)items;
{
    if ((self = [super init]))
    {
        self.contentSize = 	CGSizeMake(RATIO_WITH_PADDING* BUFFER_SIZE * (WALLPAPER_WIDTH + WALLPAPER_PADDING), WALLPAPER_HEIGHT);
        self.frame = CGRectMake(0,STATUS_HEIGHT,DISPLAY_WIDTH,WALLPAPER_HEIGHT);

        wallpaperItems = items;
        wallpaperRightIndex = 0;
        wallpaperLeftIndex = [wallpaperItems count]-1;
        oldTrueContentOffsetX=0;
        scrolledRemotely = true;
        
        visibleWallpapers = [[NSMutableArray alloc] init];
        
        // hide horizontal scroll indicator so our recentering trick is not revealed
        [self setShowsHorizontalScrollIndicator:NO];
        [self setPagingEnabled: NO];
        [self setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
        //[self tileWallpaperViewsFromMinX:0 toMaxX:self.contentSize.width];
    }
    return self;
}

-(void)setPairedScrollView: (InfiniteThumbnailScrollView *)scrollView{
    pairedScrollView = scrollView;
}

-(void)setContentOffset:(CGPoint)contentOffset{
    //NSLog(@"Big's current offset: %f", self.contentOffset.x);

    [super setContentOffset:contentOffset];
}

#pragma mark - Layout

- (void) recenterIfNecessary{
    CGPoint currentOffset = [self contentOffset];
    CGFloat contentWidth = [self contentSize].width;
    CGFloat centerOffsetX = (contentWidth - [self bounds].size.width) / 2.0;
    CGFloat distanceFromCenter = fabs(currentOffset.x - centerOffsetX);
    
    if(currentOffset.x > 1741.0)
    //if (distanceFromCenter > (contentWidth / (RATIO_WITH_PADDING * 2)))
    {
        NSLog(@"laying out Big again. current offset: %f", self.contentOffset.x);
    
        float prevContentOffsetX = self.contentOffset.x;
        
        self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
        float contentOffsetDelta = self.contentOffset.x - prevContentOffsetX;
        //contentOffsetBeforeSwitch -= contentOffsetDelta;
        
        NSLog(@"changed to : %f", self.contentOffset.x);
        //[pairedScrollView setContentOffsetBeforeSwitch];

        
        // move content by the same amount so it appears to stay still
        for (UIImageView *imageView in visibleWallpapers) {
            [imageView setFrame:CGRectMake(imageView.frame.origin.x + (centerOffsetX - currentOffset.x), imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height)];
        }
    }
    
}

-(NSMutableArray *)getVisibleWallpapers{
    return visibleWallpapers;
}

-(void) setscrolledRemotely{
    scrolledRemotely = true;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
   // [self recenterIfNecessary];
    if(!scrolledRemotely){
        trueContentOffsetX   = self.contentOffset.x;
        NSLog(@"other: %f", (trueContentOffsetX - oldTrueContentOffsetX));
        NSLog(@"other/ratio:%f", (trueContentOffsetX - oldTrueContentOffsetX)/RATIO_WITH_PADDING);
        NSLog(@"before moving: %f", pairedScrollView.contentOffset.x);
        
        pairedScrollView.contentOffset = CGPointMake(pairedScrollView.contentOffset.x + (trueContentOffsetX - oldTrueContentOffsetX)/RATIO_WITH_PADDING, 0.0f);
        NSLog(@"after moving: %f", pairedScrollView.contentOffset.x);
        [pairedScrollView setScrolledRemotely];
        oldTrueContentOffsetX = trueContentOffsetX ;
    }
    
    [self tileWallpaperViewsFromMinX:0 toMaxX:self.contentSize.width];
     scrolledRemotely = false;
}


#pragma mark - Label Tiling

- (UIImageView *)insertWallpaperView
{
    UIImageView *wallpaperImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WALLPAPER_WIDTH, WALLPAPER_HEIGHT)];
    [wallpaperImageView setImage:[[wallpaperItems objectAtIndex:0]getWallpaper]];
    [self addSubview:wallpaperImageView];
    
    return wallpaperImageView;
}

- (CGFloat)placeNewWallpaperImageViewOnRight:(CGFloat)rightEdge
{
    UIImageView *wallpaperImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WALLPAPER_WIDTH, WALLPAPER_HEIGHT)];
    [wallpaperImageView setImage:[[wallpaperItems objectAtIndex:wallpaperRightIndex]getWallpaper]];
    
    
    [visibleWallpapers addObject:wallpaperImageView]; // add rightmost label at the end of the array
    
    CGRect frame = [wallpaperImageView frame];
    frame.origin.x = rightEdge;
    frame.origin.y = [self bounds].size.height - frame.size.height;
    [wallpaperImageView setFrame:frame];
    [self addSubview:wallpaperImageView];
    wallpaperRightIndex++;
    if(wallpaperRightIndex == [wallpaperItems count])wallpaperRightIndex = 0;
    
    return CGRectGetMaxX(frame);
}

- (CGFloat)placeNewWallpaperImageViewOnLeft:(CGFloat)leftEdge
{
    UIImageView *wallpaperImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WALLPAPER_WIDTH, WALLPAPER_HEIGHT)];
    [wallpaperImageView setImage:[[wallpaperItems objectAtIndex:wallpaperLeftIndex]getWallpaper]];
    
    
    [visibleWallpapers insertObject:wallpaperImageView atIndex:0]; // add leftmost label at the beginning of the array
    
    CGRect frame = [wallpaperImageView frame];
    frame.origin.x = leftEdge - frame.size.width;
    frame.origin.y = [self bounds].size.height - frame.size.height;
    [wallpaperImageView setFrame:frame];
    [self addSubview:wallpaperImageView];
    wallpaperLeftIndex--;
    if(wallpaperLeftIndex == -1)wallpaperLeftIndex = [wallpaperItems count]-1;
    
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
    CGFloat rightEdge = CGRectGetMaxX([lastWallpaperImageView frame]);  //here's where we'll change the positioning
    while (rightEdge < maximumVisibleX)
    {
        rightEdge = [self placeNewWallpaperImageViewOnRight:rightEdge + WALLPAPER_PADDING];
    }
    
    // add labels that are missing on left side
    UIImageView *firstWallpaperImageView = visibleWallpapers[0];
    CGFloat leftEdge = CGRectGetMinX([firstWallpaperImageView frame]);
    while (leftEdge > minimumVisibleX)
    {
        leftEdge = [self placeNewWallpaperImageViewOnLeft:leftEdge - WALLPAPER_PADDING];
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
@end
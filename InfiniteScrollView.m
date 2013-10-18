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
#define RATIO 2.419
#define TEST_RATIO 10
#define RATIO_WITH_PADDING ((WALLPAPER_WIDTH + WALLPAPER_PADDING) / (THUMBNAIL_SIZE + WALLPAPER_PADDING))

#define THUMBNAIL_SIZE (WALLPAPER_WIDTH/RATIO)

#define BUFFER_SIZE 10
#define FRONT_BUFFER 107

#import "InfiniteScrollView.h"
#import "InfiniteThumbnailScrollView.h"
#import "WallpaperItem.h"
#import "objc/runtime.h"

@interface InfiniteScrollView ()

@end


@implementation InfiniteScrollView
@synthesize availableWallpaperItems;

- (id)initWithWallpaperItems:(NSMutableArray*)items;
{
    if ((self = [super init]))
    {
        self.contentSize = 	CGSizeMake(BUFFER_SIZE * (WALLPAPER_WIDTH + WALLPAPER_PADDING), WALLPAPER_HEIGHT);
        self.frame = CGRectMake(0,STATUS_HEIGHT,DISPLAY_WIDTH,WALLPAPER_HEIGHT);

        wallpaperItems = items;
        wallpaperRightIndex = [wallpaperItems count]/2;
        wallpaperLeftIndex = wallpaperRightIndex - 1;
        scrolledRemotely = true;
        
        visibleWallpapers = [[NSMutableArray alloc] init];
        
        // hide horizontal scroll indicator so our recentering trick is not revealed
        [self setShowsHorizontalScrollIndicator:NO];
        [self setPagingEnabled: NO];
        [self setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
        [self recenterIfNecessary];
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
    self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
    // move content by the same amount so it appears to stay still
    for (WallpaperItem *wallpaperItem in visibleWallpapers) {
        NSLog(@"uh what recentering");

        UIImageView *imageView = [wallpaperItem wallpaperView];
        [[wallpaperItem wallpaperView]  setFrame:CGRectMake(imageView.frame.origin.x + (centerOffsetX - currentOffset.x), imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height)];
    }
    
    
}

-(NSMutableArray *)getVisibleWallpapers{
    return visibleWallpapers;
}

-(void) setScrolledRemotely{
    scrolledRemotely = true;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
   // [self recenterIfNecessary];
    if(!scrolledRemotely){
        [pairedScrollView recenterIfNecessary];
        [pairedScrollView setContentOffset:CGPointMake(self.contentOffset.x/RATIO_WITH_PADDING, 0.0f)];
        [pairedScrollView setScrolledRemotely];
    }
    //was 145
    [self tileWallpaperViewsFromMinX:0 toMaxX:self.contentSize.width];
     scrolledRemotely = false;
}


-(void)addTapRecognizerToView:(UIImageView *)imageView withAssociatedObject: (WallpaperItem *) wallpaperItem{
    [imageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *wallpaperTap = [[UITapGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(didTouchWallpaper:)];
    wallpaperTap.numberOfTouchesRequired = 1;
    wallpaperTap.numberOfTapsRequired = 1;
    objc_setAssociatedObject(wallpaperTap, "wallpaperItem", wallpaperItem, OBJC_ASSOCIATION_ASSIGN);
    [imageView addGestureRecognizer:wallpaperTap];

}
-(WallpaperItem *)findAvailableWallpaperItem: (NSString *) side{
   // NSLog(@"side is: %@", side);
    
     /*for(WallpaperItem *availableWallpaper in availableWallpaperItems){
         NSLog(@"in items:%d", [availableWallpaper index]);
     }*/


    if([side isEqualToString: @"left"] == true){
        for(WallpaperItem *availableWallpaper in availableWallpaperItems){
            if([availableWallpaper index] == wallpaperLeftIndex && [availableWallpaper isLinked]==false){
                [availableWallpaper setIsLinked:true];
                //NSLog(@"got it from the avails left, index:%d",wallpaperLeftIndex);
                
                return availableWallpaper;
            }
        }
        //NSLog(@"not in avails..index:%d",wallpaperLeftIndex);
        
        return [[wallpaperItems objectAtIndex:wallpaperLeftIndex]copy];
    }
    for(int i=[availableWallpaperItems count] -1; i >=0 ; i--){
        WallpaperItem *availableWallpaper = [availableWallpaperItems objectAtIndex:i];
        if([availableWallpaper index] == wallpaperRightIndex && [availableWallpaper isLinked]==false){
            [availableWallpaper setIsLinked:true];
            //NSLog(@"got it from the avails right,index:%d",wallpaperRightIndex);
            
            return availableWallpaper;
        }
    }
    //NSLog(@"not in the avails...index:%d",wallpaperLeftIndex);

    
    return [[wallpaperItems objectAtIndex:wallpaperRightIndex]copy];
}

-(void)removeWallpaperItem: (WallpaperItem *)wallpaperItem{
    [[wallpaperItem thumbnailView] removeFromSuperview];
    [[wallpaperItem wallpaperView] removeFromSuperview];
    NSLog(@"removed it wall");
    
    
}



- (CGFloat)placeNewWallpaperImageViewOnRight:(CGFloat)rightEdge
{
   
    WallpaperItem *wallpaperItem = [self findAvailableWallpaperItem:@"right"];
    [wallpaperItem setWallpaperViewFrame:CGRectMake(rightEdge, 0, WALLPAPER_WIDTH, WALLPAPER_HEIGHT)];
    [self addTapRecognizerToView:[wallpaperItem wallpaperView] withAssociatedObject:wallpaperItem];
    [visibleWallpapers addObject:wallpaperItem];
    [self addSubview:[wallpaperItem wallpaperView]];
    wallpaperRightIndex++;
    if(wallpaperRightIndex == [wallpaperItems count])wallpaperRightIndex = 0;
    
    return CGRectGetMaxX([wallpaperItem wallpaperView].frame);
}



- (CGFloat)placeNewWallpaperImageViewOnLeft:(CGFloat)leftEdge
{
    //WallpaperItem *wallpaperItem = [[wallpaperItems objectAtIndex:wallpaperLeftIndex]copy];
    WallpaperItem *wallpaperItem = [self findAvailableWallpaperItem: @"left"];
    [wallpaperItem setWallpaperViewFrame:CGRectMake(leftEdge - WALLPAPER_WIDTH, 0, WALLPAPER_WIDTH, WALLPAPER_HEIGHT)];
    [self addTapRecognizerToView:[wallpaperItem wallpaperView] withAssociatedObject:wallpaperItem];
    [visibleWallpapers insertObject:wallpaperItem atIndex:0];
    [self addSubview:[wallpaperItem wallpaperView]];

    //NSLog(@"Added on left: %@", [[wallpaperItems objectAtIndex:wallpaperLeftIndex] getIndex]);
    NSLog(@"wallpaper items cound:%d", [wallpaperItems count]);

    wallpaperLeftIndex--;
    if(wallpaperLeftIndex == -1)wallpaperLeftIndex = [wallpaperItems count]-1;
    
    return CGRectGetMinX([wallpaperItem wallpaperView].frame);
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
    UIImageView *lastWallpaperImageView = [[visibleWallpapers lastObject]wallpaperView];
    CGFloat rightEdge = CGRectGetMaxX([lastWallpaperImageView frame]);
    while (rightEdge + WALLPAPER_PADDING < maximumVisibleX)
    {
        rightEdge = [self placeNewWallpaperImageViewOnRight:rightEdge + WALLPAPER_PADDING];
    }

    // add labels that are missing on left side
    UIImageView *firstWallpaperImageView = [visibleWallpapers[0] wallpaperView];
    CGFloat leftEdge = CGRectGetMinX([firstWallpaperImageView frame]);
    while (leftEdge - WALLPAPER_PADDING > minimumVisibleX)
    {
        leftEdge = [self placeNewWallpaperImageViewOnLeft:leftEdge - WALLPAPER_PADDING];
        
        NSLog(@"left edge:%f", leftEdge);

    }

    // remove labels that have fallen off right edge
    lastWallpaperImageView = [[visibleWallpapers lastObject]wallpaperView];
    while ([lastWallpaperImageView frame].origin.x > maximumVisibleX)
    {
        NSLog(@"removing shit");

        [lastWallpaperImageView removeFromSuperview];
        [visibleWallpapers removeLastObject];
        lastWallpaperImageView = [[visibleWallpapers lastObject] wallpaperView];
    }
    
    
    
    // remove labels that have fallen off left edge
    firstWallpaperImageView = [visibleWallpapers[0]wallpaperView];
    while (CGRectGetMaxX([firstWallpaperImageView frame]) < minimumVisibleX)
    {
        NSLog(@"removing shit");
        [firstWallpaperImageView removeFromSuperview];
        [visibleWallpapers removeObjectAtIndex:0];
        firstWallpaperImageView = [visibleWallpapers[0] wallpaperView];
    }
    
   
}
@end
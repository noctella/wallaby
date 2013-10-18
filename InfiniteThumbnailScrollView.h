//
//  InfiniteThumbnailScrollView.h
//  TesseractSample
//
//  Created by Jillian Crossley on 2013-10-09.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InfiniteScrollView;
@class WallpaperItem;

@interface InfiniteThumbnailScrollView : UIScrollView <UIScrollViewDelegate>{
    NSMutableArray *visibleThumbnails;
    NSMutableArray *wallpaperItems;
    int thumbnailRightIndex;
    int thumbnailLeftIndex;
    InfiniteScrollView *pairedScrollView;
    bool scrolledRemotely;
    bool isEditing;
}
- (id)initWithWallpaperItems:(NSMutableArray*)items;
- (void)setPairedScrollView: (InfiniteScrollView *)scrollView;
- (void)setScrolledRemotely;
-(void)setContentOffsetBeforeSwitch;
-(void)recenterIfNecessary;
-(IBAction)didLongPressThumbnail:(UILongPressGestureRecognizer*) sender;
-(void)removeWallpaperItem: (WallpaperItem *)wallpaperItem;

@property NSMutableArray *availableWallpaperItems;
@end

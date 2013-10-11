//
//  InfiniteThumbnailScrollView.h
//  TesseractSample
//
//  Created by Jillian Crossley on 2013-10-09.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import <UIKit/UIKit.h>
@class InfiniteScrollView;

@interface InfiniteThumbnailScrollView : UIScrollView <UIScrollViewDelegate>{
    NSMutableArray *visibleThumbnails;
    NSMutableArray *wallpaperItems;
    int thumbnailRightIndex;
    int thumbnailLeftIndex;
    InfiniteScrollView *pairedScrollView;
    float oldTrueContentOffsetX;
    float trueContentOffsetX;
    bool scrolledRemotely;
}
- (id)initWithWallpaperItems:(NSMutableArray*)items;
- (void)setPairedScrollView: (InfiniteScrollView *)scrollView;
- (void)setScrolledRemotely;
@end

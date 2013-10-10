//
//  InfiniteThumbnailScrollView.h
//  TesseractSample
//
//  Created by Jillian Crossley on 2013-10-09.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfiniteThumbnailScrollView : UIScrollView <UIScrollViewDelegate>{
    NSMutableArray *visibleThumbnails;
    NSMutableArray *wallpaperItems;
    int thumbnailRightIndex;
    int thumbnailLeftIndex;
    UIScrollView *pairedScrollView;
    float oldContentOffsetX;
}
- (id)initWithWallpaperItems:(NSMutableArray*)items;
- (void)setPairedScrollView: (UIScrollView *)scrollView;
@end

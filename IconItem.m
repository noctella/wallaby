//
//  IconPosition.m
//  TesseractSample
//
//  Created by Jillian Crossley on 10/27/2013.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import "IconItem.h"
#import "objc/runtime.h"

#define ICON_SIZE 114
#define LABEL_WIDTH 122
#define LABEL_HEIGHT 30

#define IS_RETINA_DISPLAY() [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f

// return the scale value based on device's display (2 retina, 1 other)
#define DISPLAY_SCALE IS_RETINA_DISPLAY() ? 2.0f : 1.0f

@implementation IconItem

@synthesize iconPosition, labelPosition, isPresent, label, greyIconView, clearIconView, appSelectionTap;

static NSMutableArray *items;

-(id)initWithIconPosition:(CGRect)iconPos andLabelPosition:(CGRect)labelPos{
    self = [super init];
    if(self){
        self.iconPosition = iconPos;
        self.labelPosition = labelPos;
        self.isPresent = false;
        self.label = @"";
    }
    return self;
}



+ (NSMutableArray *) items
{
    @synchronized(self){
        if(items == nil){
            items = [[NSMutableArray alloc]init];
            
            for(int i=0; i<5; i++){
                for(int j=0; j< 4; j++){
                    int iconX = 32 + (152*j);
                    int iconY = 50 + (176*i);
                    
                    int labelX = 32 + (152*j);
                    int labelY = 173 + (176*i);
                    
                    CGRect iconPosition = CGRectMake(iconX, iconY, ICON_SIZE, ICON_SIZE);
                    CGRect labelPosition = CGRectMake(labelX, labelY, LABEL_WIDTH, LABEL_HEIGHT);
                    
                    IconItem *item = [[IconItem alloc]initWithIconPosition:iconPosition andLabelPosition:labelPosition];
                    UIImage *greyIcon= [[UIImage alloc] initWithCGImage:[UIImage imageNamed: @"mask_grey.png"].CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
                    UIImageView *greyIconView = [[UIImageView alloc]initWithImage:greyIcon];
                    [greyIconView setUserInteractionEnabled:YES];
                    UITapGestureRecognizer *appSelectionTap = [[UITapGestureRecognizer alloc] init];                    objc_setAssociatedObject(appSelectionTap, "iconItem", item, OBJC_ASSOCIATION_ASSIGN);
                   // [greyIconView addGestureRecognizer:appSelectionTap];
                    
                    [greyIconView setFrame:CGRectMake([item iconPosition].origin.x/2 + 2, [item iconPosition].origin.y/2 + 2, [item iconPosition].size.width/2, [item iconPosition].size.height/2)];
                    
                    UIImage *clearIcon= [[UIImage alloc] initWithCGImage:[UIImage imageNamed: @"mask_clear.png"].CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
                    UIImageView *clearIconView = [[UIImageView alloc]initWithImage:clearIcon];
                    [clearIconView setUserInteractionEnabled:YES];
                    //[clearIconView addGestureRecognizer:appSelectionTap];
                    
                    [clearIconView setFrame:CGRectMake([item iconPosition].origin.x/2 + 2, [item iconPosition].origin.y/2 + 2, [item iconPosition].size.width/2, [item iconPosition].size.height/2)];
                    
                                                      
                    [item setGreyIconView: greyIconView];
                    [item setClearIconView: clearIconView];
                    [item setAppSelectionTap: appSelectionTap];
                    [items addObject:item];
                    
                }
            }
            
            //bottom icons
            for(int i=0; i< 4; i++){
                int iconX = 32 + (152*i);
                int iconY = 972;
                
                int labelX = 30 + (150*i);
                int labelY = 1094;
                
                CGRect iconPosition = CGRectMake(iconX, iconY, ICON_SIZE, ICON_SIZE);
                CGRect labelPosition = CGRectMake(labelX, labelY, LABEL_WIDTH, LABEL_HEIGHT);
                
                IconItem *item = [[IconItem alloc]initWithIconPosition:iconPosition andLabelPosition:labelPosition];
                
                UIImage *greyIcon= [[UIImage alloc] initWithCGImage:[UIImage imageNamed: @"mask_grey.png"].CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
                UIImageView *greyIconView = [[UIImageView alloc]initWithImage:greyIcon];
                [greyIconView setUserInteractionEnabled:YES];
                UITapGestureRecognizer *appSelectionTap = [[UITapGestureRecognizer alloc] init];                    objc_setAssociatedObject(appSelectionTap, "iconItem", item, OBJC_ASSOCIATION_ASSIGN);
                [greyIconView addGestureRecognizer:appSelectionTap];
                
                [greyIconView setFrame:CGRectMake([item iconPosition].origin.x/2 + 2, [item iconPosition].origin.y/2 + 2, [item iconPosition].size.width/2, [item iconPosition].size.height/2)];
                
                UIImage *clearIcon= [[UIImage alloc] initWithCGImage:[UIImage imageNamed: @"mask_clear.png"].CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
                UIImageView *clearIconView = [[UIImageView alloc]initWithImage:clearIcon];
                [clearIconView setUserInteractionEnabled:YES];
                //[clearIconView addGestureRecognizer:appSelectionTap];
                
                [clearIconView setFrame:CGRectMake([item iconPosition].origin.x/2 + 2, [item iconPosition].origin.y/2 + 2, [item iconPosition].size.width/2, [item iconPosition].size.height/2)];
                
                
                [item setGreyIconView: greyIconView];
                [item setClearIconView: clearIconView];
                [item setAppSelectionTap: appSelectionTap];

                
                [items addObject:item];
                
            }
        }
        return items;
    }
}

@end

//
//  IconPosition.m
//  TesseractSample
//
//  Created by Jillian Crossley on 10/27/2013.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import "IconItem.h"
#import "objc/runtime.h"
#import "WallpaperDatabase.h"

#define ICON_SIZE 114
#define LABEL_WIDTH 122
#define LABEL_HEIGHT 30

#define IS_RETINA_DISPLAY() [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f

// return the scale value based on device's display (2 retina, 1 other)
#define DISPLAY_SCALE IS_RETINA_DISPLAY() ? 2.0f : 1.0f

@implementation IconItem

@synthesize iconPosition, iconTemplatePosition, labelPosition, labelTemplatePosition, isPresent, label, icon,greyIconTemplateView, clearIconTemplateView, appSelectionTap;

static NSMutableArray *items;

-(id)initWithIconTemplatePosition:(CGRect)iconTemplatePos andLabelTemplatePosition:(CGRect)labelTemplatePos{
    self = [super init];
    if(self){
        self.iconTemplatePosition = iconTemplatePos;
        self.iconPosition = iconTemplatePos;
        self.labelTemplatePosition = labelTemplatePos;
        self.labelPosition = labelTemplatePos;
        self.isPresent = false;
        self.label = @"";
    
    }
    return self;
}

-(void) encodeWithCoder: (NSCoder *) encoder{
    
    [encoder encodeCGRect:iconTemplatePosition forKey:@"iconTemplatePosition"];
    [encoder encodeCGRect:iconPosition forKey:@"iconPosition"];
    [encoder encodeCGRect:labelTemplatePosition forKey:@"labelTemplatePosition"];
    [encoder encodeCGRect:labelPosition forKey:@"labelPosition"];
    [encoder encodeBool:isPresent forKey:@"isPresent"];
    [encoder encodeObject:label forKey:@"label"];
    [encoder encodeObject:icon forKey:@"icon"];
    
}

-(id) initWithCoder: (NSCoder *) decoder{
    
    self = [super init];
    self.iconTemplatePosition = [decoder decodeCGRectForKey:@"iconTemplatePosition"];
    self.iconPosition = [decoder decodeCGRectForKey:@"iconPosition"];
    self.labelTemplatePosition = [decoder decodeCGRectForKey:@"labelTemplatePosition"];
    self.labelPosition = [decoder decodeCGRectForKey:@"labelPosition"];
    self.isPresent = [decoder decodeBoolForKey:@"isPresent"];
    self.label = [decoder decodeObjectForKey:@"label"];
    self.icon = [decoder decodeObjectForKey:@"icon"];
    
    UIImage *greyIcon= [[UIImage alloc] initWithCGImage:[UIImage imageNamed: @"mask_grey.png"].CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
    UIImageView *greyIconView = [[UIImageView alloc]initWithImage:greyIcon];
    [greyIconView setUserInteractionEnabled:YES];
   
    [greyIconView setFrame:CGRectMake([self iconTemplatePosition].origin.x/2 + 2, [self iconTemplatePosition].origin.y/2 + 2, [self iconTemplatePosition].size.width/2, [self iconTemplatePosition].size.height/2)];
    
    UIImage *clearIcon= [[UIImage alloc] initWithCGImage:[UIImage imageNamed: @"mask_clear.png"].CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
    UIImageView *clearIconView = [[UIImageView alloc]initWithImage:clearIcon];
    [clearIconView setUserInteractionEnabled:YES];
    //[clearIconView addGestureRecognizer:appSelectionTap];
    
    [clearIconView setFrame:CGRectMake([self iconTemplatePosition].origin.x/2 + 2, [self iconTemplatePosition].origin.y/2 + 2, [self iconTemplatePosition].size.width/2, [self iconTemplatePosition].size.height/2)];
    
    
    [self setGreyIconTemplateView: greyIconView];
    [self setClearIconTemplateView: clearIconView];
    [self setAppSelectionTap: appSelectionTap];
    
    return self;
}



+ (NSMutableArray *) items
{
    @synchronized(self){
        if(items == nil){
            
            items = [WallpaperDatabase loadIconItems];
            if(items == nil){
                
                items = [[NSMutableArray alloc]init];
                
                for(int i=0; i<5; i++){
                    for(int j=0; j< 4; j++){
                        int iconX = 32 + (152*j);
                        int iconY = 50 + (176*i);
                        
                        int labelX = 32 + (152*j);
                        int labelY = 173 + (176*i);
                        
                        CGRect iconTemplatePosition = CGRectMake(iconX, iconY, ICON_SIZE, ICON_SIZE);
                        CGRect labelTemplatePosition = CGRectMake(labelX, labelY, LABEL_WIDTH, LABEL_HEIGHT);
                        
                        IconItem *item = [[IconItem alloc]initWithIconTemplatePosition:iconTemplatePosition andLabelTemplatePosition:labelTemplatePosition];
                        
                        UIImage *greyIcon= [[UIImage alloc] initWithCGImage:[UIImage imageNamed: @"mask_grey.png"].CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
                        UIImageView *greyIconView = [[UIImageView alloc]initWithImage:greyIcon];
                        [greyIconView setUserInteractionEnabled:YES];
                        UITapGestureRecognizer *appSelectionTap = [[UITapGestureRecognizer alloc] init];                    objc_setAssociatedObject(appSelectionTap, "iconItem", item, OBJC_ASSOCIATION_ASSIGN);
                       // [greyIconView addGestureRecognizer:appSelectionTap];
                        
                        [greyIconView setFrame:CGRectMake([item iconTemplatePosition].origin.x/2 + 2, [item iconTemplatePosition].origin.y/2 + 2, [item iconTemplatePosition].size.width/2, [item iconTemplatePosition].size.height/2)];
                        
                        UIImage *clearIcon= [[UIImage alloc] initWithCGImage:[UIImage imageNamed: @"mask_clear.png"].CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
                        UIImageView *clearIconView = [[UIImageView alloc]initWithImage:clearIcon];
                        [clearIconView setUserInteractionEnabled:YES];
                        //[clearIconView addGestureRecognizer:appSelectionTap];
                        
                        [clearIconView setFrame:CGRectMake([item iconTemplatePosition].origin.x/2 + 2, [item iconTemplatePosition].origin.y/2 + 2, [item iconTemplatePosition].size.width/2, [item iconTemplatePosition].size.height/2)];
                        
                        
                        [item setGreyIconTemplateView: greyIconView];
                        [item setClearIconTemplateView: clearIconView];
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
                    
                    CGRect iconTemplatePosition = CGRectMake(iconX, iconY, ICON_SIZE, ICON_SIZE);
                    CGRect labelTemplatePosition = CGRectMake(labelX, labelY, LABEL_WIDTH, LABEL_HEIGHT);
                    
                    IconItem *item = [[IconItem alloc]initWithIconTemplatePosition:iconTemplatePosition andLabelTemplatePosition:labelTemplatePosition];
                    
                    UIImage *greyIcon= [[UIImage alloc] initWithCGImage:[UIImage imageNamed: @"mask_grey.png"].CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
                    UIImageView *greyIconView = [[UIImageView alloc]initWithImage:greyIcon];
                    [greyIconView setUserInteractionEnabled:YES];
                    UITapGestureRecognizer *appSelectionTap = [[UITapGestureRecognizer alloc] init];                    objc_setAssociatedObject(appSelectionTap, "iconItem", item, OBJC_ASSOCIATION_ASSIGN);
                    [greyIconView addGestureRecognizer:appSelectionTap];
                    
                    [greyIconView setFrame:CGRectMake([item iconTemplatePosition].origin.x/2 + 2, [item iconTemplatePosition].origin.y/2 + 2, [item iconTemplatePosition].size.width/2, [item iconTemplatePosition].size.height/2)];
                    
                    UIImage *clearIcon= [[UIImage alloc] initWithCGImage:[UIImage imageNamed: @"mask_clear.png"].CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
                    UIImageView *clearIconView = [[UIImageView alloc]initWithImage:clearIcon];
                    [clearIconView setUserInteractionEnabled:YES];
                    //[clearIconView addGestureRecognizer:appSelectionTap];
                    
                    [clearIconView setFrame:CGRectMake([item iconTemplatePosition].origin.x/2 + 2, [item iconTemplatePosition].origin.y/2 + 2, [item iconTemplatePosition].size.width/2, [item iconTemplatePosition].size.height/2)];
                    
                    
                    [item setGreyIconTemplateView: greyIconView];
                    [item setClearIconTemplateView: clearIconView];
                    [item setAppSelectionTap: appSelectionTap];

                    
                    [items addObject:item];
                    
                }
                [WallpaperDatabase saveIconItems: items];
            }
        }
        return items;
    }
}

@end

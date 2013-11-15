//
//  IconPosition.h
//  TesseractSample
//
//  Created by Jillian Crossley on 10/27/2013.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IconItem : NSObject <NSCoding>


-(id) initWithIconTemplatePosition: (CGRect) iconPosition andLabelTemplatePosition: (CGRect) labelPosition;

+ (NSMutableArray *) items;

-(void) encodeWithCoder: (NSCoder *) encoder;
-(id) initWithCoder: (NSCoder *) decoder;

@property CGRect iconTemplatePosition, iconPosition;
@property CGRect labelTemplatePosition, labelPosition;
@property BOOL isPresent;
@property NSString *label;
@property UIImageView *greyIconTemplateView, *clearIconTemplateView;
@property UIImage *icon;
@property UITapGestureRecognizer *appSelectionTap;
@end

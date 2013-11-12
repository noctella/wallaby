//
//  IconPosition.h
//  TesseractSample
//
//  Created by Jillian Crossley on 10/27/2013.
//  Copyright (c) 2013 Loïs Di Qual. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IconItem : NSObject


-(id) initWithIconPosition: (CGRect) iconPosition andLabelPosition: (CGRect) labelPosition;

+ (NSMutableArray *) items;

@property CGRect iconPosition;
@property CGRect labelPosition;
@property BOOL isPresent;
@property NSString *label;
@property UIImageView *greyIconView, *clearIconView;
@property UITapGestureRecognizer *appSelectionTap;
@end

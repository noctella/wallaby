//
//  WWallpaperController.m
//  Wallaby
//
//  Created by Jillian Crossley on 2013-07-12.
//  Copyright (c) 2013 Jillian Crossley. All rights reserved.
//

#import "WWallpaperController.h"
#import "objc/runtime.h"
#import "WallpaperProcessor.h"
#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"
#import "WallpaperDatabase.h"
#import "WallpaperItem.h"
#import "InfiniteScrollView.h"
#import "InfiniteThumbnailScrollView.h"
#import "ChangeHomescreenController.h"
#import "ImageUtils.h"
#import "IconItem.h"
#import "Tesseract.h"

#define PIXEL_SIZE(size) IS_RETINA_DISPLAY() ? CGSizeMake(size.width/2.0f, size.height/2.0f) : size
#define SCREEN_HEIGHT 568
#define SCREEN_WIDTH 320


#define BUFFER_SIZE 6

// return true if the device has a retina display, false otherwise
#define IS_RETINA_DISPLAY() [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f

// return the scale value based on device's display (2 retina, 1 other)
#define DISPLAY_SCALE IS_RETINA_DISPLAY() ? 2.0f : 1.0f

// if the device has a retina display return the real scaled pixel size, otherwise the same size will be returned
#define PIXEL_SIZE(size) IS_RETINA_DISPLAY() ? CGSizeMake(size.width/2.0f, size.height/2.0f) : size

#define DISPLAY_WIDTH 320
#define DISPLAY_HEIGHT 568
#define WALLPAPER_SCALE 0.77
#define WALLPAPER_WIDTH 250.0
#define WALLPAPER_HEIGHT (DISPLAY_HEIGHT*WALLPAPER_SCALE)
#define WALLPAPER_PADDING 2.0
#define STATUS_HEIGHT 23
#define RATIO 2.419
#define RATIO_WITH_PADDING ((WALLPAPER_WIDTH + WALLPAPER_PADDING) / (THUMBNAIL_SIZE + WALLPAPER_PADDING))

#define FRONT_BUFFER 107

#define THUMBNAIL_SIZE (WALLPAPER_WIDTH/RATIO)

#define WALLPAPER_THUMBNAIL_RATIO (WALLPAPER_WIDTH/THUMBNAIL_SIZE)

@interface WWallpaperController () <UIScrollViewDelegate>

@end

@implementation WWallpaperController
static UIImage *template;
static NSMutableArray *wallpaperItems;
static NSMutableArray *visibleWallpapers;
static NSMutableArray *wallpaperTapGestureRecognizers;
static InfiniteScrollView *wallpaperScrollView;
static InfiniteThumbnailScrollView *thumbnailScrollView;
static UIImage *mask;



+ (UIImage *)template
{
    @synchronized(self){
        if(template == nil){
            template = [UIImage alloc];
        }
        return template;
    }
}

+ (void) setTemplate:(UIImage *)image
{
    @synchronized(self){
        template = image;
        [WallpaperProcessor setTemplate:template];
        /*for(WallpaperItem *wallpaperItem in wallpaperItems){
            UIImage *wallpaper =[WallpaperProcessor process: [wallpaperItem getBackground]];
            [[wallpaperItem wallpaperView]setImage:wallpaper];
            [wallpaperItem setWallpaper: wallpaper];
        }*/
      
    }
}

+ (NSMutableArray *) wallpaperItems
{
    @synchronized(self){
        if(wallpaperItems== nil){
            wallpaperItems= [NSMutableArray alloc];
        }
        return wallpaperItems;
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        wallpaperItems = [WallpaperDatabase loadWallpapers];
        
       
        visibleWallpapers = [[NSMutableArray alloc]init];
        wallpaperTapGestureRecognizers = [[NSMutableArray alloc]initWithCapacity:BUFFER_SIZE];
        NSLog(@"creating view controller");
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    template = [WallpaperDatabase loadTemplate];
    
    if (template == nil){
        UIImage *homescreen = [UIImage imageNamed: @"testLarge.png"];
        [WallpaperProcessor setTemplateAndIconsWithHomescreen:homescreen];
        NSLog(@"homescreen was nil :)");
    }

   
    thumbnailScrollView = [[InfiniteThumbnailScrollView alloc]initWithWallpaperItems:wallpaperItems];
     wallpaperScrollView = [[InfiniteScrollView alloc]initWithWallpaperItems:wallpaperItems ];
    
    [wallpaperScrollView setDelegate:self];
    
    [wallpaperScrollView setPairedScrollView: thumbnailScrollView];
    [thumbnailScrollView setPairedScrollView:wallpaperScrollView];
    
    [wallpaperScrollView setAvailableWallpaperItems:[thumbnailScrollView availableWallpaperItems]];
    
    addWallpaperButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addWallpaperButton setBackgroundImage: [UIImage imageNamed:@"add_wallpaper_icon.png"] forState:UIControlStateNormal];
    [addWallpaperButton addTarget:self action:@selector(didTouchAddWallpaper:) forControlEvents:UIControlEventTouchDown];
    addWallpaperButton.frame = CGRectMake(DISPLAY_WIDTH - 70, DISPLAY_HEIGHT - 70, 60, 60);
    
    changeHomescreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [changeHomescreenButton setBackgroundImage:[UIImage imageNamed:@"add_wallpaper_icon.png"]forState:UIControlStateNormal];
    [changeHomescreenButton addTarget:self action:@selector(didTouchChangeTemplate:) forControlEvents:UIControlEventTouchDown];
    changeHomescreenButton.frame = CGRectMake(DISPLAY_WIDTH - 30, 30, 50, 50);
    
   
    
    
    
    
    

	// Finally, add the UIScrollView to the controller's view
    [self.view addSubview:wallpaperScrollView];
    [self.view addSubview:thumbnailScrollView];
    [self.view addSubview:addWallpaperButton];
    [self.view addSubview:changeHomescreenButton];
    
    


}


-(void) viewDidAppear:(BOOL)animated{
    
    [thumbnailScrollView removeFromSuperview];
    [wallpaperScrollView removeFromSuperview];
    
    thumbnailScrollView = [[InfiniteThumbnailScrollView alloc]initWithWallpaperItems:wallpaperItems];
    wallpaperScrollView = [[InfiniteScrollView alloc]initWithWallpaperItems:wallpaperItems ];
    
    [wallpaperScrollView setDelegate:self];
    
    [wallpaperScrollView setPairedScrollView: thumbnailScrollView];
    [thumbnailScrollView setPairedScrollView:wallpaperScrollView];
    
    [wallpaperScrollView setAvailableWallpaperItems:[thumbnailScrollView availableWallpaperItems]];
    
	// Finally, add the UIScrollView to the controller's view
    [self.view addSubview:wallpaperScrollView];
    [self.view addSubview:thumbnailScrollView];
    [self.view addSubview:addWallpaperButton];
    [self.view addSubview:changeHomescreenButton];
    
    UIImage *homescreen = [ImageUtils scaleImage:[WallpaperProcessor template]];
    NSLog(@"processing the homescreen, %@", homescreen);
    UIImage *template = [ImageUtils scaleImagedName:@"transparentWallpaper.png"];
    
    /*for(IconItem *item in [IconItem items]){
        if([item isPresent]){
            UIImageView *imageView = [[UIImageView alloc]initWithImage:[item icon]];
            [self.view addSubview:imageView];
            
            template = [self drawText:[item label] inImage:template atPoint:CGPointMake([item labelPosition].origin.x, [item labelPosition].origin.y)];
        }
    }*/
    
    [self.view addSubview:[ImageUtils imageViewWithImage:homescreen]];

    

}

- (IBAction) didTouchAddWallpaper:(id)sender{
    // Create the an album controller and image picker
    ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] init];
    ELCImagePickerController *imagePicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    [albumController setParent:imagePicker];
    [imagePicker setDelegate:self];
    
    // Present modally
    [self presentViewController:imagePicker
                       animated:YES
                     completion:nil];
}

- (IBAction) didTouchChangeTemplate: (id) sender {
    ChangeHomescreenController *changeHomescreenController = [[ChangeHomescreenController alloc]initWithNibName:@"ChangeHomescreenController" bundle:nil];
    [self presentViewController:changeHomescreenController animated:YES completion:nil];
    [changeHomescreenController setCurrentHomescreen: template];
}

- (IBAction) didTouchWallpaper: (UITapGestureRecognizer*) sender{
    NSLog(@"did touch omg");
    WallpaperItem *wallpaperItem = objc_getAssociatedObject(sender, "wallpaperItem");
    UIImage *wallpaper = [wallpaperItem getWallpaper];
    WallpaperZoomController *zoomController = [[WallpaperZoomController alloc] initWithNibName:@"WallpaperZoomController" bundle:nil];
    
    [self presentViewController: zoomController animated:YES completion: nil];
    [zoomController setWallpaper: wallpaper];
}

-(IBAction)didTouchDeleteWallpaper:(id)sender{
    WallpaperItem *wallpaperItem = objc_getAssociatedObject(sender, "wallpaperItem");

    [thumbnailScrollView removeWallpaperItem: wallpaperItem];
    
}


- (void)didReceiveMemoryWarningƒ
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
	   
	for(NSDictionary *dict in info) {
        UIImage *wallpaper = [dict objectForKey:UIImagePickerControllerOriginalImage];
        //UIImage *wallpaper = [WallpaperProcessor process: image ];
        UIImage *thumbnail = [WallpaperProcessor makeThumbnail: wallpaper];
        WallpaperItem *wallpaperItem = [[WallpaperItem alloc] initWithWallpaper:wallpaper andBackground:wallpaper andThumbnail:thumbnail];
        [wallpaperItem setIndex:[wallpaperItems count]];
        [wallpaperItems addObject:wallpaperItem];
        [wallpaperItem saveData];

    }		
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *) cropImage: (UIImage *) image toRect: (CGRect)rect
{
    // Create bitmap image from original image data,
    // using rectangle to specify desired crop area
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    // CGImageRelease(imageRef);
    
    return img;
}

-(UIImage *) formatImage: (UIImage *) wallpaper{
    //Crop image to the max rect it can be
    float height = wallpaper.size.height;
    float width = (SCREEN_WIDTH * height)/SCREEN_HEIGHT;
    
    if(wallpaper.size.width < width){
        width = wallpaper.size.width;
        height = (SCREEN_HEIGHT*width)/SCREEN_HEIGHT;
    }
    
    float heightRatio = SCREEN_HEIGHT/height;
    UIImage *formattedImage = [self cropImage:wallpaper toRect:CGRectMake(0, 0, width*2, height*2)];
    
    return [self imageWithImage:formattedImage scaledToSize: CGSizeMake(width  * heightRatio * 2, height * heightRatio * 2)];
    
}

- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


- (UIImage*) drawText:(NSString*) text inImage:(UIImage*)  image atPoint:(CGPoint)   point
{
    //convert image1 from UIImage to CGImageRef to get Width and Height
    CGImageRef img1Ref = image.CGImage;
    float img1W        = CGImageGetWidth(img1Ref);
    float img1H        = CGImageGetHeight(img1Ref);
    
    CGSize size = CGSizeMake(img1W, img1H);
    
    UIGraphicsBeginImageContext(size);
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:24];
    [image drawInRect:CGRectMake(0,0,img1W,img1H)];
    CGRect rect = CGRectMake(point.x, point.y, 120, img1H);
    [[UIColor whiteColor] set];
    //[text drawInRect:CGRectIntegral(rect) withFont:font];
    [text drawInRect:rect withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *) mask
{
    @synchronized(self){
        if(mask == nil){
            mask = [[UIImage alloc] initWithCGImage:[UIImage imageNamed: @"mask.png"].CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
        }
        return mask;
    }
}


- (UIImage*) maskAndCropImage:(UIImage *)image withX: (float) x withY: (float) y withMask:(UIImage *)maskImage {
    CGRect rect = CGRectMake(x, y , 120, 120);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
	CGImageRef maskRef = maskImage.CGImage;
    
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
	CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
	return [UIImage imageWithCGImage:masked];
}
    


@end

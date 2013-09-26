//
//  WWallpaperController.m
//  Wallaby
//
//  Created by Jillian Crossley on 2013-07-12.
//  Copyright (c) 2013 Jillian Crossley. All rights reserved.
//

#import "WWallpaperController.h"
#import "tesseract.h"
#import "objc/runtime.h"
// return true if the device has a retina display, false otherwise
#define IS_RETINA_DISPLAY() [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f

// return the scale value based on device's display (2 retina, 1 other)
#define DISPLAY_SCALE IS_RETINA_DISPLAY() ? 2.0f : 1.0f

// if the device has a retina display return the real scaled pixel size, otherwise the same size will be returned
#define PIXEL_SIZE(size) IS_RETINA_DISPLAY() ? CGSizeMake(size.width/2.0f, size.height/2.0f) : size

@interface WWallpaperController ()

@end

@implementation WWallpaperController
@synthesize scrollView;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"creating view controller");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"view did load");

   // [self setView:ImageView];
	// Do any additional setup after loading the view.
    /*NSLog(@"setting view");
     Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
     [tesseract setImage:[UIImage imageNamed:@"test.jpg"]];
     [tesseract recognize];
     
     NSLog(@"%@", [tesseract recognizedText]);*/
    UIImage *screenshotOriginal = [UIImage imageNamed: @"testLarge.png"];
    
    UIImage *screenshot = [[UIImage alloc] initWithCGImage:screenshotOriginal.CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
    UIImage * maskOriginal = [UIImage imageNamed: @"maskx.png"];
    UIImage *mask = [[UIImage alloc] initWithCGImage:maskOriginal.CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
    
    
    NSMutableArray *icons = [[NSMutableArray alloc]init];
    UIImage *mergedImageOriginal = [UIImage imageNamed: @"wallpaper1.png"];
    UIImage *mergedImage = [[UIImage alloc] initWithCGImage:mergedImageOriginal.CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
    
    for(int i=0; i<4; i++){
        for(int j=0; j< 5; j++){
            int x = 32 + (152*i);
            int y = 50 + (176*j);
            UIImage *icon = [self maskAndCropImage:screenshot withX:x withY:y withMask:mask];
            [icons addObject: icon];
            mergedImage = [self MergeImage:mergedImage withImage:icon atXLoc: x atYLoc: y];
            
        }
    }
    for(int i=0; i< 4; i++){
        int x = 32 + (152*i);
        int y = 972;
        UIImage *icon = [self maskAndCropImage:screenshot withX:x withY:y withMask:mask];
        [icons addObject: icon];
        mergedImage = [self MergeImage:mergedImage withImage:icon atXLoc: x atYLoc: y];
        
    }
    
    
    
    
    NSMutableArray *labels = [[NSMutableArray alloc]init];
    NSMutableArray *labelImages = [[NSMutableArray alloc]init];
    for(int i=0; i<4; i++){
        for(int j=0; j< 5; j++){
            int x = 32 + (152*i);
            int y = 173 + (176*j);
            UIImage * image = [UIImage imageNamed: @"testLarge.png"];
            UIImage *title = [self cropImage:image toRect:CGRectMake(x, y, 122, 30)];
            Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
            [tesseract setImage:title];
            [tesseract recognize];
            NSString *label = [tesseract recognizedText];
            label =  [label
                      stringByReplacingOccurrencesOfString:@" " withString:@""];
            [labels addObject:label];
            mergedImage = [self drawText:label inImage:mergedImage atPoint:CGPointMake(x, y)];
            [labelImages addObject:title];
            
            // NSLog(@"%@", [tesseract recognizedText]);
            
        }
    }
    
    for(int i=0; i< 4; i++){
        int x = 30 + (150*i);
        int y = 1094;
        UIImage * image = [UIImage imageNamed: @"testLarge.png"];
        UIImage *title = [self cropImage:image toRect:CGRectMake(x, y, 132, 30)];
        Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
        [tesseract setImage:title];
        [tesseract recognize];
        NSString *label = [tesseract recognizedText];
        label =  [label
                  stringByReplacingOccurrencesOfString:@" " withString:@""];
        [labels addObject:label];
        mergedImage = [self drawText:label inImage:mergedImage atPoint:CGPointMake(x, y)];
        [labelImages addObject:title];
        
        //NSLog(@"%@", [tesseract recognizedText]);
        
        
    }
    
    
    
    //mergedImage = [self cropImage:mergedImage toRect:CGRectMake(0, 40, mergedImage.size.width, mergedImage.size.height)];
    //finalWallpaper = [[UIImage alloc]init];
    finalWallpaper = [[UIImage alloc] initWithCGImage:mergedImage.CGImage scale:3.0f orientation:UIImageOrientationUp];
    
    UIImage *image1 = [[UIImage alloc] initWithCGImage:[UIImage imageNamed:@"wallpaper2.PNG"].CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
    UIImage *image2 = [[UIImage alloc] initWithCGImage:[UIImage imageNamed:@"wallpaper3.PNG"].CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
	UIImage *image3 = [[UIImage alloc] initWithCGImage:[UIImage imageNamed:@"wallpaper4.PNG"].CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
    
	NSArray *images = [[NSArray alloc] initWithObjects:finalWallpaper, image1,image2,image3,nil];
    
    int imageWidth = finalWallpaper.size.width;
    int imageHeight = finalWallpaper.size.height;
    int padding = 35;
    
    // Now create a UIScrollView to hold the UIImageViews
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,40,325,imageHeight)];
    
    
    
	scrollView.pagingEnabled = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [scrollView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    int numberOfViews = 3;
	for (int i = 0; i < numberOfViews; i++) {
		CGFloat xOrigin = i * (imageWidth + padding);
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin,0,imageWidth,imageHeight)];
        
		[imageView setImage:[images objectAtIndex:i]];
		[scrollView addSubview:imageView];
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouch:)];
        tap.numberOfTouchesRequired = 1;
        tap.numberOfTapsRequired = 1;
        objc_setAssociatedObject(tap, "image", [images objectAtIndex:i], OBJC_ASSOCIATION_ASSIGN);
        [imageView addGestureRecognizer:tap];
	}
    
    /*UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
     tap.numberOfTouchesRequired = 1;
     tap.numberOfTapsRequired = 1;
     
     [scrollView addGestureRecognizer:tap];*/
    
    // Set the contentSize equal to the size of the UIImageView
    // scrollView.contentSize = imageView.scrollview.size;
	scrollView.contentSize = CGSizeMake(numberOfViews * (imageWidth + padding), imageHeight);
    
    
	// Finally, add the UIScrollView to the controller's view
    [self.view addSubview:scrollView];
    
    
    // [ImageView initWithImage:finalWallpaper ];
    
    //[ImageView initWithImage:[labelImages objectAtIndex:22] ];
    //[labelImages objectAtIndex:16]

}

-(void) viewDidAppear:(BOOL)animated{
    NSLog(@"view did appear");

    }

- (IBAction) didTouch: (UITapGestureRecognizer*) sender{
    UIImage *wallpaper = objc_getAssociatedObject(sender, "image");
    WallpaperZoomController *zoomController = [[WallpaperZoomController alloc] initWithNibName:@"WallpaperZoomController" bundle:nil];
    
    [self presentViewController: zoomController animated:YES completion: nil];
    [zoomController setWallpaper: wallpaper];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *screenshot = [info objectForKey: UIImagePickerControllerOriginalImage];
    UIImage *image = [[UIImage alloc] initWithCGImage:screenshot.CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
    UIImage * maskOriginal = [UIImage imageNamed: @"maskx.png"];
    UIImage *mask = [[UIImage alloc] initWithCGImage:maskOriginal.CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
    
    //
    UIImage *title = [self cropImage:image toRect:CGRectMake(0, 0, 300, 300)];
    Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
    [tesseract setImage:title];
    [tesseract recognize];
    
    NSLog(@"%@", [tesseract recognizedText]);
    
    
    NSMutableArray *icons = [[NSMutableArray alloc]init];
    UIImage *mergedImageOriginal = [UIImage imageNamed: @"wallpaper1.png"];
    UIImage *mergedImage = [[UIImage alloc] initWithCGImage:mergedImageOriginal.CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
    
    for(int i=0; i<4; i++){
        for(int j=0; j< 5; j++){
            int x = 33 + (152*i);
            int y = 50 + (176*j);
            UIImage *icon = [self maskAndCropImage:image withX:x withY:y withMask:mask];
            [icons addObject: icon];
mergedImage = [self MergeImage:mergedImage withImage:icon atXLoc: x atYLoc: y];
            
        }
    }

    UIImage *img = [self drawText:@"Some text" inImage:mergedImage atPoint:CGPointMake(0, 0)];
    
    [ImageView initWithImage: title];
    [ImageView initWithImage: mergedImage];
   
    
}


- (UIImage *) cropImage: (UIImage *) image toRect: (CGRect)rect
{
    // Create bitmap image from original image data,
    // using rectangle to specify desired crop area
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    return img;
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

-(UIImage*)MergeImage:(UIImage*)img1 withImage:(UIImage*)img2 atXLoc: (int) x atYLoc: (int) y
{
    //return value
    UIImage* result = nil;
    
    //convert image1 from UIImage to CGImageRef to get Width and Height
    CGImageRef img1Ref = img1.CGImage;
    float img1W        = CGImageGetWidth(img1Ref);
    float img1H        = CGImageGetHeight(img1Ref);
    
    //convert image2 from UIImage to CGImage to get Width and Height
    CGImageRef img2Ref = img2.CGImage;
    float img2W        = CGImageGetWidth(img2Ref);
    float img2H        = CGImageGetHeight(img2Ref);
    
    //Create output image size
    CGSize size = CGSizeMake(MAX(img1W, img2W), MAX(img1H, img2H));
    
    //Start image context to draw the two images
    UIGraphicsBeginImageContext(size);
    
    //draw two images in the context
    [img1 drawInRect:CGRectMake(0, 0, img1W, img1H)];
    [img2 drawInRect:CGRectMake(x, y, img2W, img2H)];
    
    //get the result of drawing as UIImage
    result = UIGraphicsGetImageFromCurrentImageContext();
    
    //End and close context
    UIGraphicsEndImageContext();
    
    //release All CGImageRef 's
    CGImageRelease(img2Ref);
    //CGImageRelease(img1Ref);
    
    //return value :)
    UIImage *returnedImage = [[UIImage alloc] initWithCGImage:result.CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
    return returnedImage;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) takePicture: (id) sender{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imagePicker setDelegate:self];
    [self presentViewController: imagePicker animated:YES completion:nil];
}

@end

//
//  WWallpaperController.m
//  Wallaby
//
//  Created by Jillian Crossley on 2013-07-12.
//  Copyright (c) 2013 Jillian Crossley. All rights reserved.
//

#import "WWallpaperController.h"
#import "tesseract.h"
// return true if the device has a retina display, false otherwise
#define IS_RETINA_DISPLAY() [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f

// return the scale value based on device's display (2 retina, 1 other)
#define DISPLAY_SCALE IS_RETINA_DISPLAY() ? 2.0f : 1.0f

// if the device has a retina display return the real scaled pixel size, otherwise the same size will be returned
#define PIXEL_SIZE(size) IS_RETINA_DISPLAY() ? CGSizeMake(size.width/2.0f, size.height/2.0f) : size

@interface WWallpaperController ()

@end

@implementation WWallpaperController


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
   // [self setView:ImageView];
	// Do any additional setup after loading the view.
}

-(void) viewDidAppear:(BOOL)animated{
    NSLog(@"setting view");
    Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
    [tesseract setImage:[UIImage imageNamed:@"image_sample.jpg"]];
    [tesseract recognize];
    
    NSLog(@"%@", [tesseract recognizedText]);
    
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *screenshot = [info objectForKey: UIImagePickerControllerOriginalImage];
    UIImage *image = [[UIImage alloc] initWithCGImage:screenshot.CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
    UIImage * maskOriginal = [UIImage imageNamed: @"maskx.png"];
    UIImage *mask = [[UIImage alloc] initWithCGImage:maskOriginal.CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
    
    
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
    //UIImage *mergedImage = [self MergeImage:image withImage:[icons objectAtIndex:2]];
    NSLog(@"hello");
    UIImage *img = [self drawText:@"Some text" inImage:mergedImage atPoint:CGPointMake(0, 0)];
    
    [ImageView initWithImage: img];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (UIImage*) drawText:(NSString*) text inImage:(UIImage*)  image atPoint:(CGPoint)   point
{
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    [text drawInRect:CGRectIntegral(rect) withFont:font];
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
    CGImageRelease(img1Ref);
    
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

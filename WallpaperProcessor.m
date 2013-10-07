//
//  WallpaperProcessor.m
//  TesseractSample
//
//  Created by Jillian Crossley on 2013-09-25.
// return true if the device has a retina display, false otherwise
#define IS_RETINA_DISPLAY() [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f

// return the scale value based on device's display (2 retina, 1 other)
#define DISPLAY_SCALE IS_RETINA_DISPLAY() ? 2.0f : 1.0f

#define WALLPAPER_SCALE 2.0

// if the device has a retina display return the real scaled pixel size, otherwise the same size will be returned
#define PIXEL_SIZE(size) IS_RETINA_DISPLAY() ? CGSizeMake(size.width/2.0f, size.height/2.0f) : size
#define SCREEN_HEIGHT 568
#define SCREEN_WIDTH 320

#import "WallpaperProcessor.h"
#import "tesseract.h"


@implementation WallpaperProcessor
static UIImage *template;
static UIImage *mask;


+ (UIImage *) template
{
    @synchronized(self){
        if(template == nil){
            template = [UIImage alloc];
        }
        return template;
    }
}

+ (UIImage *) mask
{
    @synchronized(self){
        if(mask == nil){
            mask = [[UIImage alloc] initWithCGImage:[UIImage imageNamed: @"mask.png"].CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
        }
        return mask;
    }
}

+ (void) setTemplate:(UIImage *)screen{
    template = screen;
}

+ (UIImage *) processHomescreen: (UIImage *) image{
    
   
     UIImage *homescreen = [[UIImage alloc] initWithCGImage:image.CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];
    NSLog(@"processing the homescreen, %@", homescreen);
    UIImage *template = [[UIImage alloc] initWithCGImage:[UIImage imageNamed: @"transparentWallpaper.png"].CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];

    //main icons
    for(int i=0; i<4; i++){
        for(int j=0; j< 5; j++){
            int x = 32 + (152*i);
            int y = 50 + (176*j);
            UIImage *icon = [self maskAndCropImage:homescreen withX:x withY:y withMask:[self mask]];
            template = [self MergeImage:template withImage:icon atXLoc: x atYLoc: y];
        }
    }
    
    //bottom icons
    for(int i=0; i< 4; i++){
        int x = 32 + (152*i);
        int y = 972;
        UIImage *icon = [self maskAndCropImage:homescreen withX:x withY:y withMask:[self mask]];
        template = [self MergeImage:template withImage:icon atXLoc: x atYLoc: y];
    }
    
    Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
    
    //main labels
    for(int i=0; i<4; i++){
        for(int j=0; j< 5; j++){
            int x = 32 + (152*i);
            int y = 173 + (176*j);
            UIImage *title = [self cropImage:homescreen toRect:CGRectMake(x, y, 122, 30)]; 
            [tesseract setImage:title];
            [tesseract recognize];
            NSString *label = [tesseract recognizedText];
            label =  [label
                      stringByReplacingOccurrencesOfString:@" " withString:@""];
            template = [self drawText:label inImage:template atPoint:CGPointMake(x, y)];

        }
    }
    
    //bottom labels
    for(int i=0; i< 4; i++){
        int x = 30 + (150*i);
        int y = 1094;
        UIImage *title = [self cropImage:homescreen toRect:CGRectMake(x, y, 132, 30)];
        Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
        [tesseract setImage:title];
        [tesseract recognize];
        NSString *label = [tesseract recognizedText];
        label =  [label
                  stringByReplacingOccurrencesOfString:@" " withString:@""];
        template = [self drawText:label inImage:template atPoint:CGPointMake(x, y)];
 
    }
    return template;
}

+ (UIImage *)process: (UIImage *)wallpaper{
    UIImage *processedWallpaperOrig = [[UIImage alloc] initWithCGImage:wallpaper.CGImage scale:DISPLAY_SCALE orientation:UIImageOrientationUp];

    UIImage *processedWallpaper = [self formatImage:processedWallpaperOrig];
    processedWallpaper = [self MergeImage:processedWallpaper withImage:template atXLoc:0 atYLoc:0];
    return processedWallpaper;
    
}



+ (UIImage *) cropImage: (UIImage *) image toRect: (CGRect)rect
{
    // Create bitmap image from original image data,
    // using rectangle to specify desired crop area
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
   // CGImageRelease(imageRef);
    
    return img;
}

+(UIImage *) formatImage: (UIImage *) wallpaper{
    //Crop image to the max rect it can be
    float height = wallpaper.size.height;
    float width = (SCREEN_WIDTH * height)/SCREEN_HEIGHT;
    
    NSLog(@"height: %f, width: %f", height, width);
    
    
    
    if(wallpaper.size.width < width){
        width = wallpaper.size.width;
        height = (SCREEN_HEIGHT*width)/SCREEN_HEIGHT;
        NSLog(@"Width is the limiter. height: %f, width: %f", height, width);
    }
    
    float heightRatio = SCREEN_HEIGHT/height;
    UIImage *formattedImage = [self cropImage:wallpaper toRect:CGRectMake(0, 0, width*2, height*2)];
    
    return [self imageWithImage:formattedImage scaledToSize: CGSizeMake(width  * heightRatio * 2, height * heightRatio * 2)];
    
}

+ (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


+ (UIImage*) drawText:(NSString*) text inImage:(UIImage*)  image atPoint:(CGPoint)   point
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

+(UIImage*)MergeImage:(UIImage*)img1 withImage:(UIImage*)img2 atXLoc: (int) x atYLoc: (int) y
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
    
    //return value :)
    UIImage *returnedImage = [[UIImage alloc] initWithCGImage:result.CGImage scale:4.0 orientation:UIImageOrientationUp];
    return returnedImage;
}

+ (UIImage*) maskAndCropImage:(UIImage *)image withX: (float) x withY: (float) y withMask:(UIImage *)maskImage {
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

+(UIImage *)makeThumbnail:(UIImage *)image
{
    return [self cropImage:image toRect:CGRectMake(0, image.size.width/2, image.size.width, image.size.width)];
}
@end

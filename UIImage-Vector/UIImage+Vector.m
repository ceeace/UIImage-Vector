//
//  UIImage+Vector.m
//  UIImage+Vector
//
//  Created by David Keegan on 8/7/13.
//  Copyright (c) 2013 David Keegan All rights reserved.
//

#import "UIImage+Vector.h"
#import <CoreText/CoreText.h>

@implementation UIImage(Vector)

+ (NSCache *)cache{
    static NSCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSCache alloc] init];
    });
    return cache;
}

+ (instancetype)iconWithFont:(UIFont *)font named:(NSString *)iconNamed withTintColor:(UIColor *)tintColor clipToBounds:(BOOL)clipToBounds forSize:(CGFloat)fontSize{
    NSString *identifier = [NSString stringWithFormat:@"%@%@%@%@%d%f", NSStringFromSelector(_cmd), font.fontName, tintColor, iconNamed, clipToBounds, fontSize];
    UIImage *image = [[self cache] objectForKey:identifier];
    if(image == nil){
        NSMutableAttributedString *ligature = [[NSMutableAttributedString alloc] initWithString:iconNamed];
        [ligature setAttributes:@{(NSString *)kCTLigatureAttributeName: @(2),
                                  (NSString *)kCTFontAttributeName: font}
                          range:NSMakeRange(0, [ligature length])];

        CGSize imageSize = [ligature size];
        imageSize.width = ceil(imageSize.width);
        imageSize.height = ceil(imageSize.height);
        if(!CGSizeEqualToSize(CGSizeZero, imageSize)){
            UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
            [ligature drawAtPoint:CGPointZero];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            if(tintColor){
                UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextScaleCTM(context, 1, -1);
                CGContextTranslateCTM(context, 0, -imageSize.height);
                CGContextClipToMask(context, (CGRect){CGPointZero, imageSize}, [image CGImage]);
                [tintColor setFill];
                CGContextFillRect(context, (CGRect){CGPointZero, imageSize});
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }

            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wundeclared-selector"
            if(clipToBounds && [image respondsToSelector:@selector(imageClippedToPixelBounds)]){
                image = [image performSelector:@selector(imageClippedToPixelBounds)];
            }
            #pragma clang diagnostic pop

            [[self cache] setObject:image forKey:identifier];
        }
    }
    return image;
}


+ (instancetype)imageWithPDFNamed:(NSString *)name {
	return [self imageWithPDFNamed:name tintColor:nil height:0.0f];
}


+ (instancetype)imageWithPDFNamed:(NSString *)pdfNamed tintColor:(UIColor *)tintColor height:(CGFloat)height {
    NSURL *url = [[NSBundle mainBundle] URLForResource:pdfNamed withExtension:@"pdf"];
	return [self imageWithPDFURL:url tintColor:tintColor height:height];
}


+ (instancetype)imageWithPDFURL:(NSURL *)url tintColor:(UIColor *)tintColor height:(CGFloat)height {
	NSString *identifier = [NSString stringWithFormat:@"%@%@%@%f", NSStringFromSelector(_cmd), [url absoluteString], tintColor, height];
    UIImage *image = [[self cache] objectForKey:identifier];
    if (image){
        return image;
    }

	CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
    if (!pdf){
        return nil;
    }

	CGPDFPageRef page1 = CGPDFDocumentGetPage(pdf, 1);
    CGRect mediaRect = CGPDFPageGetBoxRect(page1, kCGPDFCropBox);
    CGSize imageSize = mediaRect.size;

	if (height > 0.0f) {
		imageSize.width += height / imageSize.height;
	}

    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGFloat scale = MIN(imageSize.width / mediaRect.size.width, imageSize.height / mediaRect.size.height);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -imageSize.height);
    CGContextScaleCTM(context, scale, scale);
    CGContextDrawPDFPage(context, page1);
    CGPDFDocumentRelease(pdf);
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    if(tintColor){
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -imageSize.height);
        CGContextClipToMask(context, (CGRect){CGPointZero, imageSize}, [image CGImage]);
        [tintColor setFill];
        CGContextFillRect(context, (CGRect){CGPointZero, imageSize});
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

    return image;
}

@end

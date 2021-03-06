//
//  UIImage+Vector.h
//  UIImage+Vector
//
//  Created by David Keegan on 8/7/13.
//  Copyright (c) 2013 David Keegan All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Vector)

/**
 Create a UIImage from an icon font.
 @param font The icon font.
 @param name The name of the icon in the font.
 @param tintColor The tint color to use for the icon. Defaults to black.
 @param clipToBounds If YES the image will be clipped to the pixel bounds of the icon.
 @param fontSize The font size to draw the icon at.
 @return The resulting image.
 */
+ (instancetype)iconWithFont:(UIFont *)font named:(NSString *)name
               withTintColor:(UIColor *)tintColor clipToBounds:(BOOL)clipToBounds forSize:(CGFloat)fontSize;

/**
 Create a UIImage from a PDF icon.
 @param name The name of the PDF file in the application's resources directory.
 @return The resulting image.
 */
+ (instancetype)imageWithPDFNamed:(NSString *)name;

/**
 Create a UIImage from a PDF icon.
 @param name The name of the PDF file in the application's resources directory.
 @param tintColor The tint color to use for the icon. If nil no tint color will be used.
 @param height The height of the resulting image, the width will be based on the aspect ratio of the PDF.
 @return The resulting image.
 */
+ (instancetype)imageWithPDFNamed:(NSString *)name tintColor:(UIColor *)tintColor height:(CGFloat)height;

+ (instancetype)imageWithPDFURL:(NSURL *)PDFURL tintColor:(UIColor *)tintColor height:(CGFloat)height;

@end

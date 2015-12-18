//
//  XKFastRawImageStore.h
//  XKFastRawImageStore
//
//  Created by Karl von Randow on 12/08/14.
//  Copyright (c) 2014 XK72 Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, XKFastRawImageStoreBitmapStyle) {
    
    /** The default setting. Use for high quality images with an alpha channel */
    XKFastRawImageStoreBitmapInfo32BitBGRA,
    
    /** The best for high quality images that don't require an alpha channel */
    XKFastRawImageStoreBitmapInfo32BitBGR,
    
    /** Use for smaller images where the colour fidelity isn't so important (and no alpha) */
    XKFastRawImageStoreBitmapInfo16BitBGR,
    
    /** For grayscale images */
    XKFastRawImageStoreBitmapInfo8BitGray,
};

extern NSString * const XKFastRawImageStoreErrorDomain;

NS_ENUM(NSInteger) {
    XKFastRawImageStoreErrorNoCGImage,
    XKFastRawImageStoreErrorAllocateFailed,
    XKFastRawImageStoreErrorBitmapContextFailed
};

@interface XKFastRawImageStore : NSObject

/** The bitmap style of the images to write. See the XKFastRawImageStoreBitmapStyle enum for details. */
@property (readwrite, nonatomic) XKFastRawImageStoreBitmapStyle bitmapStyle;
/** The row alignment. The default is the best for Core Animation. Probably don't change. */
@property (readwrite, nonatomic) size_t alignment;

/** The background color to use when the output format doesn't support alpha. If you write an
    image containing alpha to a bitmap style that doesn't include alpha, it will be rendered
    on the background color. Alpha components in the background color may cause unexpected results.
    Defaults to white.
 */
@property (strong, nonatomic) UIColor *backgroundColor;

/** The bitmap info that will be used for the current bitmapStyle */
@property (readonly, nonatomic) CGBitmapInfo bitmapInfo;
/** The bits per component that will be used for the current bitmapStyle */
@property (readonly, nonatomic) size_t bitsPerComponent;
/** The bits per pixel that will be used for the current bitmapStyle */
@property (readonly, nonatomic) size_t bitsPerPixel;
/** The bytes per pixel that will be used for the current bitmapStyle */
@property (readonly, nonatomic) size_t bytesPerPixel;


/** Read an image that was previously written using this class, and use the given scale.
    Returns nil if the image doesn't exist or can't be read.
 */
- (UIImage *)imageForPath:(NSString *)path scale:(CGFloat)scale;

/** Write an image to the given path. Uses the size and scale of the image. */
- (BOOL)writeImage:(UIImage *)image toPath:(NSString *)path error:(NSError * __autoreleasing *)error;

/** Write an image to the given path, with the given size and scale.
    The pixel size of the image written to disk will be size * scale.
    The image will be scaled, if necessary, to the given size.
 */
- (BOOL)writeImage:(UIImage *)image size:(const CGSize)size scale:(const CGFloat)scale toPath:(NSString *)path error:(NSError * __autoreleasing *)error;

/** Write an image to the given path, with the given width and height in pixels.
    The image will be scaled, if necessary, to the given pixel size.
 */
- (BOOL)writeImage:(UIImage * const)image width:(const size_t)width height:(const size_t)height toPath:(NSString * const)path error:(NSError * __autoreleasing *)error;

/** Returns the default base path where you might store images written using this class.
    This returns the path of the `Library/Caches` directory for the current application.
 */
+ (NSString *)defaultBasePath;

@end

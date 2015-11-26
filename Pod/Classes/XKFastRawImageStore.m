//
//  XKFastRawImageStore.m
//  XKFastRawImageStore
//
//  Created by Karl von Randow on 12/08/14.
//  Copyright (c) 2014 XK72 Ltd. All rights reserved.
//

#import "XKFastRawImageStore.h"

u_int8_t XKFastRawImageStoreCurrentTrailerVersion = 1;

typedef struct {
    size_t width;
    size_t height;
    size_t bytesPerRow;
    size_t bitsPerComponent;
    size_t bitsPerPixel;
    CGBitmapInfo bitmapInfo;
    
    /* Always last, as we find the trailer from the end of the file, so we have to have the version
     at the end of the struct as that's the only known position if the struct may have changed.
     */
    u_int8_t version;
} XKFastRawImageStoreTrailer;

#pragma mark - Helper functions

static inline size_t XKFIDCAlign(size_t width, size_t alignment) {
    size_t result = width + (alignment - width % alignment);
    return result;
}

static void _XKFIDCReleaseImageData(void *info, const void *data, size_t size) {
    if (info) {
        CFRelease(info);
    }
}

#pragma mark -

@implementation XKFastRawImageStore {
    CGColorSpaceRef _colorSpace;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _alignment = 64; /* For Core Animation */
        
        self.bitmapStyle = XKFastRawImageStoreBitmapInfo32BitBGRA;
        
        _colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    return self;
}

- (void)dealloc
{
    CGColorSpaceRelease(_colorSpace);
}

#pragma mark - Public

- (UIImage *)imageForPath:(NSString *)path scale:(CGFloat)scale
{
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedAlways error:&error];
    if (!data) {
        if (error) {
            if ([[error domain] isEqualToString:NSCocoaErrorDomain] && (error.code == NSFileNoSuchFileError || error.code == NSFileReadNoSuchFileError)) {
                return nil;
            } else {
                /* Consider reporting this error */
            }
        }
        return nil;
    }
    
    NSUInteger length = data.length;
    NSUInteger imageLength = length - sizeof(XKFastRawImageStoreTrailer);
    void *bytes = (void *) [data bytes];
    XKFastRawImageStoreTrailer *trailer = (XKFastRawImageStoreTrailer *) (bytes + length - sizeof(XKFastRawImageStoreTrailer));
    if (trailer->version != XKFastRawImageStoreCurrentTrailerVersion) {
        return nil;
    }
    
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData((__bridge_retained void *)data, bytes, imageLength, _XKFIDCReleaseImageData);
    
    CGImageRef cgImage = CGImageCreate(trailer->width, trailer->height, trailer->bitsPerComponent, trailer->bitsPerPixel, trailer->bytesPerRow, _colorSpace, trailer->bitmapInfo, dataProvider, NULL, false, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    if (cgImage == NULL) {
        return nil;
    }
    
    UIImage *result = [UIImage imageWithCGImage:cgImage scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    return result;
}

- (BOOL)writeImage:(UIImage *)image toPath:(NSString *)path error:(NSError **)error
{
    return [self writeImage:image size:image.size scale:image.scale toPath:path error:error];
}

- (BOOL)writeImage:(UIImage *)image size:(const CGSize)size scale:(const CGFloat)scale toPath:(NSString *)path error:(NSError **)error
{
    const CGImageRef cgImage = [image CGImage];
    if (!cgImage) {
        return NO;
    }
    
    const size_t width = size.width * scale;
    const size_t height = size.height * scale;
    const size_t bytesPerRow = XKFIDCAlign(width * _bytesPerPixel, _alignment);
    
    const size_t length = bytesPerRow * height + sizeof(XKFastRawImageStoreTrailer);
    void *bytes = malloc(length);
    if (bytes == NULL) {
        return NO;
    }
    
    XKFastRawImageStoreTrailer *trailer = (XKFastRawImageStoreTrailer *) (bytes + length - sizeof(XKFastRawImageStoreTrailer));
    trailer->version = XKFastRawImageStoreCurrentTrailerVersion;
    trailer->width = width;
    trailer->height = height;
    trailer->bytesPerRow = bytesPerRow;
    trailer->bitsPerComponent = _bitsPerComponent;
    trailer->bitsPerPixel = _bitsPerPixel;
    trailer->bitmapInfo = _bitmapInfo;
    
    CGContextRef ctx = CGBitmapContextCreate(bytes, width, height, _bitsPerComponent, bytesPerRow, _colorSpace, _bitmapInfo);
    if (!ctx) {
        return NO;
    }
    
    CGRect r = (CGRect) { CGPointZero, { width, height }};
    CGContextDrawImage(ctx, r, cgImage);
    
    CGContextRelease(ctx);
    
    NSData *data = [NSData dataWithBytesNoCopy:bytes length:length freeWhenDone:YES];
    
    return [data writeToFile:path options:NSDataWritingAtomic error:error];
}

#pragma mark Properties

- (void)setBitmapStyle:(XKFastRawImageStoreBitmapStyle)bitmapStyle
{
    switch (bitmapStyle) {
        case XKFastRawImageStoreBitmapInfo32BitBGRA:
            _bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
            _bitsPerComponent = 8;
            _bytesPerPixel = 4;
            break;
            
        case XKFastRawImageStoreBitmapInfo32BitBGR:
            _bitmapInfo = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host;
            _bitsPerComponent = 8;
            _bytesPerPixel = 4;
            break;
            
        case XKFastRawImageStoreBitmapInfo16BitBGR:
            _bitmapInfo = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder16Host;
            _bitsPerComponent = 5;
            _bytesPerPixel = 2;
            break;
            
        case XKFastRawImageStoreBitmapInfo8BitGray:
            _bitmapInfo = (CGBitmapInfo)kCGImageAlphaNone;
            _bitsPerComponent = 8;
            _bytesPerPixel = 1;
            break;
    }
    
    _bitsPerPixel = _bytesPerPixel * 8;
}

#pragma mark Utilities

+ (NSString *)defaultBasePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if (paths.count) {
        return paths[0];
    } else {
        return nil;
    }
}

@end

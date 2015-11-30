//
//  XKViewController.m
//  XKFastRawImageStore
//
//  Created by Karl von Randow on 11/27/2015.
//  Copyright (c) 2015 XK72 Ltd. All rights reserved.
//

#import "XKViewController.h"

#import <XKFastRawImageStore/XKFastRawImageStore.h>

@interface XKViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation XKViewController {
    
    XKFastRawImageStore *_imageStore;
    NSString *_basePath;
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _imageStore = [XKFastRawImageStore new];
        _imageStore.bitmapStyle = XKFastRawImageStoreBitmapInfo16BitBGR;
        _imageStore.backgroundColor = [UIColor purpleColor];
        
        _basePath = [[XKFastRawImageStore defaultBasePath] stringByAppendingPathComponent:@"fastimages"];
        
        /* Ensure the directory exists where we want to store the images */
        [[NSFileManager defaultManager] createDirectoryAtPath:_basePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *image = [self loadImage:@"66"];
    self.imageView.image = image;
}

#pragma mark - Private

- (UIImage *)loadImage:(NSString *)named
{
    NSString * const path = [_basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.raw", named]];
    
    /* Try to load existing cached raw image */
    UIImage * result = [_imageStore imageForPath:path scale:self.traitCollection.displayScale];
    if (result) {
        /* But don't use it in this case so we can test different configuration */
//        return result;
    }
    
    /* Generate the raw image */
    UIImage *image = [UIImage imageNamed:named];
    if (!image) {
        return nil;
    }
    
    NSError *error = nil;
    if (![_imageStore writeImage:image toPath:path error:&error]) {
        NSLog(@"Failed to write raw image (%@): %@", named, [error localizedDescription]);
        return nil;
    }
    
    /* Return the newly generated raw image */
    return [_imageStore imageForPath:path scale:self.traitCollection.displayScale];
}

@end

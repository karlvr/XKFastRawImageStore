//
//  XKFastRawImageStoreTests.m
//  XKFastRawImageStoreTests
//
//  Created by Karl von Randow on 11/27/2015.
//  Copyright (c) 2015 Karl von Randow. All rights reserved.
//

// https://github.com/Specta/Specta

@import XKFastRawImageStore;
@import UIKit;


SpecBegin(InitialSpecs)

describe(@"write images", ^{
    
    it(@"can write an image", ^{
        UIImage *image = [UIImage imageNamed:@"67"];
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.raw"];
        
        XKFastRawImageStore *imageStore = [XKFastRawImageStore new];
        BOOL result = [imageStore writeImage:image toPath:path error:nil];
        
        expect(result).to.equal(YES);
    });
    
    it(@"can read an image", ^{
        UIImage *image = [UIImage imageNamed:@"67"];
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.raw"];
        
        XKFastRawImageStore *imageStore = [XKFastRawImageStore new];
        BOOL result = [imageStore writeImage:image toPath:path error:nil];
        
        expect(result).to.equal(YES);
        
        UIImage *read = [imageStore imageForPath:path scale:1];
        expect(read).toNot.equal(nil);
        
        expect(read.scale).to.equal(1.0);
        expect(read.size.width).to.equal(image.size.width * image.scale);
        expect(read.size.height).to.equal(image.size.height * image.scale);
        expect(read.size.width).toNot.equal(0);
        expect(read.size.height).toNot.equal(0);
    });
    
    it(@"can resize an image", ^{
        UIImage *image = [UIImage imageNamed:@"67"];
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.raw"];
        
        XKFastRawImageStore *imageStore = [XKFastRawImageStore new];
        BOOL result = [imageStore writeImage:image width:32 height:32 toPath:path error:nil];
        
        expect(result).to.equal(YES);
        
        UIImage *read = [imageStore imageForPath:path scale:1];
        expect(read).toNot.equal(nil);
        
        expect(read.scale).to.equal(1.0);
        expect(read.size.width).to.equal(32);
        expect(read.size.height).to.equal(32);
    });
    
});

SpecEnd


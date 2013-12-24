//
//  VFDVideoReader.m
//  VideoFaceDetection
//
//  Created by 西山 勇世 on 2013/12/24.
//  Copyright (c) 2013年 Yusei Nishiyama. All rights reserved.
//

#import "VFDVideoReader.h"

#import <AVFoundation/AVFoundation.h>

@interface VFDVideoReader ()
@property (nonatomic, copy) VFDVideoReaderCompletionHandler completionHandler;
@end

@implementation VFDVideoReader {
    AVAsset *_asset;
    CIDetector *_detector;
    NSMutableArray *_allFeatures;
}

- (id)init
{
    if (self = [super init]) {
        _allFeatures = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)readFromURL:(NSURL *)targetURL
  complitionHandler:(VFDVideoReaderCompletionHandler)completionHandler
{
    self.completionHandler = completionHandler;
    [self _setupDetector];
    __weak VFDVideoReader *weakSelf = self;
    _asset = [AVAsset assetWithURL:targetURL];
    [_asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        [weakSelf _startReading];
    }];
}

- (void)_setupDetector
{
    CIContext *context = [CIContext contextWithOptions:nil];
    NSDictionary *detectorOptions = @{CIDetectorAccuracy : CIDetectorAccuracyHigh};
    _detector = [CIDetector detectorOfType:CIDetectorTypeFace context:context options:detectorOptions];
}

- (void)_startReading
{
    AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:_asset error:nil];
    NSDictionary *outputSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]};
    AVAssetReaderTrackOutput *output = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:[_asset tracksWithMediaType:AVMediaTypeVideo][0]
                                                                                  outputSettings:outputSettings];
    [reader addOutput:output];
    [reader startReading];
    while ([reader status] == AVAssetReaderStatusReading) {
        [self _readNextVideoFrame:[output copyNextSampleBuffer]];
    }
    [self _endReading];
}

- (void)_endReading
{
    _completionHandler(_allFeatures);
}

- (void)_readNextVideoFrame:(CMSampleBufferRef)sampleBuffer
{
    if (!sampleBuffer) return;
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	CIImage *convertedImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
	if (attachments)
		CFRelease(attachments);
    
    enum {
		PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
		PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
		PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
		PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
		PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
		PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
	};
    
    NSDictionary *options = @{CIDetectorImageOrientation : [NSNumber numberWithInt:PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP]};
    NSArray *features = [_detector featuresInImage:convertedImage options:options];
    [features enumerateObjectsUsingBlock:^(CIFaceFeature *feature, NSUInteger idx, BOOL *stop) {
        NSLog(@"%@", NSStringFromCGRect([feature bounds]));
    }];
    [_allFeatures addObject:features];
    CFRelease(sampleBuffer);
}

@end

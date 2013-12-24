//
//  VFDVideoReader.m
//  VideoFaceDetection
//
//  Created by 西山 勇世 on 2013/12/24.
//  Copyright (c) 2013年 Yusei Nishiyama. All rights reserved.
//

#import "VFDVideoReader.h"

#import <AVFoundation/AVFoundation.h>

@implementation VFDVideoReader {
    AVAsset *_asset;
    CIDetector *_detector;
}

- (void)readFromURL:(NSURL *)targetURL
{
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
    
    //NSDictionary *imageOptions =
	//imageOptions = [NSDictionary dictionaryWithObject:nil forKey:CIDetectorImageOrientation];
    
    NSLog(@"Face Detector %@", [_detector description]);
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
}

- (void)_readNextVideoFrame:(CMSampleBufferRef)sampleBuffer
{
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	CIImage *convertedImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
    
	if (attachments)
		CFRelease(attachments);
	
    NSLog(@"converted Image %@", [convertedImage description]);
    NSArray *features = [_detector featuresInImage:convertedImage options:nil];
    NSLog(@"%@", features);
}

@end

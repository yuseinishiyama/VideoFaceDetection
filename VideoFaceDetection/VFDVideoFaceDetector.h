//
//  VFDVideoReader.h
//  VideoFaceDetection
//
//  Created by 西山 勇世 on 2013/12/24.
//  Copyright (c) 2013年 Yusei Nishiyama. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^VFDVideoReaderCompletionHandler)(NSArray *allFeatures);

@interface VFDVideoFaceDetector : NSObject
- (void)readFromURL:(NSURL *)targetURL
  complitionHandler:(VFDVideoReaderCompletionHandler)completionHandler;
@end

//
//  VFDProgressViewController.m
//  VideoFaceDetection
//
//  Created by 西山 勇世 on 2013/12/24.
//  Copyright (c) 2013年 Yusei Nishiyama. All rights reserved.
//

#import "VFDProgressViewController.h"

#import "VFDVideoReader.h"

@interface VFDProgressViewController ()

@end

@implementation VFDProgressViewController
{
    VFDVideoReader *_reader;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self _startProcessing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_startProcessing
{
    _reader = [[VFDVideoReader alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [_reader readFromURL:_targetURL];
    });
}

@end

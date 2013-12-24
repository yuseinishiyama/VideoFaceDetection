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
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
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
}

- (void)_startProcessing
{
    [_indicator startAnimating];
    [_statusLabel setText:@"Now Detecting..."];
    
    __weak VFDProgressViewController *weakSelf = self;
    
    _reader = [[VFDVideoReader alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [_reader readFromURL:_targetURL complitionHandler:^(NSArray *allFeatures) {
            [weakSelf _endProcessing:allFeatures];
        }];
    });
}

- (void)_endProcessing:(NSArray *)allFeatures
{
    [_indicator stopAnimating];
    [_statusLabel setText:@"Finish"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Finish"
                                                    message:[allFeatures description]
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    [alert show];
}

@end

//
//  VFDViewController.m
//  VideoFaceDetection
//
//  Created by 西山 勇世 on 2013/12/24.
//  Copyright (c) 2013年 Yusei Nishiyama. All rights reserved.
//

#import "VFDTopViewController.h"

#import "VFDProgressViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>

@interface VFDTopViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation VFDTopViewController {
    NSURL *_targetURL;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)onSelectVideoTapped:(id)sender
{
    [self _showImagePicker];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    VFDProgressViewController *destinationViewController = [segue destinationViewController];
    destinationViewController.targetURL = _targetURL;
}

- (void)_showImagePicker
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setDelegate:self];
    [imagePicker setMediaTypes:@[(NSString *)kUTTypeMovie]];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _targetURL = info[UIImagePickerControllerMediaURL];
    __weak VFDTopViewController *weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf performSegueWithIdentifier:@"progress" sender:self];
    }];
}

@end

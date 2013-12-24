//
//  VFDViewController.m
//  VideoFaceDetection
//
//  Created by 西山 勇世 on 2013/12/24.
//  Copyright (c) 2013年 Yusei Nishiyama. All rights reserved.
//

#import "VFDViewController.h"

#import "VFDProgressViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>

@interface VFDViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation VFDViewController {
    NSURL *_targetURL;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)showImagePicker
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setDelegate:self];
    [imagePicker setMediaTypes:@[(NSString *)kUTTypeMovie]];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSelectVideoTapped:(id)sender
{
    [self showImagePicker];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _targetURL = info[UIImagePickerControllerMediaURL];
    __weak VFDViewController *weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf performSegueWithIdentifier:@"progress" sender:self];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    VFDProgressViewController *destinationViewController = [segue destinationViewController];
    destinationViewController.targetURL = _targetURL;
}

@end

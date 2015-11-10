//
//  MCAProductImageVC.m
//  assignment
//
//  Created by Amr Aboelela on 4/29/14.
//  Copyright (c) 2014 Macys. All rights reserved.
//

#import "MCAProductImageVC.h"
#import "MCAThemeUtils.h"

@implementation MCAProductImageVC

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [MCAThemeUtils fixNavbarIssue:self];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(close:)];
    [self updateView];
}

#pragma mark - Actions

- (void)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Utils

- (void)updateView
{
    self.title = self.product.name;
    self.photo.image = [UIImage imageNamed:self.product.photoName];
}

@end

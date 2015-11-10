//
//  MCADetailViewController.m
//  assignment
//
//  Created by Amr Aboelela on 4/29/14.
//  Copyright (c) 2014 Macys. All rights reserved.
//

#import "MCAProductDetailVC.h"
#import "MCAThemeUtils.h"
#import "MCAProductImageVC.h"
#import "MCAEditProductVC.h"

@implementation MCAProductDetailVC

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [MCAThemeUtils fixNavbarIssue:self];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Update"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(update:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateView];
}

#pragma mark - Actions

- (void)update:(id)sender
{
    MCAEditProductVC *vc = [[MCAEditProductVC alloc] init];
    vc.product = self.product;
    [self.navigationController presentViewControllerInNavigationController:vc];
}

- (IBAction)photoClicked:(id)sender
{
    MCAProductImageVC *vc = [[MCAProductImageVC alloc] init];
    vc.product = self.product;
    [self.navigationController presentViewControllerInNavigationController:vc];
}

- (IBAction)deleteProduct:(id)sender
{
    [MCAProduct deleteProductWithID:self.product.ID];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Utils

- (void)updateView
{
    self.title = self.product.name;
    self.descriptionLabel.text = self.product.productDescription;
    self.regularPriceLabel.text = [NSString stringWithFormat:@"$%0.2f", self.product.regularPrice];
    self.salePriceLabel.text = [NSString stringWithFormat:@"$%0.2f", self.product.salePrice];
    self.colorsLabel.text = [self.product.colors componentsJoinedByString:@", "];
    self.storesLabel.text = [self.product.stores[@"names"] componentsJoinedByString:@", "];
    [self.photoButton setImage:[UIImage imageNamed:self.product.photoName] forState:UIControlStateNormal];
}

@end

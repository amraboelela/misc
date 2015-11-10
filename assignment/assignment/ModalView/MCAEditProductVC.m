//
//  MCAEditProductVC.m
//  assignment
//
//  Created by Amr Aboelela on 4/29/14.
//  Copyright (c) 2014 Macys. All rights reserved.
//

#import "MCAEditProductVC.h"
#import "MCAThemeUtils.h"

@implementation MCAEditProductVC

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [MCAThemeUtils fixNavbarIssue:self];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(save:)];
    self.title = self.product.name;
    [self loadData];
}

#pragma mark - Data

- (void)loadData
{
    self.nameTextField.text = self.product.name;
    self.descriptionTextField.text = self.product.productDescription;
    self.regularPriceTextField.text = [NSString stringWithFormat:@"%0.2f", self.product.regularPrice];
    self.salesPriceTextField.text = [NSString stringWithFormat:@"%0.2f", self.product.salePrice];
    self.colorsTextField.text = [self.product.colors componentsJoinedByString:@", "];
    self.storesTextField.text = [self.product.stores[@"names"] componentsJoinedByString:@", "];
}

#pragma mark - Actions

- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)save:(id)sender
{
    self.product.name = self.nameTextField.text;
    self.product.productDescription = self.descriptionTextField.text;
    self.product.regularPrice = [self.regularPriceTextField.text floatValue];
    self.product.salePrice = [self.salesPriceTextField.text floatValue];
    self.product.colors = [self.colorsTextField.text componentsSeparatedByString:@", "];
    self.product.stores[@"names"] = [self.storesTextField.text componentsSeparatedByString:@", "];
    [self.product saveToDB];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

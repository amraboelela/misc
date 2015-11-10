//
//  MCAMasterViewController.m
//  assignment
//
//  Created by Amr Aboelela on 4/29/14.
//  Copyright (c) 2014 Macys. All rights reserved.
//

#import "MCAProductListVC.h"
#import "MCAProductDetailVC.h"
#import "MCAProduct.h"
#import "MCAProductCell.h"
#import "MCAProductDetailVC.h"

static NSString *cellIdentifier = @"Cell";

@interface MCAProductListVC ()

@property (nonatomic) NSArray *products;
@property (nonatomic) UIBarButtonItem *addButton;

@end

@implementation MCAProductListVC

#pragma mark - Life cycle

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                   target:self
                                                                   action:@selector(addProduct:)];
    self.navigationItem.rightBarButtonItem = self.addButton;
    [[self tableView] registerNib:[UINib nibWithNibName:@"MCAProductCell" bundle:nil]
           forCellReuseIdentifier:cellIdentifier];
    self.title = @"Products";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateView];
}

#pragma mark - Data

- (void)loadData
{
    self.products = [MCAProduct getAllDBProducts];
}

- (void)addProduct:(id)sender
{
    NSArray *allJsonProducts = [MCAProduct getAllJsonProducts];
    if (self.products.count < allJsonProducts.count) {
        for (MCAProduct *product in allJsonProducts) {
            if ([product addToDB] == SQLITE_DONE) {
                break;
            }
        }
        [self updateView];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCAProductCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    NSDictionary *product = self.products[indexPath.row];
    cell.nameLabel.text = product[@"name"];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [MCAProduct deleteProductWithID:self.products[indexPath.row][@"ID"]];
        [self updateView];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCAProductDetailVC *vc = [[MCAProductDetailVC alloc] init];
    vc.product = [MCAProduct getProductWithID:self.products[indexPath.row][@"ID"]];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Utilties

- (void)updateView
{
    [self loadData];
    [self.tableView reloadData];
    NSArray *allJsonProducts = [MCAProduct getAllJsonProducts];
    if (self.products.count < allJsonProducts.count) {
        self.addButton.enabled = YES;
    } else {
        self.addButton.enabled = NO;
    }
}

@end

//
//  MCADetailViewController.h
//  assignment
//
//  Created by Amr Aboelela on 4/29/14.
//  Copyright (c) 2014 Macys. All rights reserved.
//

#import "MCAProduct.h"

@interface MCAProductDetailVC : UIViewController

@property (nonatomic) MCAProduct *product;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *regularPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *salePriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *colorsLabel;
@property (weak, nonatomic) IBOutlet UILabel *storesLabel;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;

@end

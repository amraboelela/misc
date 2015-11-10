//
//  MCAEditProductVC.h
//  assignment
//
//  Created by Amr Aboelela on 4/29/14.
//  Copyright (c) 2014 Macys. All rights reserved.
//

#import "MCAProduct.h"

@interface MCAEditProductVC : UIViewController

@property (nonatomic) MCAProduct *product;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UITextField *regularPriceTextField;
@property (weak, nonatomic) IBOutlet UITextField *salesPriceTextField;
@property (weak, nonatomic) IBOutlet UITextField *colorsTextField;
@property (weak, nonatomic) IBOutlet UITextField *storesTextField;

@end

//
//  MCAProductImageVC.h
//  assignment
//
//  Created by Amr Aboelela on 4/29/14.
//  Copyright (c) 2014 Macys. All rights reserved.
//

#import "MCAProduct.h"

@interface MCAProductImageVC : UIViewController

@property (nonatomic) MCAProduct *product;
@property (weak, nonatomic) IBOutlet UIImageView *photo;

@end

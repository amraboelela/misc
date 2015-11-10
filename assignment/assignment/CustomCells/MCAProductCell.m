//
//  MCAProductCell.m
//  assignment
//
//  Created by Amr Aboelela on 4/29/14.
//  Copyright (c) 2014 Macys. All rights reserved.
//

#import "MCAProductCell.h"

@interface MCAProductCell ()

@end

@implementation MCAProductCell

#pragma mark - Life cycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

@end

//
//  MCAThemeUtils.m
//  assignment
//
//  Created by Amr Aboelela on 4/29/14.
//  Copyright (c) 2014 Macys. All rights reserved.
//

#import "MCAThemeUtils.h"

@interface MCAThemeUtils ()

@end

@implementation MCAThemeUtils

+ (BOOL)isOS7
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        return NO;
    } else {
        return YES;
    }
    
}

+ (void)fixNavbarIssue:(UIViewController *)vc
{
    if ([MCAThemeUtils isOS7]) {
        vc.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

@end

//
//  NSDictionary+MCA.m
//  assignment
//
//  Created by Amr Aboelela on 4/29/14.
//  Copyright (c) 2014 Macys. All rights reserved.
//

#import "NSDictionary+MCA.h"

@implementation NSDictionary (MCA)

+ (NSMutableDictionary *)dictionaryFromJSONString:(NSString *)string
{
    return [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding]
                                           options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                             error:NULL];
}

- (NSString *)jsonString
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:NULL];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end

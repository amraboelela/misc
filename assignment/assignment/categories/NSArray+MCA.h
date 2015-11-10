//
//  NSArray+MCA.h
//  assignment
//
//  Created by Amr Aboelela on 4/29/14.
//  Copyright (c) 2014 Macys. All rights reserved.
//

@interface NSArray (MCA)

+ (NSMutableArray *)arrayFromJSONString:(NSString *)string;
- (NSString *)jsonString;

@end

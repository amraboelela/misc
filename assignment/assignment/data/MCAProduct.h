//
//  MCAProduct.h
//  assignment
//
//  Created by Amr Aboelela on 4/29/14.
//  Copyright (c) 2014 Macys. All rights reserved.
//

#import <sqlite3.h>

@interface MCAProduct : NSObject

@property (nonatomic) NSString *ID;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *productDescription;
@property (nonatomic) float regularPrice;
@property (nonatomic) float salePrice;
@property (nonatomic) NSString *photoName;
@property (nonatomic) NSArray *colors;
@property (nonatomic) NSMutableDictionary *stores;

+ (NSArray *)getAllJsonProducts;
+ (BOOL)deleteProductWithID:(NSString *)ID;
+ (NSArray *)getAllDBProducts;
+ (MCAProduct *)getProductWithID:(NSString *)ID;

- (int)addToDB;
- (BOOL)saveToDB;

@end

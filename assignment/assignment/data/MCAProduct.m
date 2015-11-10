//
//  MCADetailViewController.m
//  assignment
//
//  Created by Amr Aboelela on 4/29/14.
//  Copyright (c) 2014 Macys. All rights reserved.
//

#import "MCAProduct.h"
#import "MCADBManager.h"
#import "NSDictionary+MCA.h"
#import "NSArray+MCA.h"

@interface MCAProduct ()

@end

@implementation MCAProduct

#pragma mark - Accessors

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; ID: %@; name: %@; productDescription: %@; regularPrice: %0.2f; salePrice: %0.2f; photoName: %@; colors: %@; stores: %@>", [self class], self, _ID, _name, _productDescription, _regularPrice, _salePrice, _photoName, _colors, _stores];
}

#pragma mark - Class methods

+ (NSArray *)getAllJsonProducts
{
    static NSArray *products = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:dataPath];
        NSArray *rawProducts = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
        NSMutableArray *mutableProducts = [NSMutableArray arrayWithCapacity:10];
        for (NSDictionary *product in rawProducts) {
            MCAProduct *mcaProduct = [[self alloc] init];
            mcaProduct.ID = product[@"ID"];
            mcaProduct.name = product[@"name"];
            mcaProduct.productDescription = product[@"description"];
            mcaProduct.regularPrice = [product[@"regularPrice"] floatValue];
            mcaProduct.salePrice = [product[@"salePrice"] floatValue];
            mcaProduct.photoName = product[@"photoName"];
            mcaProduct.colors = product[@"colors"];
            mcaProduct.stores = product[@"stores"];
            [mutableProducts addObject:mcaProduct];
        }
        products = [NSArray arrayWithArray:mutableProducts];
    });
    return products;
}

+ (BOOL)deleteProductWithID:(NSString *)ID
{
    BOOL result = NO;
    sqlite3_stmt *statement;
    MCADBManager *dbManager = [MCADBManager sharedInstance];
    sqlite3 *database = dbManager.database;
    const char *dbpath = [dbManager.databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *sqlString = [NSString stringWithFormat:@"delete from product where ID=\"%@\"",ID];
        const char *insert_stmt = [sqlString UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        int sqlResult = sqlite3_step(statement);
        DLog(@"sqlite3_step sqlResult: %d", sqlResult);
        if (sqlResult == SQLITE_DONE) {
            result = YES;
        }
        sqlite3_reset(statement);
        sqlite3_close(database);
    }
    return result;
}

+ (NSArray *)getAllDBProducts
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    sqlite3_stmt *statement;
    MCADBManager *dbManager = [MCADBManager sharedInstance];
    sqlite3 *database = dbManager.database;
    const char *dbpath = [dbManager.databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:@"select ID, name from product"];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                NSMutableDictionary *product = [NSMutableDictionary dictionaryWithCapacity:2];
                product[@"ID"] = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                product[@"name"] = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                [resultArray addObject:product];
            }
        }
        sqlite3_reset(statement);
        sqlite3_close(database);
    }
    return resultArray;
}

+ (MCAProduct *)getProductWithID:(NSString *)ID
{
    MCAProduct *product = nil;
    sqlite3_stmt *statement;
    MCADBManager *dbManager = [MCADBManager sharedInstance];
    sqlite3 *database = dbManager.database;
    const char *dbpath = [dbManager.databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:@"select ID, name, description, regularPrice, salePrice, photoName, colors, stores from product where ID=\"%@\"",ID];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                product = [[MCAProduct alloc] init];
                product.ID = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                product.name = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                product.productDescription = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                product.regularPrice = sqlite3_column_double(statement, 3);
                product.salePrice = sqlite3_column_double(statement, 4);
                product.photoName = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
                product.colors = [NSArray arrayFromJSONString:
                                  [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 6)]];
                product.stores = [NSMutableDictionary dictionaryFromJSONString:
                                  [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 7)]];
            } else {
                NSLog(@"Not found");
            }
        }
        sqlite3_reset(statement);
        sqlite3_close(database);
    }
    return product;
}

#pragma mark - Data

- (int)addToDB
{
    int result = SQLITE_OK;
    sqlite3_stmt *statement;
    MCADBManager *dbManager = [MCADBManager sharedInstance];
    sqlite3 *database = dbManager.database;
    const char *dbpath = [dbManager.databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into product(ID, name, description, regularPrice, salePrice, photoName, colors, stores) values (\"%@\",\"%@\",\"%@\",\"%0.2f\",\"%0.2f\",\"%@\",'%@','%@')",self.ID,self.name,self.productDescription,self.regularPrice,self.salePrice,self.photoName,[self.colors jsonString],[self.stores jsonString]];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        result = sqlite3_step(statement);
        DLog(@"sqlite3_step result: %d", result);
        sqlite3_reset(statement);
        sqlite3_close(database);
    }
    return result;
}

- (BOOL)saveToDB
{
    BOOL result = NO;
    sqlite3_stmt *statement;
    MCADBManager *dbManager = [MCADBManager sharedInstance];
    sqlite3 *database = dbManager.database;
    const char *dbpath = [dbManager.databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        const char *sql = [[NSString stringWithFormat:@"update product Set name = ?, description = ?, regularPrice = ?, salePrice = ?, colors = ?, stores = ? Where ID = %@", self.ID] UTF8String];
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSLog(@"Error while creating update statement. %s", sqlite3_errmsg(database));
        }
    }
    sqlite3_bind_text(statement, 1, [self.name  UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 2, [self.productDescription  UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 3, [[NSString stringWithFormat:@"%0.2f", self.regularPrice] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 4, [[NSString stringWithFormat:@"%0.2f", self.salePrice] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 5, [[self.colors jsonString] UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 6, [[self.stores jsonString] UTF8String], -1, SQLITE_TRANSIENT);
    char *errmsg;
    sqlite3_exec(database, "COMMIT", NULL, NULL, &errmsg);
    if (sqlite3_step(statement) == SQLITE_DONE) {
        result = YES;
    } else {
        NSLog(@"Error while updating. %s", sqlite3_errmsg(database));
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    return result;
}

@end

//
//  MCADBManager.m
//  assignment
//
//  Created by Amr Aboelela on 4/29/14.
//  Copyright (c) 2014 Macys. All rights reserved.
//

#import "MCADBManager.h"

@implementation MCADBManager

#pragma Mark - Class methods

+ (MCADBManager *)sharedInstance
{
    static MCADBManager *_sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
            _sharedInstance = [[self alloc] init];
            [_sharedInstance createDB];
    });
    return _sharedInstance;
}

#pragma Mark - Acessors

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; database: %@; databasePath: %@>", [self class], self, self.database, self.databasePath];
}

#pragma Mark - Utilities

- (BOOL)createDB
{
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    self.databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"data.db"]];
    BOOL isSuccess = YES;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    const char *dbpath = [self.databasePath UTF8String];
    if (![fileManager fileExistsAtPath:self.databasePath]) {
        if (sqlite3_open(dbpath, &_database) == SQLITE_OK) {
            char *errMsg;
            const char *sql_stmt = "create table if not exists product (ID text primary key, name text, description text, regularPrice double, salePrice double, photoName text, colors text, stores text)";
            if (sqlite3_exec(self.database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            sqlite3_close(self.database);
            return isSuccess;
        } else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    if (sqlite3_open(dbpath, &_database) != SQLITE_OK) {
        isSuccess = NO;
        NSLog(@"Failed to open/create database");
    }
    return isSuccess;
}

@end

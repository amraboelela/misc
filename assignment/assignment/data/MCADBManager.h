//
//  MCADBManager.h
//  assignment
//
//  Created by Amr Aboelela on 4/29/14.
//  Copyright (c) 2014 Macys. All rights reserved.
//

#import "MCAProduct.h"
#import <sqlite3.h>

@interface MCADBManager : NSObject

@property (nonatomic) sqlite3 *database;
@property (nonatomic) NSString *databasePath;

+ (MCADBManager *)sharedInstance;
- (BOOL)createDB;

@end

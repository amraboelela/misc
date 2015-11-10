//
//  assignmentTests.m
//  assignmentTests
//
//  Created by Amr Aboelela on 4/29/14.
//  Copyright (c) 2014 Macys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCAProduct.h"
#import "MCADBManager.h"

@interface assignmentTests : XCTestCase

@end

@implementation assignmentTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    //XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testMCAProduct
{
    NSArray *allJsonProducts = [MCAProduct getAllJsonProducts];
    XCTAssertEqual(allJsonProducts.count, 3, @"getAllJSONProducts count is not 3");
    
    MCADBManager *dbManager = [[MCADBManager alloc] init];
    XCTAssert([dbManager createDB], @"database creation failed");
    
    for (MCAProduct *product in allJsonProducts) {
        int result = [product addToDB];
        XCTAssert(result == SQLITE_DONE || result == SQLITE_CONSTRAINT, @"addProduct failed");
    }
    
    NSArray *allDBProducts = [MCAProduct getAllDBProducts];
    XCTAssertEqual(allDBProducts.count, 3, @"getAllDBProducts count is not 3");
    
    MCAProduct *thirdProduct = allJsonProducts[2];
    XCTAssert([MCAProduct deleteProductWithID:thirdProduct.ID], @"removeProduct failed");
    
    allDBProducts = [MCAProduct getAllDBProducts];
    XCTAssertEqual(allDBProducts.count, 2, @"getAllDBProducts count is not 2");
    
    NSString *ID = [allDBProducts objectAtIndex:0][@"ID"];
    MCAProduct *product = [MCAProduct getProductWithID:ID];
    XCTAssertNotNil(product, @"getProductWithID returned nil");
}

@end

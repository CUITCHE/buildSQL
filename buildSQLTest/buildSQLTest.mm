//
//  buildSQLTest.m
//  buildSQLTest
//
//  Created by hejunqiu on 16/7/1.
//  Copyright © 2016年 CHE. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BuildSql.h"

@interface buildSQLTest : XCTestCase
{
    BuildSql sqlBuilder;
}
@end

@implementation buildSQLTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    sqlBuilder.reset();
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testFieldOdd
{
    sqlBuilder.field(@"f0", @"f1", @"f2", @"f3").end();
    XCTAssertEqualObjects(sqlBuilder.sql(), @"f0, f1, f2, f3;");
}

- (void)testFieldNotOdd
{
    sqlBuilder.field(@"f0", @"f1", @"f2").end();
    XCTAssertEqualObjects(sqlBuilder.sql(), @"f0, f1, f2;");
}

- (void)testScope
{
    sqlBuilder.scopes().scopee();
    XCTAssertEqualObjects(sqlBuilder.sql(), @"()");
}

- (void)testInsertInto
{
    sqlBuilder.insertInto(@"table").field(@"f0", @"f1", @"f2").values();
    XCTAssertEqualObjects(sqlBuilder.sql(), @"INSERT INTO table(f0, f1, f2) VALUES(?,?,?);");
}

- (void)testDelete
{
    sqlBuilder.Delete(@"table").where(@"id").greaterThan(@1).And(@"id").lessThanOrEqualtTo(@200).Or(@"name").equalTo(@"sql");
    XCTAssertEqualObjects(sqlBuilder.sql(), @"DELETE FROM table WHERE id>1 AND id<=200 OR name='sql'");
}

- (void)testUpdate
{
    sqlBuilder.update(@"table").fieldPh(@"f0", @"f1", @"f2", @"f3").where(@"id").greaterThan(@200).Or(@"id").lessThanOrEqualtTo(@34).end();
    XCTAssertEqualObjects(sqlBuilder.sql(), @"UPDATE table SET f0=?, f1=?, f2=?, f3=? WHERE id>200 OR id<=34;");
}

- (void)testSelect
{
    sqlBuilder.select(@"f0", @"f1", @"f2").from(@"table").where(@"id").greaterThan(@1).And(@"name").equalTo(@"buildSQL");
    XCTAssertEqualObjects(sqlBuilder.sql(), @"SELECT f0, f1, f2 FROM table WHERE id>1 AND name='buildSQL'");
}

- (void)testCreateTable
{
    sqlBuilder.create(@"table").
    column(@"id", SqlTypeInteger).primaryKey().
    column(@"name", SqlTypeVarchar, bs_max(200)).nonull().
    column(@"number", SqlTypeDecimal, bs_precision(20, 8)).nonull().
    column(@"unique", SqlTypeDateTime).unique().end();
    XCTAssertEqualObjects(sqlBuilder.sql(), @"CREATE TABLE IF NOT EXISTS table(id Integer PRIMARY KEY,name Varchar(200) NOT NULL,number Decimal(20,8) NOT NULL,unique DateTime UNIQUE);");
}
@end

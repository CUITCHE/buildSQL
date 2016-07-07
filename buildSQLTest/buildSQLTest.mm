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

- (void)testCache
{
    sqlBuilder.update(@"table").fieldPh(@"f0", @"f1", @"f2", @"f3").where(@"id").greaterThan(@200).Or(@"id").lessThanOrEqualtTo(@34).end();
    sqlBuilder.setCacheForKey(@"1");

    sqlBuilder.reset();
    sqlBuilder.update(@"table").fieldPh(@"f0", @"f11", @"f2", @"f3").where(@"id").greaterThan(@200).Or(@"id").lessThanOrEqualtTo(@34).end();
    sqlBuilder.setCacheForKey(@"2");

    XCTAssertNotEqualObjects(sqlBuilder.cacheForKey(@"1"), sqlBuilder.cacheForKey(@"2"));
    XCTAssertEqualObjects(sqlBuilder.cacheForKey(@"1"), @"UPDATE table SET f0=?, f1=?, f2=?, f3=? WHERE id>200 OR id<=34;");
    XCTAssert(sqlBuilder.cached(@"1") && sqlBuilder.cached(@"2"));
    XCTAssert(!sqlBuilder.cached(@"3"));
}

- (void)testTailPrimaryKey
{
    sqlBuilder.create(@"table").
    column(@"id", SqlTypeInteger).
    column(@"name", SqlTypeVarchar, bs_max(200)).nonull().
    column(@"number", SqlTypeDecimal, bs_precision(20, 8)).nonull().
    column(@"unique", SqlTypeDateTime).unique().
    primaryKey(@"id").end();
    XCTAssertEqualObjects(sqlBuilder.sql(), @"CREATE TABLE IF NOT EXISTS table(id Integer,name Varchar(200) NOT NULL,number Decimal(20,8) NOT NULL,unique DateTime UNIQUE,PRIMARY KEY (id));");
}

- (void)testForeignKey
{
    sqlBuilder.create(@"table").
    column(@"id", SqlTypeInteger).primaryKey().
    column(@"name", SqlTypeVarchar, bs_max(200)).nonull().
    column(@"number", SqlTypeDecimal, bs_precision(20, 8)).nonull().
    column(@"unique", SqlTypeDateTime).unique().
    foreignKey(@"name", @"name2", @"another_table").end();
    XCTAssertEqualObjects(sqlBuilder.sql(), @"CREATE TABLE IF NOT EXISTS table(id Integer PRIMARY KEY,name Varchar(200) NOT NULL,number Decimal(20,8) NOT NULL,unique DateTime UNIQUE,FOREIGN KEY (name) REFERENCES another_table(name2));");
}

- (void)testCheck_way1
{
    sqlBuilder.create(@"table").
    column(@"id", SqlTypeInteger).check(@"id>0").
    column(@"name", SqlTypeVarchar, bs_max(200)).nonull().
    column(@"number", SqlTypeDecimal, bs_precision(20, 8)).nonull().
    column(@"unique", SqlTypeDateTime).unique().end();
    XCTAssertEqualObjects(sqlBuilder.sql(), @"CREATE TABLE IF NOT EXISTS table(id Integer CHECK (id>0),name Varchar(200) NOT NULL,number Decimal(20,8) NOT NULL,unique DateTime UNIQUE);");
}

- (void)testCheck_way2
{
    sqlBuilder.create(@"table").
    column(@"id", SqlTypeInteger).checks().field(@"id").gt(@0).And(@"id").lt(@1000).checke().
    column(@"name", SqlTypeVarchar, bs_max(200)).nonull().
    column(@"number", SqlTypeDecimal, bs_precision(20, 8)).nonull().
    column(@"unique", SqlTypeDateTime).unique().end();
    XCTAssertEqualObjects(sqlBuilder.sql(), @"CREATE TABLE IF NOT EXISTS table(id Integer CHECK (id>0 AND id<1000),name Varchar(200) NOT NULL,number Decimal(20,8) NOT NULL,unique DateTime UNIQUE);");
}

- (void)testDefualt
{
    sqlBuilder.create(@"table").
    column(@"id", SqlTypeInteger).checks().field(@"id").gt(@0).And(@"id").lt(@1000).checke().
    column(@"name", SqlTypeVarchar, bs_max(200)).nonull().Default(@"CUITCHE").
    column(@"number", SqlTypeDecimal, bs_precision(20, 8)).nonull().Default(@"12.8").
    column(@"unique", SqlTypeDateTime).unique().Default(@"GETDATE()").end();
    XCTAssertEqualObjects(sqlBuilder.sql(), @"CREATE TABLE IF NOT EXISTS table(id Integer CHECK (id>0 AND id<1000),name Varchar(200) NOT NULL DEFAULT 'CUITCHE',number Decimal(20,8) NOT NULL DEFAULT 12.8,unique DateTime UNIQUE DEFAULT GETDATE());");
}

- (void)testTop_1
{
    sqlBuilder.top(@10).field(@"f0", @"f1", @"f2").from(@"table").where(@"id").nlt(@12).end();
    XCTAssertEqualObjects(sqlBuilder.sql(), @"SELECT TOP 10 f0, f1, f2 FROM table WHERE id<=12;");
}

- (void)testTop_2
{
    sqlBuilder.top(@10).field(@"*").from(@"table").where(@"id").nlt(@12).end();
    XCTAssertEqualObjects(sqlBuilder.sql(), @"SELECT TOP 10 * FROM table WHERE id<=12;");
}

- (void)testTop_3
{
    sqlBuilder.top(@0.2).field(@"f0", @"f1", @"f2").from(@"table").where(@"id").nlt(@12).end();
    XCTAssertEqualObjects(sqlBuilder.sql(), @"SELECT TOP 20 PERCENT f0, f1, f2 FROM table WHERE id<=12;");
}

- (void)testIn_1
{
    sqlBuilder.select(@"f1",@"f2").from(@"table").where(@"column").in(@[@"che", @"hhhh"]).end();
    XCTAssertEqualObjects(sqlBuilder.sql(), @"SELECT f1, f2 FROM table WHERE column IN ('che','hhhh');");
}

- (void)testIn_2
{
    sqlBuilder.select(@"f1",@"f2").from(@"table").where(@"column").in(@[@2, @23.9]).end();
    XCTAssertEqualObjects(sqlBuilder.sql(), @"SELECT f1, f2 FROM table WHERE column IN (2,23.9);");
}

- (void)testBetween_1
{
    sqlBuilder.select(@"*").from(@"table").where(@"column").between(@"value1").And(@"value2").end();
    XCTAssertEqualObjects(sqlBuilder.sql(), @"SELECT * FROM table WHERE column BETWEEN 'value1' AND 'value2';");
}

- (void)testBetween_2
{
    sqlBuilder.select(@"*").from(@"table").where(@"column").between(@2).And(@2048).end();
    XCTAssertEqualObjects(sqlBuilder.sql(), @"SELECT * FROM table WHERE column BETWEEN 2 AND 2048;");
}

- (void)testAs_1
{
    sqlBuilder.select(@"field0").as(@"f0").field(@"field1", @"field2").from(@"table").end();
    XCTAssertEqualObjects(sqlBuilder.sql(), @"SELECT field0 AS f0, field1, field2 FROM table;");
}

- (void)testMultiFrom
{
    sqlBuilder.select(@"f1", @"f2").from(@[@"t1", @"t2"]).end();
    XCTAssertEqualObjects(sqlBuilder.sql(), @"SELECT f1, f2 FROM t1,t2;");
}

- (void)testJoin
{
    sqlBuilder.select(@"f1", @"f2").from(@"table").joinOn(@"anothertable", SqlJoinTypeNormal).field(@"table.id").et(@"anothertable.id").orderBy(@"f1").end();
    XCTAssertEqualObjects(sqlBuilder.sql(), @"SELECT f1, f2 FROM table OUTER JOIN anothertable ON table.id=anothertable.id ORDER BY f1;");
}

- (void)testUnion
{
    sqlBuilder.select(@"f1", @"f2", @"f3").from(@"table1").Union().select(@"f1", @"f2", @"f3").from(@"table2").end();
    XCTAssertEqualObjects(sqlBuilder.sql(), @"SELECT f1, f2, f3 FROM table1 UNION SELECT f1, f2, f3 FROM table2;");
    sqlBuilder.reset();

    sqlBuilder.select(@"f1", @"f2", @"f3").from(@"table1").Union(true).select(@"f1", @"f2", @"f3").from(@"table2").end();
    XCTAssertEqualObjects(sqlBuilder.sql(), @"SELECT f1, f2, f3 FROM table1 UNION ALL SELECT f1, f2, f3 FROM table2;");
}

- (void)testSelectInto
{
    sqlBuilder.select(@"*").into(@"newtable").from(@"oldtable");
    XCTAssertEqualObjects(sqlBuilder.sql(), @"SELECT * INTO newtable FROM oldtable");
}

- (void)testCreateIndex
{
    sqlBuilder.createIndex(@"indexName", @"f1", @"table");
    XCTAssertEqualObjects(sqlBuilder.sql(), @"CREATE INDEX indexName ON table(f1)");
}

- (void)testLimit
{
    sqlBuilder.select(@"*").from(@"table").where(@"id").gt(@1024).limit(2, 20);
    XCTAssertEqualObjects(sqlBuilder.sql(), @"SELECT * FROM table WHERE id>1024 LIMIT 2,20");
}

- (void)testSqlIfCached
{
    sqlBuilder.reset();
    const int count = 100;
    int i = count;
    int flag = 0;
    while (i-->0) {
        if (sqlBuilder.cached(@"sql_limit2_20")) {
            ++flag;
            continue;
        }
        sqlBuilder.select(@"*").from(@"table").where(@"id").gt(@1024).limit(2, 20).setCacheForKey(@"sql_limit2_20");
    }
    XCTAssert(flag == count - 1);
}
@end

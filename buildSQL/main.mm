//
//  main.m
//  buildSQL
//
//  Created by hejunqiu on 16/6/30.
//  Copyright © 2016年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BuildSql.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        BuildSql sqlBuilder;
        // select
        sqlBuilder.select(@"field0", @"field1", @"field2").from(@"table").where(@"id").equalTo(@(1)).And(@"type").lessThan(@(9)).end();
        printf("%s\n", sqlBuilder.sql().UTF8String);
        bs_set_cache(sqlBuilder, 1);

        sqlBuilder.reset();
        // insert into
        sqlBuilder.insertInto(@"table").field(@"field0", @"field1", @"field2", @"field3").values();
        printf("%s\n", sqlBuilder.sql().UTF8String);

        sqlBuilder.reset();
        // update
        sqlBuilder.update(@"table").fieldPh(@"field0", @"field1", @"field2", @"field3").where(@"name").equalTo(@"buildSql").end();
        printf("%s\n", sqlBuilder.sql().UTF8String);

        sqlBuilder.reset();
        // delete
        sqlBuilder.Delete(@"table").where(@"id").greaterThan(@1001).Or(@"id").lessThanOrEqualtTo(@2001).end();
        printf("%s\n", sqlBuilder.sql().UTF8String);

        sqlBuilder.reset();
        // order by
        sqlBuilder.select(@"field0", @"field1", @"field2").from(@"table").where(@"id").equalTo(@(1)).And(@"type").lessThan(@(9)).orderBy(@"field0").end();
        printf("%s\n", sqlBuilder.sql().UTF8String);
    }
    return 0;
}

//
//  BuildSql.mm
//  buildSQL
//
//  Created by hejunqiu on 16/6/30.
//  Copyright © 2016年 CHE. All rights reserved.
//

#import "BuildSql.h"

struct SqlMakerPrivateData
{
    uint32_t isFinished  : 1;
    uint32_t inserting   : 1;
    uint32_t updating    : 1;
    uint32_t deleting    : 1;
    uint32_t selecting   : 1;
    uint32_t operation   : 1; // 上一个操作是=,<>,>,<,<=,>=等操作
    uint32_t insertCount : 5; // 31个参数最多

    NSMutableString *sql;
    NSString *placeholder;

    SqlMakerPrivateData()
    :sql([NSMutableString stringWithCapacity:40])
    {}
    void clean() {
        isFinished = 0;
        insertCount = 0;
        updating = 0;
        deleting = 0;
        selecting = 0;
        operation = 0;
        insertCount = 0;
        [sql setString:@""];
    }
};

BuildSql::BuildSql(NSString *placehodler/* = @"?"*/)
:d(new struct SqlMakerPrivateData())
{
    d->placeholder = placehodler.copy;
}

BuildSql::~BuildSql()
{
    delete d;
}

BuildSql& BuildSql::from(NSString *table)
{
    [[d->sql append:@" FROM "] appendString:table];
    return *this;
}

BuildSql& BuildSql::where(NSString *field)
{
    [[d->sql append:@" WHERE "] appendString:field];
    return *this;
}

BuildSql& BuildSql::Delete(NSString *table)
{
    do {
        if (d->sql.length) {
            NSCAssert(NO, @"SQL: sql syntax error.");
            break;
        }
        [[d->sql append:@"DELETE FROM "] appendString:table];
    } while (0);
    return *this;
}

BuildSql& BuildSql::update(NSString *table)
{
    do {
        if (d->sql.length) {
            NSCAssert(NO, @"SQL: sql syntax error.");
            break;
        }
        [[[d->sql append:@"UPDATE "] append:table] append:@" SET "];
    } while (0);
    return *this;
}

BuildSql& BuildSql::insertInto(NSString *table)
{
    do {
        if (d->sql.length) {
            NSCAssert(NO, @"SQL: sql syntax error.");
            break;
        }
        [[d->sql append:@"INSERT INTO "] append:table];
        this->scopes();
        d->inserting = 1;
    } while (0);
    return *this;
}

BuildSql& BuildSql::values()
{
    do {
        if (!d->inserting) {
            d->insertCount = 0;
            break;
        }
        NSCAssert(d->insertCount, @"SQL: no matched number of placeholder");
        this->scopee();
        [[d->sql append:@" VALUES("] append:d->placeholder];
        while (--d->insertCount) {
            [[d->sql append:@","] append:d->placeholder];
        }
        [d->sql append:@")"];
        this->end();
    } while(0);
    return *this;
}

BuildSql& BuildSql::And(NSString *feild)
{
    [[d->sql append:@" AND "] append:feild];
    return *this;
}

BuildSql& BuildSql::Or(NSString *feild)
{
    [[d->sql append:@" OR "] append:feild];
    return *this;
}

BuildSql& BuildSql::scopes()
{
    [d->sql appendString:@"("];
    return *this;
}

BuildSql& BuildSql::scopee()
{
    [d->sql appendString:@")"];
    return *this;
}

BuildSql& BuildSql::value(NSString *value)
{
    [d->sql appendString:value];
    d->operation = 0;
    return *this;
}

BuildSql& BuildSql::placeholder()
{
    [d->sql appendString:d->placeholder];
    return *this;
}

BuildSql& BuildSql::orderBy(NSString *field, Order order/* = ASC*/)
{
    [[d->sql append:@" ORDER BY "] appendString:field];
    if (order == DESC) {
        [d->sql appendString:@" DESC"];
    }
    return *this;
}

#pragma mark - final sql
NSString* BuildSql::sql() const
{
    return d->sql;
}

#pragma mark - operation
BuildSql& BuildSql::equalTo(id value)
{
    do {
        if ([value isKindOfClass:[NSNumber class]]) {
            [d->sql appendFormat:@"=%@",value];
        } else if ([value isKindOfClass:[NSString class]]) {
            [d->sql appendFormat:@"='%@'",value];
        } else {
            NSCAssert(NO, @"SQL: unsupport type:%@", [value class]);
        }
    } while (0);
    return *this;
}

BuildSql& BuildSql::notEqualTo(id value)
{
    do {
        if ([value isKindOfClass:[NSNumber class]]) {
            [d->sql appendFormat:@"<>%@",value];
        } else if ([value isKindOfClass:[NSString class]]) {
            [d->sql appendFormat:@"<>'%@'",value];
        } else {
            NSCAssert(NO, @"SQL: unsupport type:%@", [value class]);
        }
    } while (0);
    return *this;
}

BuildSql& BuildSql::greaterThan(id value)
{
    do {
        if ([value isKindOfClass:[NSNumber class]]) {
            [d->sql appendFormat:@">%@",value];
        } else if ([value isKindOfClass:[NSString class]]) {
            [d->sql appendFormat:@">'%@'",value];
        } else {
            NSCAssert(NO, @"SQL: unsupport type:%@", [value class]);
        }
    } while (0);
    return *this;
}

BuildSql& BuildSql::greaterThanOrEqualTo(id value)
{
    do {
        if ([value isKindOfClass:[NSNumber class]]) {
            [d->sql appendFormat:@">=%@",value];
        } else if ([value isKindOfClass:[NSString class]]) {
            [d->sql appendFormat:@">='%@'",value];
        } else {
            NSCAssert(NO, @"SQL: unsupport type:%@", [value class]);
        }
    } while (0);
    return *this;
}

BuildSql& BuildSql::lessThan(id value)
{
    do {
        if ([value isKindOfClass:[NSNumber class]]) {
            [d->sql appendFormat:@"<%@",value];
        } else if ([value isKindOfClass:[NSString class]]) {
            [d->sql appendFormat:@"<'%@'",value];
        } else {
            NSCAssert(NO, @"SQL: unsupport type:%@", [value class]);
        }
    } while (0);
    return *this;
}

BuildSql& BuildSql::lessThanOrEqualtTo(id value)
{
    do {
        if ([value isKindOfClass:[NSNumber class]]) {
            [d->sql appendFormat:@"<=%@",value];
        } else if ([value isKindOfClass:[NSString class]]) {
            [d->sql appendFormat:@"<='%@'",value];
        } else {
            NSCAssert(NO, @"SQL: unsupport type:%@", [value class]);
        }
    } while (0);
    return *this;
}

BuildSql& BuildSql::field_impl(NSString *field, bool hasNext)
{
    [d->sql appendString:field];
    if (d->inserting) {
        ++d->insertCount;
    }
    if (hasNext) {
        [d->sql appendString:@", "];
    }
    return *this;
}

BuildSql& BuildSql::fieldPh_impl(NSString *field, bool hasNext)
{
    [[d->sql append:field] appendString:@"=?"];
    if (hasNext) {
        [d->sql appendString:@", "];
    }
    return *this;
}

BuildSql& BuildSql::select_impl(NSString *field, bool hasNext)
{
    [d->sql appendString:field];
    if (hasNext) {
        [d->sql appendString:@", "];
    }
    return *this;
}

void BuildSql::select()
{
    [d->sql appendString:@"SELECT "];
}

#pragma mark - constraint
BuildSql& BuildSql::nonull()
{
    [d->sql appendString:@" NOT NULL"];
    return *this;
}

BuildSql& BuildSql::unique()
{
    [d->sql appendString:@" UNIQUE"];
    return *this;
}

BuildSql& BuildSql::primaryKey()
{
    [d->sql appendString:@" PRIMARY KEY"];
    return *this;
}

#pragma mark - unsql
bool BuildSql::isFinished() const
{
    return d->isFinished;
}

void BuildSql::end()
{
    do {
        if (d->isFinished) {
            NSCAssert(NO, @"SQL: has finished!");
            break;
        }
        [d->sql appendString:@";"];
        d->isFinished = 1;
    } while (0);
}

void BuildSql::reset()
{
    d->clean();
}

@implementation NSMutableString (append)

- (instancetype)append:(NSString *)aString
{
    [self appendString:aString];
    return self;
}

@end

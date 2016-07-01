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
    uint32_t creating    : 1;
    uint32_t operation   : 1; // 上一个操作是=,<>,>,<,<=,>=等操作
    uint32_t creatingHasColumn : 1; // 已经添加一列了
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
        creating = 0;
        operation = 0;
        insertCount = 0;
        creatingHasColumn = 0;
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

void BuildSql::values()
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

BuildSql& BuildSql::value(id val)
{
    if ([val isKindOfClass:[NSNumber class]]) {
        [d->sql appendString:[val stringValue]];
    } else if ([val isKindOfClass:[NSString class]]) {
        [d->sql appendFormat:@"'%@'", val];
    } else {
        NSCAssert(NO, @"SQL: unsupport type:%@", [val class]);
    }
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

BuildSql& BuildSql::create(NSString *table)
{
    do {
        if (d->creating) {
            NSCAssert(NO, @"SQL: sql syntax error. You are already in creat-table. And you couldn't use 'creat' again.");
            break;
        }
        [[d->sql append:@"CREATE TABLE IF NOT EXISTS "] appendString:table];
        this->scopes();
        d->creating = 1;
    } while (0);
    return *this;
}

BuildSql& BuildSql::column(NSString *name, SqlType type, __capacity capacity/* = {0,0}*/)
{
#define __common(type) [words appendFormat:@"%@ %s", name, #type];
#define __case(type) case SqlType##type:\
                        __common(type) \
                        break
#define __caseCapacity(type) case SqlType##type:\
                                __common(type)\
                                [words appendFormat:@"(%u)",bs_whole(capacity)];\
                                break
#define __case2Place(type) case SqlType##type:\
                                __common(type)\
                                [words appendFormat:@"(%u,%u)",capacity.wholeMax,capacity.rightMax];\
                                break
    if (!name.length) {
        return *this;
    }
    NSMutableString *words = [NSMutableString stringWithCapacity:20];
    switch (type) {
        __case(Int);
        __case(TinyInt);
        __case(SmallInt);
        __case(MediumInt);
        __case(BigInt);
        __case(UnsignedBigInt);
        __case(Int2);
        __case(Int8);
        __case(Integer);
        __caseCapacity(Varchar);
        __caseCapacity(NVarchar);
        __caseCapacity(Char);
        __caseCapacity(NChar);
        __case(CLOB);
        __case(Text);
        __case(Double);
        __case(Float);
        __case(Real);
        __case2Place(Decimal);
        __case(Date);
        __case(DateTime);
        __case(Boolean);
        __case2Place(Numeric);
        __case(Blob);
        default:
            return *this;
    }
    if (d->creatingHasColumn) {
        [d->sql appendString:@","];
    } else {
        d->creatingHasColumn = 1;
    }
    [d->sql appendString:words];
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

BuildSql& BuildSql::like(NSString *value)
{
    [[d->sql append:@" LIKE "] appendString:value];
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
        if (d->creating) {
            this->scopee();
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

- (NSMutableString *)append:(NSString *)aString
{
    [self appendString:aString];
    return self;
}

@end

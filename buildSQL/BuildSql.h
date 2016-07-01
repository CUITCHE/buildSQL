//
//  BuildSql.h
//  buildSQL
//
//  Created by hejunqiu on 16/6/30.
//  Copyright © 2016年 CHE. All rights reserved.
//

#ifndef BuildSql_hpp
#define BuildSql_hpp

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint8_t, Order) {
    /// 升序
    ASC,
    /// 降序
    DESC
};

typedef NS_ENUM(NSInteger, SqlType) {
#pragma mark INTEGER in SQLITE
    SqlTypeInt,
    SqlTypeTinyInt,
    SqlTypeSmallInt,
    SqlTypeMediumInt,
    SqlTypeBigInt,
    SqlTypeUnsignedBigInt,
    SqlTypeInt2,
    SqlTypeInt8,
    SqlTypeInteger,

#pragma mark TEXT in SQLITE
    SqlTypeVarchar,
    SqlTypeNVarchar,
    SqlTypeChar,
    SqlTypeNChar,
    SqlTypeCLOB,
    SqlTypeText,

#pragma mark REAL in SQLITE
    SqlTypeDouble,
    SqlTypeFloat,
    SqlTypeReal,

#pragma mark NUMBERIC in SQLITE
    SqlTypeDecimal,
    SqlTypeDate,
    SqlTypeDateTime,
    SqlTypeBoolean,
    SqlTypeNumeric,

#pragma mark NONE in SQLITE
    SqlTypeBlob
};

// __capacity begin
typedef struct {
    uint32_t wholeMax : 16;
    uint32_t rightMax : 16;
}__capacity;

NS_INLINE uint32_t bs_whole(__capacity c) {return (((uint32_t)c.wholeMax)<<16) | c.rightMax;}
NS_INLINE __capacity bs_max(uint32_t val) {return {((val&0xFFFF0000)>>16), (val&0x0000FFFF)};}
NS_INLINE __capacity bs_precision(uint16_t whole, uint16_t right) {return {.wholeMax=whole,.rightMax=right};};
// __capacity end

class BuildSql
{
public:
    BuildSql(NSString *placehodler = @"?");
    ~BuildSql();

    template<typename... Args>
    BuildSql& field(NSString *field, Args... args);
    template<typename... Args>
    BuildSql& fieldPh(NSString *field, Args... args);

    template<typename... Args>
    BuildSql& select(Args... args);

    BuildSql& from(NSString *table);
    BuildSql& where(NSString *field);

    BuildSql& Delete(NSString *table);
    BuildSql& update(NSString *table);

    BuildSql& insertInto(NSString *table);
    void values(); // 如果本条sql使用了insert，那么将会自动插入与insert相同数量的placeholder

    BuildSql& scopes(); // '('开始标记
    BuildSql& scopee(); // ')'结束标记

    BuildSql& value(id val);

    BuildSql& orderBy(NSString *field, Order order = ASC);

    BuildSql& create(NSString *table);
    BuildSql& column(NSString *name, SqlType type, __capacity capacity = {0,0});
#pragma mark - final sql
    NSString* sql() const;

#pragma mark - operation
    BuildSql& equalTo(id value);
    BuildSql& notEqualTo(id value);
    BuildSql& greaterThan(id value);
    BuildSql& greaterThanOrEqualTo(id value);
    BuildSql& lessThan(id value);
    BuildSql& lessThanOrEqualtTo(id value);
    BuildSql& like(NSString *value);
    BuildSql& And(NSString *feild); // like and
    BuildSql& Or(NSString *feild);  // like or

#pragma mark - constraint
    BuildSql& nonull();
    BuildSql& unique();
    BuildSql& primaryKey();

#pragma mark - unsql
    bool isFinished() const;
    void end();
    void reset();
protected:
    BuildSql& field(){return *this;}
    BuildSql& field_impl(NSString *field, bool hasNext);

    BuildSql& fieldPh(){return *this;}
    BuildSql& fieldPh_impl(NSString *field, bool hasNext);

    BuildSql& select_extend(){return *this;}
    BuildSql& select_impl(NSString *field, bool hasNext);
    template <typename... Args>
    BuildSql& select_extend(NSString *field, Args... args);
    void select();
private:
    struct SqlMakerPrivateData *d;
};

template <typename... Args>
BuildSql& BuildSql::field(NSString *f, Args... args)
{
    field_impl(f, sizeof...(args) > 0);
    return field(args...);
}

template <typename... Args>
BuildSql& BuildSql::fieldPh(NSString *f, Args... args)
{
    fieldPh_impl(f, sizeof...(args) > 0);
    return fieldPh(args...);
}

template <typename... Args>
BuildSql& BuildSql::select(Args... args)
{
    select();
    return select_extend(args...);
}

template <typename... Args>
BuildSql& BuildSql::select_extend(NSString *field, Args... args)
{
    select_impl(field, sizeof...(args) > 0);
    return select_extend(args...);
}
#pragma mark -[C]
@interface NSMutableString (append)

- (NSMutableString *)append:(NSString *)aString;

@end

#endif /* BuildSql_hpp */

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
    /// same as equalTo.
    BuildSql& et(id value){return equalTo(value);}
    BuildSql& equalTo(id value);

    /// same as notEqualTo.
    BuildSql& net(id value){return notEqualTo(value);}
    BuildSql& notEqualTo(id value);

    /// same as greaterThan.
    BuildSql& gt(id value){return greaterThan(value);}
    BuildSql& greaterThan(id value);

    /// same as greaterThanOrEqualTo.
    BuildSql& ngt(id value){return greaterThanOrEqualTo(value);}
    BuildSql& greaterThanOrEqualTo(id value);

    /// same as lessThan.
    BuildSql& lt(id value){return lessThan(value);}
    BuildSql& lessThan(id value);

    /// same as lessThanOrEqualtTo.
    BuildSql& nlt(id value){return lessThanOrEqualtTo(value);}
    BuildSql& lessThanOrEqualtTo(id value);

    BuildSql& And(id valueOrField); // like and
    BuildSql& Or(NSString *feild);  // like or

#pragma mark - constraint
    BuildSql& nonull();
    BuildSql& unique();
    BuildSql& primaryKey();

#pragma mark - advance
    BuildSql& like(NSString *value);
    /**
     * @author hejunqiu, 16-07-03 22:07:51
     *
     * Build a statement-sql for a clause of SELECT: 'TOP 100' or 'TOP 50 PERCENT'.
     * Such as 'SELECT TOP 2 * FROM Persons', 'SELECT TOP 50 PERCENT * FROM Persons'.
     *
     * @param number An object of NSNumber presents integer or float value. If number
     * is a float value, it's limit between 0 and 1.
     *
     * @return An object of BuildSql.
     */
    BuildSql& top(NSNumber *number);

    BuildSql& in(NSArray *numberOrStringValues);
    BuildSql& between(id value);

#pragma mark - unsql
    bool isFinished() const;
    void end();
    void reset();
    NSString* cacheForKey(NSString *key) const;
    void setCacheForKey(NSString *key);
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

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

typedef enum {
    /// 升序
    ASC,
    /// 降序
    DESC
} Order;

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
    BuildSql& values(); // 如果本条sql使用了insert，那么将会自动插入与insert相同数量的placeholder

    BuildSql& And(NSString *feild); // like and
    BuildSql& Or(NSString *feild);  // like or

    BuildSql& scopes();
    BuildSql& scopee();

    BuildSql& value(NSString *value);
    BuildSql& placeholder();

    BuildSql& orderBy(NSString *field, Order order = ASC);

#pragma mark - final sql
    NSString* sql() const;

#pragma mark - operation
    BuildSql& equalTo(id value);
    BuildSql& notEqualTo(id value);
    BuildSql& greaterThan(id value);
    BuildSql& greaterThanOrEqualTo(id value);
    BuildSql& lessThan(id value);
    BuildSql& lessThanOrEqualtTo(id value);

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

- (instancetype)append:(NSString *)aString;

@end

#endif /* BuildSql_hpp */

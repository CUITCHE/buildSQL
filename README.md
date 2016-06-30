# buildSQL
基于Objective-C的buildSQL，可以用代码语言来build一条SQL语句。
# 简介
某天，我写了很多SQL语句，实在受不了了，就有了buildSQL。
# 如何使用
将`BuildSql.h`和`BuildSql.mm`包含进你的工程，并在包含`BuildSql.h`的文件的后缀名改为`mm`即可。
具体用法：
```Objective-C
BuildSql sqlBuilder;
sqlBuilder.select(@"field0", @"field1", @"field2").from(@"table").where(@"id").equalTo(@(1)).And(@"type").lessThan(@(9)).end();
printf("%s\n", sqlBuilder.sql().UTF8String);

sqlBuilder.reset();
sqlBuilder.insertInto(@"table").field(@"field0", @"field1", @"field2", @"field3").values();
printf("%s\n", sqlBuilder.sql().UTF8String);

sqlBuilder.reset();
sqlBuilder.update(@"table").fieldPh(@"field0", @"field1", @"field2", @"field3").where(@"name").equalTo(@"buildSql").end();
printf("%s\n", sqlBuilder.sql().UTF8String);

sqlBuilder.reset();
sqlBuilder.Delete(@"table").where(@"id").greaterThan(@1001).Or(@"id").lessThanOrEqualtTo(@2001).end();
printf("%s\n", sqlBuilder.sql().UTF8String);
```
输出：
```
SELECT field0, field1, field2 FROM table WHERE id=1 AND type<9;
INSERT INTO table(field0, field1, field2, field3) VALUES(?,?,?,?);
UPDATE table SET field0=?, field1=?, field2=?, field3=? WHERE name='buildSql';
DELETE FROM table WHERE id>1001 OR id<=2001;
```
# 使用要求
* Xcode 7.3
* Only support [C]

# 注意
* 目前实现了`SELECT`，`UPDATE`，`DELETE`，`INSERT INTO`的简单用法。
* 高级约束未实现。
* `CREATE TABLE`未实现。

# ELSE
欢迎各位对此感兴趣的社区同仁共同维护buildSQL。欢迎大家提bug issue。

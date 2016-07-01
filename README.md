# buildSQL
基于C++和Objective-C的buildSQL，可以用代码语言来build一条SQL语句。
# 简介
某天，我写了很多SQL语句，实在受不了了，就有了buildSQL。在有代码提示的情况下，写起来会更爽，阅读这样的SQL语句也更清晰明了。
# 如何使用
将`BuildSql.h`和`BuildSql.mm`包含进你的工程，并在包含`BuildSql.h`的文件的后缀名改为`mm`即可。
具体用法：
```Objective-C
BuildSql sqlBuilder;
// select
sqlBuilder.select(@"field0", @"field1", @"field2").from(@"table").where(@"id").equalTo(@(1)).And(@"type").lessThan(@(9)).end();

// insert into
sqlBuilder.insertInto(@"table").field(@"field0", @"field1", @"field2", @"field3").values();

// update
sqlBuilder.update(@"table").fieldPh(@"field0", @"field1", @"field2", @"field3").where(@"name").equalTo(@"buildSql").end();

// delete
sqlBuilder.Delete(@"table").where(@"id").greaterThan(@1001).Or(@"id").lessThanOrEqualtTo(@2001).end();

// order by
sqlBuilder.select(@"field0", @"field1", @"field2").from(@"table").where(@"id").equalTo(@(1)).And(@"type").lessThan(@(9)).orderBy(@"field0").end();
```
输出：
```
SELECT field0, field1, field2 FROM table WHERE id=1 AND type<9;
INSERT INTO table(field0, field1, field2, field3) VALUES(?,?,?,?);
UPDATE table SET field0=?, field1=?, field2=?, field3=? WHERE name='buildSql';
DELETE FROM table WHERE id>1001 OR id<=2001;
SELECT field0, field1, field2 FROM table WHERE id=1 AND type<9 ORDER BY field0;
```
BuildSql可以被多次使用，只需要在使用前调用`reset()`就可以恢复到初始状态。
# 使用要求
* Only support [C]. 由于使用了Objective-C的`NSString`，所以暂时只支持[C]，以后会考虑改成存C++的构建。

# 注意
* buildSql基本上不会去检查语法错误！
* 目前实现了`SELECT`，`UPDATE`，`DELETE`，`INSERT INTO`的简单用法。
* 高级约束未实现。
* `CREATE TABLE`未实现。

# 其它
欢迎各位对此感兴趣的社区同仁共同维护buildSQL。欢迎大家提bug issue。

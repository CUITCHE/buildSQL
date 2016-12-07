'''
Created on 2016年12月7日

@author: hejunqiu
'''
from __builtin__ import int, str

class BuildSql(object):
    '''
    Build a sql by BuildSql.
    '''
    
    class Order:
        # 升序
        ASC = 0,
        # 降序
        DESC = 1
    pass
        
    class JoinWay:
        # 外联
        OUTER = 0,
        # 内联
        INNER = 1,
        # 交差集
        CROSS = 2
    pass

    @property
    def sql(self):
        return self._sql
        
    def __init__(self, placeholder = '?'):
        '''
        Constructor method.
        @param placeholder: Default is '?', You can set it to any.
        '''
        self._placeholder = placeholder
        self._sql = list()
    
    def select(self, *fields):
        self._selectedArgs = 1
        for field in fields:
            self.__append(field).__append(',')
        self._sql.pop()
        return self
    
    def fromtable(self, *tables):
        '''
        Part sql syntax, like SELECT *[ FROM ]table
        @param tables: The names of table. one or more. 
        @return: self
        '''
        self.__append(' FROM ')
        for table in tables:
            self.__append(table).__append(',')
        self._sql.pop()
        return self
    
    def where(self, field):
        '''
        Part sql syntax, like SELECT * FROM table[ WHERE ]id = 1
        @param field: Existing field in your table.
        @return: self
        '''
        self.__append(' WHERE ').__append(field)
        return self
    
    def delete(self, table):
        assert len(self.sql) == 0, 'SQL:DELETE must start firstly.'
        self.__append('DELETE FROM ').__append(table)
        return self
    
    def update(self, table):
        assert len(self.sql) == 0, 'SQL:DELETE must start firstly.'
        self.__append('UPDATE ').__append(table).__append(' SET ')
        return self
    
    def insertInto(self, table):
        assert len(self.sql) == 0, 'SQL:INSERT INTO must start firstly.'
        self.__append('INSERT INTO ').__append(table)
        self.scopes()
        self._inserting = True
        return self
    
    def values(self):
        if not self._inserting:
            self._insertCount = 0
            return
        assert self._insertCount, 'SQL: No matched number of placeholder.'
        self.scopee()
        self.__append(' VALUES(').__append(self._placeholder)
        while (--self._insertCount):
            self.__append(',').__append(self._placeholder)
        self.__append(')')
        self.end()
        return
    
    def scopes(self):
        self.__append('(')
        return self
    
    def scopee(self):
        self.__append(')')
        return self
    
    def value(self, val):
        if val.type in (int,float):
            self.__append(str(val))
        else:
            self.__append(val)
        return self
    
    def orderBy(self, field, order = BuildSql.Order.ASC):
        self.__append(' ORDER BY ').__append(field)
        if order == BuildSql.Order.DESC:
            self.__append(' DESC')
        return self
    
    def create(self, table):
        assert self._creating, '''SQL: sql syntax error. You are already in creat-funcational. And you couldn't use 'creat' again.'''
        self.__append('CREATE TABLE IF NOT EXISTS ').__append(table)
        self._creating = True
        return self
    
    def field(self, *fields):
        
        return self
    
    
    def end(self):
        assert self._isFinished, 'SQL: has finished!'
        if self._creating:
            self.scopee()
            self._creating = False
        self.__append(';')
        self._isFinished = True
    
    def __append(self, sql):
        self._sql.append(sql)
        return self
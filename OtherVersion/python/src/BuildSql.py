'''
Created on 2016年12月7日

@author: hejunqiu
'''

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
        self.placeholder = placeholder
        self._sql = list()
        
    def fromtable(self, tables):
        '''
        Part sql syntax, like SELECT *[ FROM ]table
        @param tables: The names of table. one or more. Support type:set(str), list(str) or str
        @return: self
        '''
        assert tables.type in (set, list, str), 'param[tables] must be a set type.'
        assert len(tables), 'The length of tables must not be 0.'
        self.__append(' FROM ')
        if tables is str:
            self.__append(tables)
        else:
            first = True
            for table in tables:
                if first:
                    self.__append(table)
                    first = True
                else:
                    self.__append(',').__append(table)
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
        return self
    
    def select(self):
        pass
    def __append(self, sql):
        self._sql.append(sql)
        return self
'''
Created on 2016年12月7日

@author: hejunqiu
'''
from enum import Enum,unique
from builtins import str
from _ast import Str

class BuildSql(object):
    '''
    Build a sql by BuildSql.
    '''
    
    @unique
    class Order(Enum):
        # 升序
        ASC = 0
        # 降序
        DESC = 1
    pass
    
    @unique
    class JoinWay(Enum):
        # 外联
        OUTER = 0
        # 内联
        INNER = 1
        # 交差集
        CROSS = 2
    pass

    @unique
    class SqlType(Enum):
        # INTEGER in SQLITE
        INI = 0
        TINYINT = 1
        SMALLINT = 2
        MEDIUMINT = 3
        BIGINT = 4
        UNSIGNEDBIGINT = 5
        INT2 = 6
        INT8 = 7
        INTEGER = 8
        # TEXT in SQLITE    
        VARCHAR = 9
        NVARCHAR = 10
        CHAR = 11
        NCHAR = 12
        CLOB = 12
        TEXT = 13
        # REAL in SQLITE
        DOUBLE = 14
        FLOAT = 15
        REAL = 16
        # NUMBERIC in SQLITE
        DECIMAL = 17
        DATE = 18
        DATETIME = 19
        BOOLEAN = 20
        NUMBERIC = 21
        # NONE in SQLITE
        BLOB = 21
    pass

    class InvaildArgumentError(Exception):pass
    class SQLBuildError(Exception):pass

    @property
    def sql(self):
        return self._sql
        
    def __init__(self, placeholder='?'):
        '''
        Constructor method.
        @param placeholder: Default is '?', You can set it to any.
        '''
        self._placeholder = placeholder
        self._sql = list()
        self._creatingHasColumn = False
    
    def select(self, *fields):
        self.__append('SELECT ')
        self._selecting = True
        if len(fields):
            self._selectedArgs = 1
            for field in fields:
                self.__append(field).__append(', ')
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
        while (- -self._insertCount):
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
        if type(val) is str:
            self.__append('\"{}\"'.format(val))
        else:
            self.__append(str(val))
        return self
    
    def orderBy(self, field, order=Order.ASC):
        self.__append(' ORDER BY ').__append(field)
        if order == self.Order.DESC:
            self.__append(' DESC')
        return self
    
    def create(self, table):
        assert self._creating, '''SQL: sql syntax error. You are already in create-funcation. And you couldn't use 'creat' again.'''
        self.__append('CREATE TABLE IF NOT EXISTS ').__append(table)
        self._creating = True
        return self
    
    def column(self, name: str, sqlType: BuildSql.SqlType, *capacity) -> BuildSql:
        self.__append('{} {}'.format(name, sqlType.name()))
        if self.SqlType.VARCHAR <= sqlType <= self.SqlType.NCHAR:
            assert len(capacity), 'SQL:{} type needs capacity.'.format(sqlType.name())
            self.__append('({})'.format(capacity[0]))
        elif sqlType == self.SqlType.DECIMAL or sqlType == self.SqlType.NUMBERIC:
            assert len(capacity) == 2, 'SQL:{} type needs a range.'.format(sqlType.name())
            self.__append('({},{})'.format(capacity[0], capacity[1]))
        if self._creatingHasColumn:
            self.__append(',')
        else:
            self._creatingHasColumn = True;
        self._lastTypeOfField = sqlType
        return self
# operation
    def equalTo(self, value):
        if value is None:
            raise self.InvaildArgumentError('value must not be None');
        if not self._joining and type(value) is str:
            self.__append('=\'{}\''.format(value))
        else:
            self.__append('={}'.format(value))
        return self
    
    def et(self, value = None):
        if value is None:
            self.__append('={}'.self._placeholder)
            return self
        return self.equalTo(value)
    
    def notEqualTo(self, value):
        if value is None:
            raise self.InvaildArgumentError('value must not be None');
        if not self._joining and type(value) is str:
            self.__append('<>\'{}\''.format(value))
        else:
            self.__append('<>{}'.format(value))
        return self
    
    def net(self, value = None):
        if value is None:
            self.__append('<>{}'.self._placeholder)
            return self
        return self.notEqualTo(value)
    
    def greaterThan(self, value):
        if value is None:
            raise self.InvaildArgumentError('value must not be None');
        if not self._joining and type(value) is str:
            self.__append('>\'{}\''.format(value))
        else:
            self.__append('>{}'.format(value))
        return self
    
    def gt(self, value = None):
        if value is None:
            self.__append('>{}'.self._placeholder)
            return self
        return self.greaterThan(value)
    
    def greaterThanOrEqualTo(self, value):
        if value is None:
            raise self.InvaildArgumentError('value must not be None');
        if not self._joining and type(value) is str:
            self.__append('>=\'{}\''.format(value))
        else:
            self.__append('>={}'.format(value))
        return self
    
    def nlt(self, value = None):
        if value is None:
            self.__append('>={}'.self._placeholder)
            return self
        return self.greaterThanOrEqualTo(value)
    
    def lessThan(self, value):
        if value is None:
            raise self.InvaildArgumentError('value must not be None');
        if not self._joining and type(value) is str:
            self.__append('<\'{}\''.format(value))
        else:
            self.__append('<{}'.format(value))
        return self
    
    def lt(self, value = None):
        if value is None:
            self.__append('<{}'.self._placeholder)
            return self
        return self.lessThan(value)
    
    def lessThanOrEqualtTo(self, value):
        if value is None:
            raise self.InvaildArgumentError('value must not be None');
        if not self._joining and type(value) is str:
            self.__append('<=\'{}\''.format(value))
        else:
            self.__append('<={}'.format(value))
        return self
    
    def ngt(self, value = None):
        if value is None:
            self.__append('<={}'.self._placeholder)
            return self
        return self.lessThanOrEqualtTo(value)
    
    def And(self, valueOrField): 
        fmt = '{}'
        if self._betweening:
            if type(valueOrField) is str:
                fmt = '\'{}\''
            self._betweening = False
        self.__append(' AND ').__append(fmt.format(valueOrField))
        return self
    
    def Or(self, field: str):
        self.__append(' OR {}'.format(field))
        return self
    
    def field(self, *fields):
        if self._selectedArgs:
            self._selectedArgs = False
            self.__append(', ')
        for i, field in fields:
            if self._inserting:
                ++self._insertCount
            if i:
                self.__append(', ')
            self.__append(field)
        return self
    
    def fieldPh(self, *fields):
        for i, field in fields:
            if i:
                self.__append(', ')
            self.__append(field)
        return self
    
# constraint
    def nonull(self):
        self.__append(' NOT NULL')
        return self
    
    def unique(self, field: str = None) -> BuildSql:
        if str is None:
            self.__append(' UNIQUE')
            return self
        if not self._creating:
            raise self.SQLBuildError('SQL: Tail UNIQUE operation is just used in CREATE statement.')
        if not self._creatingHasColumn:
            raise self.SQLBuildError('SQL: No column!')
        self.__append(',UNIQUE ({})'.format(field))
        return self
    
    def primaryKey(self, field: str = None) -> BuildSql:
        if field is None:
            self.__append(' PRIMARY KEY')    
            return self
        if not self._creating:
            raise self.SQLBuildError('SQL: Tail PRIMARY KEY operation is just used in CREATE statement.')
        if not self._creatingHasColumn:
            raise self.SQLBuildError('SQL: No column!')
        self.__append(',PRIMARY KEY ({})'.format(field))
        return self
    
    def pk(self, field: str=None) -> BuildSql:
        return self.primaryKey(field)
    
    def foreignKey(self, field: str, toField: str, ofAnotherTable: str) -> BuildSql:
        return self
    
    def end(self):
        if self._isFinished:
            raise self.SQLBuildError('SQL: has finished!')
        if self._creating:
            self.scopee()
            self._creating = False
        self.__append(';')
        self._isFinished = True
    
    def __append(self, sql):
        self._sql.append(sql)
        return self

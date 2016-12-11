'''
Created on 2016年12月7日

@author: hejunqiu
'''

__metaclass = type

from enum import Enum, unique
from builtins import str, int
import copy

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
	CLOB = 13
	TEXT = 14
	# REAL in SQLITE
	DOUBLE = 15
	FLOAT = 16
	REAL = 17
	# NUMBERIC in SQLITE
	DECIMAL = 18
	DATE = 19
	DATETIME = 20
	BOOLEAN = 21
	NUMBERIC = 22
	# NONE in SQLITE
	BLOB = 23
pass

@unique
class SqlJoinType(Enum):
	NORMAL = 0
	LEFT = 1
	RIGHT = 2
	FULL = 3
pass

class BuildSql(object):
	'''
	Build a sql by BuildSql.
	'''
	__version__ = '0.0.1'

	class InvaildArgumentError(Exception):pass
	class SQLBuildError(Exception):pass

	def __init__(self, placeholder='?'):
		'''
		Constructor method.
		@param placeholder: Default is '?', You can set it to any.
		'''
		self._placeholder = placeholder
		self._sql = list()
		self._sqlBuildCache = {}
		self.__clean()

	@property
	def sql(self) -> str:
		return ''.join(self._sql)

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
		if order == Order.DESC:
			self.__append(' DESC')
		return self

	def create(self, table):
		assert not self._creating, 'SQL: sql syntax error. You are already in create-funcation. And you couldn\'t use \'creat\' again.'
		self.__append('CREATE TABLE IF NOT EXISTS ').__append(table)
		self._creating = True
		return self.scopes()

	def column(self, columnName: str, sqlType:SqlType, *capacity):
		if self._creatingHasColumn:
			self.__append(',')
		else:
			self._creatingHasColumn = True
		self.__append('{} {}'.format(columnName, sqlType.name))
		if SqlType.VARCHAR.value <= sqlType.value <= SqlType.NCHAR.value:
			assert len(capacity), 'SQL:{} type needs capacity.'.format(sqlType.name)
			self.__append('({})'.format(capacity[0]))
		elif sqlType.value == SqlType.DECIMAL.value or sqlType.value == SqlType.NUMBERIC.value:
			assert len(capacity) == 2, 'SQL:{} type needs a range.'.format(sqlType.name)
			self.__append('({},{})'.format(capacity[0], capacity[1]))
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

	def et(self, value=None):
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

	def net(self, value=None):
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

	def gt(self, value=None):
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

	def nlt(self, value=None):
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

	def lt(self, value=None):
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

	def ngt(self, value=None):
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
				+ +self._insertCount
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

	def unique(self, field: str=None):
		if str is None:
			self.__append(' UNIQUE')
			return self
		self.__checkInCreating('unique')
		self.__append(',UNIQUE ({})'.format(field))
		return self

	def primaryKey(self, field: str=None):
		if field is None:
			self.__append(' PRIMARY KEY')
			return self
		self.__checkInCreating('primaryKey')
		self.__append(',PRIMARY KEY ({})'.format(field))
		return self

	def pk(self, field: str=None):
		return self.primaryKey(field)

	def foreignKey(self, field: str, toField: str, ofAnotherTable: str):
		if field is None or toField is None or ofAnotherTable is None:
			raise self.SQLBuildError('SQL: parameters must not be None.')
		self.__checkInCreating('foreignKey')
		self.__append(',FOREIGN KEY ({}) REFERENCES {}({})'.format(field, ofAnotherTable, toField))
		return self

	def fk(self,  field: str, toField: str, ofAnotherTable: str):
		return self.foreignKey(field, toField, ofAnotherTable)

	def check(self, statement: str):
		assert statement, 'parameter couldn\'t be None.'
		self.__checkInCreating('check')
		self.__append(' CHECK ({})'.format(statement))
		return self

	def checks(self):
		self.__checkInCreating('check start statement')
		self.__append(' CHECK (')
		return self

	def checke(self):
		self.__checkInCreating('check end statement')
		self.__append(')')
		return self

	def default(self, statement: str):
		self.__checkInCreating('DEFAULT')
		self.__append(' DEFAULT ')
		if SqlType.VARCHAR.value <= self._lastTypeOfField.value <= SqlType.TEXT.value:
			self.__append('\'{}\''.format(statement))
		else:
			self.__append(statement)
		return self
# Advance
	def like(self, value):
		self.__append(' LIKE \'{}\''.format(str(value)))
		return self

	def top(self, number):
		assert number, 'parameter must not be None.'
		if type(number) is float:
			if not(0.0 <= number <= 1.0):
				raise self.SQLBuildError('Invalid parameter. In top x percent statement, x is between 0.0 and 1.0')
			self.__append('SELECT TOP {} PERCENT '.format((int)(number * 100)))
		else:
			self.__append('SELECT TOP {} '.format(number))
		self._selecting = True
		return self

	def limit(self, start: int, count: int):
		self.__append(' LIMIT {},{}'.format(start, count))
		return self

	def IN(self, *elements):
		if len(elements) != 0:
			raise self.SQLBuildError('SQL: empty set.')
		fmt = None
		elementType = type(elements.first())
		if elementType is str:
			fmt = ',\'{}\''
		elif elementType is int:
			fmt = ',{}'
		else:
			raise self.SQLBuildError('SQL: unsupported type:{}'.format(elementType))
		self.__append(' IN ({}'.format(elements.pop()))
		for element in elements:
			self.__append(fmt.format(element))
		self.__append(')')
		return self

	def between(self, value):
		self.__append(' BETWEEN ')
		valueType = type(value)
		fmt = None
		if valueType is str:
			fmt = '\'{}\''
		elif valueType is int:
			fmt = '{}'
		else:
			raise self.SQLBuildError('SQL: unsupported type:{}'.format(valueType))
		self.__append(fmt.format(value))
		self._betweening = True
		return self

	def AS(self, alias):
		self.__append(' AS {}'.format(alias))
		return self

	def joinon(self, table: str, joinType: SqlJoinType, oi:JoinWay = JoinWay.OUTER):
		assert len(str) != 0, 'SQL: the length of table must not be 0.'
		fmt = None
		if joinType == SqlJoinType.NORMAL:
			fmt = ' {} JOIN {} ON '
		elif joinType == SqlJoinType.LEFT:
			fmt = ' LEFT {} JOIN {} ON '
		elif joinType == SqlJoinType.RIGHT:
			fmt = ' RIGHT {} JOIN {} ON '
		elif joinType == SqlJoinType.FULL:
			fmt = 'FULL {} JOIN {} ON '
		else:
			raise self.SQLBuildError('SQL: unsupported SqlJoinType value({})'.format(joinType.name))

		self.__append(fmt.format(oi.name, table))
		self._joining = True
		return self

	def union(self, recur: bool=False):
		if not self._selecting:
			raise self.SQLBuildError('SQL: UNION operation is just used in SELECT statement.')
		self.__append(' UNION ')
		if recur:
			self.__append('ALL ')
		return self

	def into(self, table: str):
		assert len(table) != 0, 'SQL: the length of table must not be 0.'
		if not self._selecting:
			raise self.SQLBuildError('SQL: SELECT INTO operation is just used in SELECT statemnet.')
		self.__append(' INTO {}'.format(table))
		return self

	def createIndex(self, indexName: str, onField: str, ofTable: str, unique: bool=False):
		fmt = None
		if unique:
			fmt = 'CREATE UNIQUE INDEX {} ON {}({})'
		else:
			fmt = 'CREATE INDEX {} ON {}({})'
		self.__append(fmt.format(indexName, ofTable, onField))
		return self

	def isnull(self):
		self.__append(' IS NULL')
		return self

	def isnnull(self):
		self.__append('IS NOT NULL')
		return self

#   unsql
	def isFinished(self):
		return self._isFinished

	def end(self):
		if self._isFinished:
			raise self.SQLBuildError('SQL: has finished!')
		if self._creating:
			self.scopee()
			self._creating = False
		self.__append(';')
		self._isFinished = True

	def reset(self):
		self.__clean()
		return self

	def cacheForKey(self, key: str) -> str:
		if key in self._sqlBuildCache:
			return self._sqlBuildCache[key]
		return None

	def cached(self, key: str) -> bool:
		return key in self._sqlBuildCache

	def setCacheForKey(self, key: str):
		if self.cached(key):
			raise self.SQLBuildError('SQL: repeat cache for key({}). Check your code.'.format(key))
		self._sqlBuildCache[key] = ''.join(self._sql)

	def caches(self) -> dict:
		a = copy.deepcopy(self._sqlBuildCache)
		return a

#     private
	def __clean(self):
		self._isFinished = False
		self._insertCount = False
		self._updating = False
		self._deleting = False
		self._selecting = False
		self._creating = False
		self._operation = False
		self._insertCount = False
		self._creatingHasColumn = False
		self._betweening = False
		self._selectedArgs = False
		self._joining = False
		self._sql.clear()

	def __checkInCreating(self, methodName: str):
		if not self._creating:
			raise self.SQLBuildError('SQL: Tail {} operation is just used in CREATE statement.'.format(methodName))
		if not self._creatingHasColumn:
			raise self.SQLBuildError('SQL: No column!')

	def __append(self, sql: str):
		self._sql.append(sql)
		return self

if '__main__' == __name__:
	builder = BuildSql()
	builder.create('table')
	builder.column('column1', SqlType.VARCHAR, 100).pk().\
			column('c2', SqlType.NUMBERIC, 12, 8).nonull().\
			column('c3', SqlType.CHAR, 64).default('defalut char value fill').end()
	print(builder.sql)

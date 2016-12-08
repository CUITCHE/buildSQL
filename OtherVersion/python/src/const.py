'''
Created on 2016年12月8日

@author: hejunqiu
'''

class const(object):
    '''
    classdocs
    '''
    class ConstError(TypeError): pass

    def __init__(self, params):
        '''
        Constructor
        '''
    def __setattr__(self, name, value):
        if self.__dict__.has_key(name):
            raise self.ConstError('You could modify the value of {}.'.format(name))
        return super.__setattr__(self, name, value)    
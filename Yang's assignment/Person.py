class Person:

    def __init__(self, name='', address='', phoneNum=''):

        self.name = name
        self.address = address
        self.phoneNum = phoneNum

    def setName(self, newName):
        self.name = newName
        
    def getName(self):
        return self.name
    
    def setAddress(self, newAddress):
        self.address = newAddress
    
    def getAddress(self):
        return self.address

    def setPhoneNum(self, newPhoneNum):
        self.phoneNum = newPhoneNum
    
    def getPhoneNum(self):
        return self.phoneNum
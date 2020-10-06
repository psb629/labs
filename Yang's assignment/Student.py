from Person import Person
class Student(Person):

    def __init__(self, name='', address='', phoneNum='', studentId='', major='', scores={}):
        
        self.studentId = studentId
        self.major = major
        self.scores = scores
        super().__init__(name=name, address=address, phoneNum=phoneNum)
        
    def setStudentId(self, newStudentID):
        self.studentId = newStudentID
        
    def getStudentId(self):
        return self.studentId
    
    def setMajor(self, newMajor):
        self.major = newMajor
    
    def getMajor(self):
        return self.major
    
    def addScore(self, grade):
        subj = list(grade.keys())[0]
        scr = list(grade.values())[0]
        if subj in self.scores:
            print("이미 과목 점수가 저장되어 있습니다.")
        else:
            self.scores.update(grade)
            print("%s는 %d점으로 저장되었습니다." %(subj,scr))
            
    def changeScore(self, subj, scr):
        if subj in self.scores:
            scr_b4 = self.scores[subj]
            self.scores[subj] = scr
            print("%s(은)는 %d점에서 %d점으로 변경되었습니다." %(subj,scr_b4,scr))
            
        else:
            print("%s 과목은 저장되지 않았습니다." %subj)
            
    def getScore(self, subj):
        if subj in self.scores:
            scr = self.scores[subj]
        else:
            scr = None
        return scr
    
    def printScores(self):
        subjs = self.scores.keys()
        scrs = self.scores.values()
        if len(subjs)==0:
            print("저장된 과목이 없습니다.")
        else:
            for subj, scr in zip(subjs,scrs):
                print("%s : %d점" %(subj,scr))
                
    def calcAverage(self):
        subjs = self.scores.keys()
        scrs = self.scores.values()
        if len(subjs)==0:
            print("저장된 과목이 없습니다.")
            mean = 0.0
        else:
            mean = sum(scrs)/len(subjs)
        return mean
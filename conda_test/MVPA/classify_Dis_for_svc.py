#import nilearn.decoding
#import nilearn.image
import pandas as pd
#import time

#from sklearn.model_selection import KFold

behav_dir = '/clmnlab/TM/behav_data/'
subj_list = [
				"TML04_PILOT", "TML05_PILOT", "TML06_PILOT", "TML07_PILOT", "TML08_PILOT"
				,"TML09_PILOT", "TML10_PILOT", "TML11_PILOT",
				"TML12_PILOT", "TML13", "TML14", "TML15", "TML16", "TML18", "TML19"
			]
#subj_list = ["TML19"]
n_subj = len(subj_list)

run1 = 40
run2 = 30
run3 = 30
n_run = run1 + run2 + run3

for subj in subj_list:
    df = pd.read_csv(behav_dir + subj + '/behav_data_Dis.dat', sep='\t', header=None)
    df.columns=['trial', 'Freq.1', 'ISI1', 'Freq.2', 'ISI2', 'decision', 'correctness', 'RT', 'ISI3']
    df['Freq.1_updown.class'] = [-1 if i < 15 else 0 if i == 15.0 else 1 for i in df['Freq.1']]
    df['Freq.2_updown.class'] = [-1 if i < 15 else 0 if i == 15.0 else 1 for i in df['Freq.2']]
    df['Freq.other.index'] = [2 if a == 0 else 1 for a, b in zip(df['Freq.1_updown.class'], df['Freq.2_updown.class'])]
    df['Freq.other_updown.class'] = [a+b for a, b in zip(df['Freq.1_updown.class'], df['Freq.2_updown.class'])]
    df['answer.index'] = [1 if a>b else 2 for a, b in zip(df['Freq.1'], df['Freq.2'])]
    df['Freq.other_answer.class'] = [1 if a==b else -1 for a,b in zip(df['Freq.other.index'],df['answer.index'])]
    df['decision.index'] = [1 if x == 'before' else (2 if x=='after' else 'NaN') for i, x in enumerate(df['decision'])]
    df['Freq.other_decision.class'] = ['NaN' if b=='NaN' else (1 if a==b else -1) for a,b in zip(df['Freq.other.index'],df['decision.index'])]
    #df['Freq.other_decision.class'] = [0 if b=='NaN' else (1 if a==b else -1) for a,b in zip(df['Freq.other.index'],df['decision.index'])]
	# Note, Freq.other_answer.class == Freq.other_updown.class
    validation = df['Freq.other_answer.class'] == df['Freq.other_updown.class']
    assert validation.all() == True
    assert df['Freq.other_answer.class'].shape[0] == n_run
    assert df['Freq.other_decision.class'].shape[0] == n_run

    run = 0
    fin = -1
    for i in [run1, run2, run3]:
        run = run + 1
        ini = fin + 1
        fin = ini + i - 1
        temp = df.loc[ini:fin,['Freq.other.index','Freq.other_updown.class','Freq.other_answer.class','Freq.other_decision.class']]
        temp.to_csv(behav_dir + subj + '/%s.r%02d.Dis_classes_for_svc.dat' %(subj, run), sep='\t')
        
    temp = []
    for i in range(0,n_run,1):
        j = i*2
        temp.insert(j,df.loc[i,'Freq.1'])
        temp.insert(j+1,df.loc[i,'Freq.2'])
    #print(temp,':',len(temp),':',type(temp))
    tt = pd.DataFrame(temp)
    tt.to_csv(behav_dir + subj + '/%s.Dis_freq_order.dat' %(subj), sep='\t', header=None, index=False)

    print('subj %s completed' %(subj))

import pandas as pd

def calc_freq_class(freq_range, freq):
    #freq_range = range(10,20+1,1)
    freqs = [x for x in freq_range]
    #print(freqs)
    f_mid = int((freqs[0]+freqs[-1])*0.5)
    return int(freq - f_mid)

#!pushd \\10.201.185.39\clmnlab
behav_dir = 'Z:/TM/behav_data/'

subj_list = [
            "TML04_PILOT","TML05_PILOT","TML06_PILOT","TML07_PILOT"
            ,"TML08_PILOT","TML09_PILOT","TML10_PILOT","TML11_PILOT"
            ,"TML12_PILOT","TML13","TML14","TML15","TML16","TML18","TML19", "TML20"
            ,"TML21"
            ]
#subj_list = ["TML19"]

n_subj = len(subj_list)
 # low frequency range : 10<= AND 20>=
freq_range = range(10,20+1,1)

run1 = 40
run2 = 30
run3 = 30
n_run = run1 + run2 + run3

for subj in subj_list:
    df = pd.read_csv(behav_dir + subj + '/behav_data_Dis.dat', sep='\t', header=None)
    df.columns=['trial', 'Freq.1', 'ISI1', 'Freq.2', 'ISI2', 'decision', 'correctness', 'RT', 'ISI3']
    df['Freq.1_updown.class'] = [calc_freq_class(freq_range,f) for f in df['Freq.1']]
    df['Freq.2_updown.class'] = [calc_freq_class(freq_range,f) for f in df['Freq.2']]
    df['Freq.other.index'] = [2 if f1==0 else 1 for f1 in df['Freq.1_updown.class']]
    df['Freq.other_updown.class'] = [a+b for a, b in zip(df['Freq.1_updown.class'], df['Freq.2_updown.class'])]
    #df['answer.index'] = [1 if a>b else 2 for a, b in zip(df['Freq.1'], df['Freq.2'])]
    #df['Freq.other_answer.class'] = [1 if a==b else -1 for a,b in zip(df['Freq.other.index'],df['answer.index'])]
    #df['decision.index'] = [1 if x == 'before' else (2 if x=='after' else 'NaN') for i, x in enumerate(df['decision'])]
    #df['Freq.other_decision.class'] = ['NaN' if b=='NaN' else (1 if a==b else -1) for a,b in zip(df['Freq.other.index'],df['decision.index'])]
    
    assert df['Freq.other_updown.class'].shape[0] == n_run
    assert df['Freq.other_updown.class'].sum(0) == 0
    
    run = 0
    fin = -1
    for i in [run1, run2, run3]:
        run = run + 1
        ini = fin + 1
        fin = ini + i - 1
        temp = df.loc[ini:fin,['Freq.other.index','Freq.other_updown.class']]
        temp.to_csv(behav_dir + subj + '/%s.r%02d.Dis_classes_for_svr.dat' %(subj, run), sep='\t')
        #print(temp)
        
#df

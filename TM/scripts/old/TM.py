from scipy import special
from scipy import optimize
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from random import random as rand
from datetime import date
import warnings

warnings.simplefilter(action='ignore', category=FutureWarning)

def curve_fit(subj, ptype):
    ## subj : ex) 'TML01', 'TMH05_pilot', etc.
    ## ptype : 1 = gaussian
    ##         2 = logistic
    ##         3 = Weibull
    ## output = parameters, fitting figure.png
    
    def switch_freq(subj):
        i = subj[2]
        switcher = {
            'L':(10,15,20),
            'H':(25,30,35)
        }
        return switcher.get(i,"Error : Invalid subj ID")

    def greek(letter):
        switcher = {
            'alpha':'\u03B1',   'ALPHA':'\u0391',
            'beta':'\u03B2',    'BETA':'\u0392',
            'gamma':'\u03B3',   'GAMMA':'\u0393',
            'delta':'\u03B4',   'DELTA':'\u0394',
            'epilson':'\u03B5', 'EPSILON':'\u0395',
            'zeta':'\u03B6',    'ZETA':'\u0396',
            'eta':'\u03B7',     'ETA':'\u0397',
            'theta':'\u03B8',   'THETA':'\u0398',
            'iota':'\u03B9',    'IOTA':'\u0399',
            'kappa':'\u03BA',   'KAPPA':'\u039A',
            'lamda':'\u03BB',   'LAMDA':'\u039B',
            'mu':'\u03BC',      'MU':'\u039C',
            'nu':'\u03BD',      'NU':'\u039D',
            'xi':'\u03BE',      'XI':'\u039E',
            'omicron':'\u03BF', 'OMICRON':'\u039F',
            'pi':'\u03C0',      'PI':'\u03A0',
            'rho':'\u03C1',     'RHO':'\u03A1',
            'sigma':'\u03C3',   'SIGMA':'\u03A3',
            'tau':'\u03C4',     'TAU':'\u03A4',
            'phi':'\u03C6',     'PHI':'\u03A6',
            'chi':'\u03C7',     'CHI':'\u03A7',
            'psi':'\u03C8',     'PSI':'\u03A8',
            'omega':'\u03C9',   'OMEGA':'\u03A9'
        }
        return switcher.get(letter, "Error : Invalid letter")

#     root_dir = '/Users/clmn/Desktop/GitHub/labs/TM'
    root_dir = '../'
    behav_dir = root_dir + '/behav_data'

    f_ini, f_mid, f_fin = switch_freq(subj)
    freq_range = range(f_ini,f_fin+1)
    today = date.today().strftime("%Y%m%d")

    ## Psychometric Curve Fitting

    def get_dataframe_DIS(subj):
        subj_behav_datum = behav_dir + '/%s/behav_data_Dis.dat' %subj
        df = pd.read_csv(subj_behav_datum, sep='\t', header=None)
        df.columns=['trial', 'Freq.1', 'ISI1', 'Freq.2', 'ISI2', 'decision', 'correctness', 'RT', 'ISI3']
        df['answer.index'] = [1 if a>b else 2 for a, b in zip(df['Freq.1'], df['Freq.2'])]
        df['decision.index'] = [1 if x == 'before' else (2 if x=='after' else 'NaN') for i, x in enumerate(df['decision'])]

        df['Freq.1.diff'] = [f-f_mid for f in df['Freq.1']]
        df['Freq.2.diff'] = [f-f_mid for f in df['Freq.2']]
        df['Freq.other.diff'] = [a+b for a, b in zip(df['Freq.1.diff'], df['Freq.2.diff'])]
        df['F1<F2.class'] = [np.sign(b-a) for a, b in zip(df['Freq.1'], df['Freq.2'])]
        df['F1<F2.diff'] = [b-a for a, b in zip(df['Freq.1'], df['Freq.2'])]

        return df

    def scatter_x_y(subj):
        df = get_dataframe_DIS(subj)

        diff = np.arange(-5,6) # contrast
        ntrial_per_freq = int(len(df)*0.1)

        da = pd.DataFrame(index = ['prob'], columns = diff)

        for c in diff:
            temp = (df['decision.index'] != 'NaN') & (df['Freq.other.diff'] == c) & (df['answer.index'] == df['decision.index'])
            n = len(df[temp])
            da[c] = n * np.sign(c)
        da = (da/ntrial_per_freq + 1) * 0.5
        prob = np.array(da).reshape(len(diff))
        return diff+f_mid, prob

    def func_ideal_observer(x, a,b,r,k):
        n = f_mid
        return 0.5*(1+special.erf( k/(a*k**r)**(0.5) * (x**b-n**b)/np.sqrt(x**(b*r)+n**(b*r)) ))

    def func_error(x, mu,s):
        ## Error function
        ## 'mu' means mean
        ## 's' means deviation
        return 0.5*(1+special.erf((x-mu)/(np.sqrt(2)*s)))

    def func_logistic(x, a,b):
        ## Logistic function
        ## freeparameter : a, b
        ## 'a' can be interpreted as the 75% threshold
        ## 'b' as a scaling factor that is inversely related to the slope of the psychometric function.
        return special.expit((x-a)/b)

    def func_Weibull(x, a,b):
        ## Weibull cumulative distribution function
        ## 'a' summarises the effect of the stimulus
        ## 'b' reflets to the effect of noise
        g = 0.5 # chance level
        y = []
        for temp in x:
            k = temp - f_mid
            if k > 0:
                y.append(1 - (1-g)*np.exp(-a * (k**b)))
            elif k == 0:
                y.append(g)
            else:
                y.append(g*np.exp(-a * ((-k)**b))) # reverse Weibull cdf
        return np.asarray(y)

    data, prob = scatter_x_y(subj)
    dx = 2**(-4)
    x = np.arange(f_ini,f_fin+dx,dx)

    if ptype == 1:
        ptype = 'gaussian'
        ## error function
        test_func = func_error
        params, params_covariance = optimize.curve_fit(
            test_func, data, prob, maxfev=500,
            p0=[f_mid+5*(rand()-0.5),10*rand()]
        )
        JND=special.erfinv(0.5)*(np.sqrt(2)*params[1]); # JND for 75%
        plt.plot(
            x, test_func(x, params[0],params[1]),
            label='%s=%.3fHz\n%s=%.3fHz\nJND=%.3fHz'%(greek('mu'),params[0],greek('sigma'),params[1],JND)
        )
    elif ptype == 2:
        ptype = 'logistic'
        ## logistic function
        test_func = func_logistic
        a_max, b_max = f_fin, 20.
        params, params_covariance = optimize.curve_fit(
            test_func, data, prob, p0=[f_mid+5*(rand()-0.5),b_max*rand()], maxfev=500,
            bounds=([dx,dx], [a_max,b_max])
        )
        JND = params[1]*np.log(3)+params[0] - f_mid
        plt.plot(x, test_func(x, params[0],params[1]), label='%s=%.3fHz\n%s=%.3fHz\nJND=%.3fHz'%(greek('alpha'),params[0],greek('beta'),params[1],JND))
    elif ptype == 3:
        ptype = 'Weibull'
        ## Weibull function
        test_func = func_Weibull
        a_max, b_max = 5., 2.
        params, params_covariance = optimize.curve_fit(
            test_func, data, prob,
            p0=[a_max*rand(),b_max*rand()],
            maxfev=500,
            bounds=([dx,dx], [a_max,b_max])
        )
        JND = (np.log(2)/params[0])**(1./params[1])
        plt.plot(
            x, test_func(x, params[0],params[1]),
            label='%s=%.3f\n%s=%.3f\nJND=%.3fHz'%(greek('alpha'),params[0],greek('beta'),params[1],JND)
        )
    else:
        ptype = 'invalid'
        print("Invalid plot type!!")

    plt.scatter(x=data,y=prob)
    plt.legend(loc='best')
    plt.ylim([-.1,1.1])

    plt.title(subj + ' / ' + ptype)
    plt.grid()
    plt.savefig(fname=today+'_'+subj+'_'+ptype+'.png',dpi=300)
    
    return params
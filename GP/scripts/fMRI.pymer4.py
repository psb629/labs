#!/usr/bin/env python

from os.path import join
import pandas as pd

import matplotlib.pyplot as plt
import seaborn as sns

from pymer4.utils import get_resource_path
from pymer4.models import Lm, Lmer

dir_result = '/home/sungbeenpark/Github/labs/GP/results'

df = pd.read_csv(join(get_resource_path(), "sample_data.csv"))
print(df.head())

model = Lmer("DV ~ IV1 + (IV2|Group)", data=df)

print(model.fit())

print(model.coefs)

print(model.fixef.head(5))
print(model.ranef.head(5))

print(model.plot_summary())

 #fig.savefig(
 #        join(dir_result, 'pymer4.png'),
 #        dpi=300, facecolor=[1,1,1,0], bbox_inches='tight'
 #)

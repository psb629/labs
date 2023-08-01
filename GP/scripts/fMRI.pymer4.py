#!/usr/bin/env python

from os.path import join
import pandas as pd

from pymer4.utils import get_resource_path
from pymer4.models import Lm

df = pd.read_csv(join(get_resource_path(), "sample_data.csv"))
print(df.head())

model = Lm("DV ~ IV1 + IV2", data=df)

print(model.fit())

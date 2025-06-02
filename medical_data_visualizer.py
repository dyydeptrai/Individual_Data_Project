import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np

# 1
df = pd.read_csv('medical_examination.csv')

# 2
df['overweight'] = (((df['weight']/df['height']**2).round(2))>25).astype(int)

# 3
df['cholesterol']= (df['cholesterol']>1).astype(int)
df['gluc']= (df['gluc']>1).astype(int)
# 4
def draw_cat_plot():
    # 5
    df_cat = pd.melt(df, value_var=['cholesterol', 'gluc', 'smoke', 'alco', 'active', 'overweight'], var_name='Subtances')


    # 6
    df_cat = pd.melt(df, id_var='cardio', value_var=['cholesterol', 'gluc', 'smoke', 'alco', 'active', 'overweight'], var_name='features')
    df_cat=df_cat.groupby(by='cardio').size().reset_index(name='total')
    

    # 7
    sns.catplot(x='features', y='total', data=df_cat)


    # 8
    fig = sns.catplot(x='features', y='total', data=df_cat)


    # 9
    fig.savefig('catplot.png')
    return fig


# 10
def draw_heat_map():
    # 11
    df_heat = df[(df['ap_lo']<=df['ap_hi'])&(df['height']>=df['height'].quantile(0.025))&(df['height']<=df['height'].quantile(0.975))&(df['weight']>=df['weight'].quantile(0.025))&(df['weight']<=df['weight'].quantile(0.975))]

    # 12
    corr = df_heat.corr(numeric_only=True)

    # 13
    mask = np.triu(np.ones_like(corr, dtype=bool))



    # 14
    fig, ax = plt.subplots(figsize={20,10}, ncols=1, nrows=1)

    # 15
    ax=sns.heatmap(corr, mask=mask, annot=True, fmt=".1f", cmap='coolwarm', square=True, linewidths=0.5)



    # 16
    fig.savefig('heatmap.png')
    return fig

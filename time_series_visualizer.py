import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from pandas.plotting import register_matplotlib_converters
register_matplotlib_converters()

# Import data (Make sure to parse dates. Consider setting index column to 'date'.)
df = pd.read_csv('fcc-forum-pageviews.csv', parse_dates='Date', index_col='Date')

# Clean data
df = df[(df['value']>=df['value'].quantile(0.025))&(df['value']<df['value'].quantile(0.975))]


def draw_line_plot():
    # Draw line plot
    plt.plot(df.index, df['value'], 'b')
    plt.xlabel('Date')
    plt.ylabel('Page Views')
    plt.title('Daily freeCodeCamp Forum Page Views 5/2016-12/2019')
    plt.xticks(rotation='90')





    # Save image and return fig (don't change this part)
    fig.savefig('line_plot.png')
    return fig

def draw_bar_plot():
    # Copy and modify data for monthly bar plot
    df_bar = df.copy()
    df_bar['month']=df_bar.index.month
    df_bar['Year']=df_bar.index.year
    df_bar=df_bar.groupby(by=['Year','month']).agg(Average=('value', 'mean'))
    
    
    # Draw bar plot
    plt.plot(df_bar['Year'], df_bar['Average'], 'b')
    plt.xlabel('YEar')
    plt.ylabel('Average Page Views')
    plt.legend(df_bar['month'])
    plt.show()





    # Save image and return fig (don't change this part)
    fig.savefig('bar_plot.png')
    return fig

def draw_box_plot():
    # Prepare data for box plots (this part is done!)
    df_bar = df.copy()
    df_bar['month']=df_bar.index.month
    df_bar['Year']=df_bar.index.year

    fig,ax=plt.subplots(figsize=(20,10), ncols=2)
    sns.boxplot(x=df_bar['month'], y=df_bar['value'], ax=ax[0])
    ax[0].set_xlabel('Month')
    ax[0].set_ylabel('Distribution of Value')
    ax[0].set_title('Month-wise Box Plot (Seasonality)')
    sns.boxplot(x=df_bar['Year'], y=df_bar['value'], ax=ax[1])
    ax[1].set_xlabel('Year')
    ax[1].set_ylabel('Distribution of Value')
    ax[1].set_title('Year-wise Box Plot (Trend)')





    # Save image and return fig (don't change this part)
    fig.savefig('box_plot.png')
    return fig

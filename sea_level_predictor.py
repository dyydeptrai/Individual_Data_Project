import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import linregress

def draw_plot():
    # Read data from file
    df=pd.read_csv('epa-sea-level.csv')


    # Create scatter plot
    plt.scatter(df['Year'], df['CSIRO Adjusted Sea Level'])


    # Create first line of best fit
    line=linregress(df['Year'], df['CSIRO Adjusted Sea Level'])
    x_pred= np.arange(df.Year.min(), 2050)
    y_pred = line.slope*x_pred+line.intercept
    plt.plot(x_pred, y_pred, 'r')
    
    
    


    # Create second line of best fit
    year_2000=df[df['Year']>=2000]
    line=linregress(year_2000['Year'], year_2000['CSIRO Adjusted Sea Level'])
    x_pred=np.arange(year_2000['Year'].min(), 2050)
    y_pred=line.slope*x_pred+line.intercept
    plt.plot(x_pred , y_pred, 'g')


    # Add labels and title
    plt.xlabel('Year')
    plt.ylabel('Sea Level (inches)')
    plt.title('Rise in Sea Level')
    plt.show()
    
    # Save plot and return data for testing (DO NOT MODIFY)
    plt.savefig('sea_level_plot.png')
    return plt.gca()
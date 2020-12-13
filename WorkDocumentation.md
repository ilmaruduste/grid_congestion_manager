*"Practical work is an essential part of learning. We offer you an opportunity to test your newly acquired machine learning skills against real-life problems."*

## The tasks we were given by Eesti Energia (Kristjan Eljand):
  * Prepare the datasets for analysis;
  * Develop a prediction model that forecasts the grid load in specific location based on EV charging statistics.
  * Develop a model for smart charging – a model that divides the electricity consumption of EVs such that the limits of the grid won’t be exceeded and all of the EV owners receive the similar experience.
  * Develop a graphical user interface (GUI) with following functionality: 
    * enables to select a time of day (hour) and location as an input and shows grid load forecast.
    * shows the optimized charging schedule if there is a threat of grid congestion.

## Final presentation: Dec 14 - 16
  * At least one member from the team (can be more than one) makes a presentation about the project.
  * As intermediate presentations, the final presentation will also be held solely online with two practice session leaders grading the presentations over Zoom.
  * You have 5 minutes to make the final presentation
    * In the presentation make sure to introduce your team and project owner (if applicable);
    * Briefly remind us the problem you are trying to solve (say why it needs to be solved);
    * Explain what was your approach to the problem (your methods);
    * Detail results you have obtained and how they match the initial expectations;
    * Lastly, describe a few main lessons that you have learned while working on the project.

## Grading
  * They will grade our presentations based on roughly the following criteria:
    * amount and complexity of work performed (40%),
    * quality of presentation (30%),
    * degree to which you have completed the initial task (25%),
    * being on time (5%).

## Where we got more info:
  * By asking Kristjan Eljand himself:
    * Grids must be connected with nearest charging stations with a straight line (buildings, Emajõgi and everything else is also excluded)
    * Grid baseloads show consumption without ev charging 
    * When a car is charging, then it always uses it's max charging power.
    * We have to face charging problems when they happen (on the same hour) and not predict them.
    * We also asked for more data - we did not get it.
  * By asking Dima:
    * What can be done with such type of data: https://ieeexplore.ieee.org/abstract/document/7796887
    * ARIMA as a baseline
    * With ensembling of multiple LSTMs and MLPs - must make sure, that data is not overfitted
  * By asking other people:
    * With R code, a master's thesis with ARIMA (predicting hospital's patients) https://dspace.ut.ee/bitstream/handle/10062/64858/soll_hanna_liisa_msc_2019.pdf?sequence=1&isAllowed=y
    * Seasonal ARIMA models : https://otexts.com/fpp2/seasonal-arima.html

## What we tried, but did not work:
  * Randomforests
  * Using X and Y coordinates to predict charging need
  
## What we learned in the process about the task:
  * 

## Links with good information:
  * Introduction to Time Series Analysis: Time-Series Forecasting Machine learning Methods & Models https://medium.com/analytics-steps/introduction-to-time-series-analysis-time-series-forecasting-machine-learning-methods-models-ecaa76a7b0e3
  * How (not) to use Machine Learning for time series forecasting: Avoiding the pitfalls https://towardsdatascience.com/how-not-to-use-machine-learning-for-time-series-forecasting-avoiding-the-pitfalls-19f9d7adf424

## What is in the final work:
  * 

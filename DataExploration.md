# Grid Congestion Manager


## Tasks:
 * Prepare the datasets for analysis;
 * Develop a prediction model that forecasts the grid load in specific location based on EV charging statistics.
 * Develop a model for smart charging – a model that divides the electricity consumption of EVs such that the limits of the grid won’t be exceeded and all of the EV owners receive the similar experience.
 * Develop a graphical user interface (GUI) with following functionality: 
   * enables to select a time of day (hour) and location as an input and shows grid load forecast.
 * shows the optimized charging schedule if there is a threat of grid congestion.


## Files
### grid_locations: (alajaamad)
![grid_locations (alajaamad)](https://github.com/ilmaruduste/grid_congestion_manager/blob/main/grid_congestion_data%20pictures/grid_locations.png?raw=true)
  *  address -- address
  *  cadaster -- Cadaster unit based on Maa-amet cadaster definition
  *  latitude -- Geographical latitude
  *  longitude -- Geographical longitude
  *  x -- L-EST97 X axis
  *  y -- L-EST97 Y axis
  *  max_current -- maximum electricity strength (current in kW) allowed at that location. 

### public_chargers_locations:
![public_chargers_locations](https://github.com/ilmaruduste/grid_congestion_manager/blob/main/grid_congestion_data%20pictures/public_chargers_locations.png?raw=true)
  *  address -- address of public charger
  *  cadaster -- Cadaster unit based on Maa-amet cadaster definition
  *  latitude -- Geographical latitude
  *  longitude -- Geographical longitude
  *  x -- L-EST97 X axis
  *  y -- L-EST97 Y axis

### ev_history
![ev_history](https://github.com/ilmaruduste/grid_congestion_manager/blob/main/grid_congestion_data%20pictures/ev_history.png?raw=true)
  *  time -- hour of day.
  *  model -- EV model.
  *  driving -- whether the owner is driving or not.
  *  connected -- whether the EV is connected to the charger or not.
  *  soc -- state-of-charge in kWh (how much energy is in the battery) at the beginning of the ‘time’.
  *  charge_need -- how much energy does the car during the ‘time’. 
  *  cadaster -- cadaster unit number

### ev_home_locations
![ev_home_locations](https://github.com/ilmaruduste/grid_congestion_manager/blob/main/grid_congestion_data%20pictures/ev_home_locations.png?raw=true)
  *  address -- Home location
  *  cadaster -- Cadaster unit based on Maa-amet cadaster definition
  *  latitude -- Geographical latitude
  *  longitude -- Geographical longitude
  *  x -- L-EST97 X axis
  *  y -- L-EST97 Y axis

### gridload
![gridload](https://github.com/ilmaruduste/grid_congestion_manager/blob/main/grid_congestion_data%20pictures/gridload.png?raw=true)
  *  cadaster -- cadaster unit identificator.
  *  time -- hour of day.
  *  baseload -- baseload (electricity current in kWh) at the grid object on that cadaster unit.

### ev_models
![ev_models](https://github.com/ilmaruduste/grid_congestion_manager/blob/main/grid_congestion_data%20pictures/ev_models.png?raw=true)
  *  models -- name of the EV model
  *  battery_size -- the battery size in kW/h
  *  charge_power -- maximum AC charging power in kW
  *  efficiency -- energy consumption kWh/km


### Map of Tartu with ev home locations, public chargers locations and grid locations
![Map of Tartu](https://github.com/ilmaruduste/grid_congestion_manager/blob/main/grid_congestion_data%20pictures/tartu.png?raw=true)
![layers](https://github.com/ilmaruduste/grid_congestion_manager/blob/main/grid_congestion_data%20pictures/layers.png?raw=true)


## Sammud / Steps that were written down in the beginning of the project:

  * Ühendada omavahel laadimisjaamad ja alajaamad / Connect chargers locations and grids locations
  * Peale ühendamist uurida, kuidas laadimine jaamade võrgu koormust mõjutab. / Find out how charging affects gridloads
  * Siit saaks siis edasi ennustamise peale mõelda / Then we can think about predicting
  * Andmed pandasesse lugeda / Read data with pandas
  * Koordinaadid ümardada / Round coordinates
  * Ühendada kodu/avalikud laadijad alajaamadega / Connect home/public chargers and grids
    * kõige lähemasse alajaama / to the closest grids
  * DATA
    * What the model takes in : a grid
    * Training data : ev_history + ev_models


## INSIGHT:

  *  BASELOAD + CHARGING CARS <= MAX CURRENT (POWER)

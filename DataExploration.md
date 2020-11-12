Ülesanded:
Prepare the datasets for analysis;
Develop a prediction model that forecasts the grid load in specific location based on EV charging statistics.
Develop a model for smart charging – a model that divides the electricity consumption of EVs such that the limits of the grid won’t be exceeded and all of the EV owners receive the similar experience.
Develop a graphical user interface (GUI) with following functionality: 
enables to select a time of day (hour) and location as an input and shows grid load forecast.
shows the optimized charging schedule if there is a threat of grid congestion.


Failid:	1
grid_locations:	1
public_chargers_locations:	2
ev_history	2
ev_home locations	2
gridload	3
ev models	3


Failid:
grid_locations: (alajaamad)


address -- address.
cadaster -- Cadaster unit based on Maa-amet cadaster definition.
latitude -- Geographical latitude.
longitude -- Geographical longitude.
x -- L-EST97 X axis.
y -- L-EST97 Y axis.
max_current -- maximum electricity strength (current in kW) allowed at that location. 
public_chargers_locations:

address -- address of public charger
cadaster -- Cadaster unit based on Maa-amet cadaster definition
latitude -- Geographical latitude
longitude -- Geographical longitude
x -- L-EST97 X axis
y -- L-EST97 Y axis

ev_history

time -- hour of day.
model -- EV model.
driving -- whether the owner is driving or not.
connected -- whether the EV is connected to the charger or not.
soc -- state-of-charge in kWh (how much energy is in the battery) at the beginning of the ‘time’.
charge_need -- how much energy does the car during the ‘time’. 
cadaster -- cadaster unit number
ev_home locations

address -- Home location
cadaster -- Cadaster unit based on Maa-amet cadaster definition
latitude -- Geographical latitude
longitude -- Geographical longitude
x -- L-EST97 X axis
y -- L-EST97 Y axis

gridload

cadaster -- cadaster unit identificator.
time -- hour of day.
baseload -- baseload (electricity current in kWh) at the grid object on that cadaster unit.
ev models

models -- name of the EV model
battery_size -- the battery size in kW/h
charge_power -- maximum AC charging power in kW
efficiency -- energy consumption kWh/km


Kaart Tartust



Sammud:

Ühendada omavahel laadimisjaamad ja alajaamad
Uurida Kristjanilt täpsemalt kadastrite kohta

Peale ühendamist uurida, kuidas laadimine jaamade võrgu koormust mõjutab?
Siit saaks siis edasi ennustamise peale mõelda
Andmed pandasesse lugeda
Koordinaadid ümardada
Ühendada kodu/avalikud laadijad alajaamadega
kõige lähemasse alajaama


Küsimused:
Kas laadimisjaamad on seotud geograafiliselt kõige lähema alajaamaga? 
(nt kodu kadastrid ei lange kokku alajaamade omadega)

EV home loc tabelis on kadastrid, kas see viitab alajaama kadastrile? Vist jah 

Kuidas on seotud omavahel kadastrid numbrid ja alajaamad?

Kas gridload.baseload arvestab juba ev_historys toodud laadimistega, või laadimised on lisaks baseloadile?
INSIGHT:

BASELOAD + AUTODE LAADIMINE <= MAX CURRENT (POWER)

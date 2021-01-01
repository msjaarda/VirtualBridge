# Overview

VirtualBridge is a program that is used to answer research questions about the effect of road traffic on bridges in Switzerland.

There are 2 main projects currently underway:
+ OFROU - Updating alpha Factors for SIA 269
+ AGB   - Estimating the Effect of Platooning

The program requires data from a road network to function. There are 2 primary data sources:
+ Weigh-in-Motion [WIM](https://www.astra.admin.ch/astra/fr/home/documentation/donnees-concernant-le-trafic/donnees-et-publications/saisie-poids.html)
+ Swiss Automatic Road Traffic Counts [SARTC](https://www.astra.admin.ch/astra/en/home/documentation/traffic-data/data-and-publication/swiss-automatic-road-traffic-counts--sartc-.html)

Road traffic data is treated/filtered and converted to axle point load data and combined with bridge influence lines to get bridge load effects.
This can be done with WIM data directly, or it can be with simulated vehicles (deriving properties from the WIM vehicles).

A basic framework is given below

![alt text](https://msjaarda.github.io/VirtualBridge/HTML/Frameworkx.png?raw=true)

The main programs within this project are
+ *MATSim*
+ *MATSimWIM*
+ *MATSimAxles*
+ *MATSimDET*

## MATSim
[Q1Investigation](https://msjaarda.github.io/VirtualBridge/HTML/Q1Investigation)  
[Q1Q2Investigation](https://msjaarda.github.io/VirtualBridge/HTML/Q1Q2Investigation)

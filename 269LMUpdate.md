# Updating Alpha Factors for SIA 269

The Eurocode LM1 for traffic loads on bridges features side-by-side tandem axles, as well as uniformly distributed lane loads.

![alt text](https://msjaarda.github.io/VirtualBridge/HTML/SIALM1.png?)

This LM is mirrored in the Swiss code SIA 261, for new structures, as well as SIA 269, for existing structures, where updating is permitted based on existing traffic in the form of updated alpha factors, α1 and α2.
The research herein uses an extensive WIM database to update alpha factors for Swiss traffic. 

For the first (slow) lane, this is done using simple block maxima of tandem axle statistics (daily, weekly, and yearly block maxima results are compared) with log-normal fitting to the extreme value statistic. For the second lane, a novel approach is used which reconstructs real multiple-presence scenarios from the WIM data to predict the total joint load across both lanes. 

Finally, the alpha for small "q" is set through simulations involving jammed traffic.

## LiveScripts
[Q1Investigation](https://msjaarda.github.io/VirtualBridge/HTML/Q1Investigation)  
[Q1Q2Investigation](https://msjaarda.github.io/VirtualBridge/HTML/Q1Q2Investigation)

Some changes have been introduced in version 0.2.0.
In particular, the cycle/step system has been implemented
in order to be able to observe the population mutation
and evolution over time. This system works as follows:
- 	the simulation is performed over a certain number of
	CYCLES. Each cycle is populated by a certain number of 
	creatures, whose goal is to find food in order to survive
	until the end of the cycle (e.g. until the end of the 
	day). Each cycle is divided in a number of STEPS (e.g. a 
	good number is 1000 steps/cycle).
- 	the STEPS are the smallest time unities considered in the
	simulation. At each step, a creature moves of a small
	distance consuming a small amount of energy. The "action" 
	method of the "creature" class is run once every step for
	each creature in the alive population.
-	at the end of each cycle, some creatures are dead due to 
	a complete loss off energy that has happened during the
	steps succession. The creature that are still alive can generate some children that have the same characteristics
	of the parents but are subject to some random mutations
	that slowly modify the creatures leading (hopefully) to 
	some evident mutation in the overall population.
At the end of all the cycles the population is analysed to
understand if - and how - mutations have led to a more
efficient generation of creatures and which are the 
characteristics that made the new creatures more efficient
than the old ones.
myself(generalElectric).

/*
+time(T) [source(S)] : true
    <- .print(S, " just told me ", time(T)).
*/

+engine(Name,Location,Cycles,Provenance) : true
	<- +engine(Name,Location,Cycles,Provenance);
	   .print("New engine ", Name, " at ", Location, 
		      " with ", Cycles, " cycles, and used by ",Provenance);
	   true.

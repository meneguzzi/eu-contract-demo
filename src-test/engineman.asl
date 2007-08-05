{include("print.asl")}

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

+requestMaintenance(10,Plane,Location,Engine) [source(S)] : true
	<- !print(S," is requesting maintenance, screw him!").
{include("print.asl")}

myself(generalElectric).

/*
+time(T) [source(S)] : true
    <- .print(S, " just told me ", time(T)).
*/

+engine(Name,Location,Cycles,Provenance) : true
	<- //+engine(Name,Location,Cycles,Provenance);
	   //!print("New engine ", Name, " at ", Location, " with ", Cycles, " cycles, and used by ",Provenance);
	   
	   true.

@pb2[atomic]
+requestMaintenance(T,Plane,Location,Engine) [source(S)]
	: engine(Engine, Plane, Cycles, Provenance) 
	  //& engine(Replacement, Location, CyclesR, ProvenanceR)
	<- .print(S," just requested maintenance.");
	   !findFreeEngines;
	   !performMaintenance(Plane,Location,Engine);
	   true.

+!performMaintenance(Plane,Location,Engine) 
	: aircraft(Plane, Location) & engine(Engine, Plane, _, _) &
	  engine(Replacement, Location, _, _) & free(Replacement)
	<- .print("Performing maintenance on ",Plane);
	   +testing(Engine);
	   swapEngine(Engine, Replacement, Plane, Location);
	   true.

+!performMaintenance(Plane,Location,Engine)
	: aircraft(Plane, Location) & engine(Engine, Plane, _, _) &
	  engine(Replacement, RepLocation, _, _) & free(Replacement)
	 <- !print("Need to replace ",Engine, " but there's no replacement at ", Location);
	 	.print("Bringing ",Replacement," from ",RepLocation);
	 	moveEngine(Replacement,RepLocation,Location);
	 	+testing(Engine);
	 	swapEngine(Engine, Replacement, Plane, Location);
	 	true.

+!performMaintenance(Plane,Location,Engine) : true
	<- .print("Maintenance failed, something is not right with ",Engine," being in ", Location," or in ", Plane);
	   true.
//*********************************************************
//Helper plans to find engines

@pb1[atomic]
+!findFreeEngines : true
	<- .findall(engine(Engine, Location),
				engine(Engine, Location, _, _),
				Engines);
	   !addFreeEngines(Engines);
	   true.
		
+!addFreeEngines([]) : true
	<- true.

+!addFreeEngines([engine(Engine, Location) | Engines]) : aircraft(Location,_)
	<- -free(Engine);
	   !addFreeEngines(Engines);
	   true.

+!addFreeEngines([engine(Engine, Location) | Engines]) : testing(Engine)
	<- -free(Engine);
	   !addFreeEngines(Engines);
	   true.

+!addFreeEngines([engine(Engine, Location) | Engines]) : true
	<- +free(Engine);
	   .print(Engine, " is free");
	   !addFreeEngines(Engines);
	   true.
{include("print.asl")}

myself(simpleJet).

/* Initial test beliefs
+time(T) : true
    <- .print(time(T));
       .send(engineman, tell, time(T)).

+aircraft(Name,Location) : true
	<- .print("New aircraft ",Name," at ",Location);
		true.
*/

//Plans for gathering data
+aircraft(Name,Location)[target(S)] : myself(S)
  <- //+aircraft(Name,Location);
  	 .print("New aircraft ",Name," at ",Location).

+engine(Engine, Plane, Cycles, Provenance) : aircraft(Plane,_)
  <- //+engine(Engine, Plane, Cycles, Provenance);
  	 .print("New engine ", Name, " at ", Location, 
		      " with ", Cycles, " cycles, and used by ",Provenance).

+scheduledFlight(Time,Operator,Aircraft,Origin,Destination) : myself(Operator)
  <- +scheduledFlight(Time,Operator,Aircraft,Origin,Destination);
  	 .print(Operator, " has a scheduled flight at time ", Time, " using ", 
  	   Aircraft, " from ", Origin, " to ", Destination).
  	   
//***********************************************************************

//Whenever we have a time tick, we need to check our obligations
+time(T) : true
	<- !checkObligations(T).
	
+!checkObligations(T) : true
	<-  //First, check flights
		.findall(flight(Aircraft,Origin,Destination),
				scheduledFlight(T,_,Aircraft,Origin,Destination), Flights);
		!print("Flights at time ", T,": ",Flights);
		!processFlights(Flights);
		!print("Done").

//***********************************************************************
//Plans to fly aircraft

+!processFlights([]) : true
	<- !print("Finished processing flights").

+!processFlights([flight(Aircraft,Origin,Destination)|Tail]) : true
	<- !flyAircraft(Aircraft,Origin,Destination);
	   !processFlights(Tail).

+!flyAircraft(Plane, From, To) : aircraft(Plane,From)
  <- flyPlane(Plane,From,To);
  	 !print("Flying ", Plane," from ", From, " to ",To);
  	 !print("Updating engines.");
  	 !updateEngines(Plane).

-aircraft(Plane,From) : true
  <- -aircraft(Plane,From);
  	 !print("I just took off!").

+!flyAircraft(Plane, From, To) : not aircraft(Plane,From)
  <- !print("Tried to fly ",Plane, " from an invalid location").

+!updateEngines(Plane) : aircraft(Plane,Location)
  <- .findall(engine(Engine,Plane),
  			  engine(Engine, Plane, Cycles, Provenance),
  			  Engines);
  	 !processEngines(Engines);
     true.
  	 
+!processEngines([]) : true
  <- !print("Done processing engines");
  	 true.

+!processEngines([engine(Engine,Plane), Engines]) : engine(Engine, Plane, Cycles, Provenance)
  <- 
     .send(engineman,tell,requestMaintenance(10,Plane,Location,Engine));
     !processEngines(Engines).
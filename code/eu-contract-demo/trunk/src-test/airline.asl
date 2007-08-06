{include("print.asl")}
{include("constants.asl")}

myself(simpleJet).

/* Initial test beliefs
+time(T) : true
    <- .print(time(T));
       .send(engineman, tell, time(T)).
*/

//Plans for gathering data
+aircraft(Name,Location)[target(S)] : myself(S)
  <- //+aircraft(Name,Location);
  	 //!print("New aircraft ",Name," at ",Location);
  	 true.

+engine(Engine, Plane, Cycles, Provenance) : aircraft(Plane,_)
  <- //+engine(Engine, Plane, Cycles, Provenance);
  	 //!print("New engine ", Engine, " at ", Plane, " with ", Cycles, " cycles, and used by ",Provenance);
  	 true.

+scheduledFlight(Time,Operator,Aircraft,Origin,Destination) : myself(Operator)
  <- //+scheduledFlight(Time,Operator,Aircraft,Origin,Destination);
  	 .print(Operator, " has a scheduled flight at time ", Time, " using ", 
  	   Aircraft, " from ", Origin, " to ", Destination).
  	   
//***********************************************************************

//Whenever we have a time tick, we need to check our obligations
+time(T) : true
	<- !checkObligations(T).
	
+!checkObligations(T) : true
	<-  //First, check flights
		!checkFlightObligations(T);
		//Then check the obligations regarding engine maintenance
		!checkEngineMaintenanceObligations(T);
		true.

+!checkFlightObligations(T) : true
	<- .findall(flight(Aircraft,Origin,Destination),
				scheduledFlight(T,_,Aircraft,Origin,Destination), Flights);
		!print("Flights at time ", T,": ",Flights);
		!processFlights(Flights);
		!print("Done").

+!checkEngineMaintenanceObligations(T) : true
	<- .findall(engine(Engine, Plane),
  			  engine(Engine, Plane, _, _),
  			  Engines);
  	   !checkEngineMaintenance(Engines);
  	   true.

//Plans to verify if an engine needs maintenance 
+!checkEngineMaintenance([]) : true
	<- true.

//We only need to check the engine if it is on a plane
+!checkEngineMaintenance([engine(Engine, Plane) | Engines]) : aircraft(Plane,Location)
	<- !print("Engine ",Engine," is in ",Plane);
	   !needsMaintenance(engine(Engine, Plane));
	   !checkEngineMaintenance(Engines).

+!checkEngineMaintenance([engine(Engine, Location) | Engines]) : true
	<- !print("Engine ",Engine," is not on a plane, but on ",Location);
	   !checkEngineMaintenance(Engines).

+!needsMaintenance(engine(Engine,Plane)) 
	: engine(Engine, Plane, Cycles, _) & engineHardLife(Life) &
	  aircraft(Plane,Location) & ((Cycles + 1) == Life) &
	  time(T)
	<- !print(Engine, " is nearing its hard life of ", Life);
	   !sendMaintenanceRequest(T+1,Plane,Location,Engine).

+!needsMaintenance(engine(Engine,Plane)) : engine(Engine, Plane, Cycles, _)
	<- !print(Engine, " does not need maintenance at this time, it has ",Cycles," cycles");
	   true.
	   
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
  <- //-aircraft(Plane,From);
  	 !print("I just took off!").

+!flyAircraft(Plane, From, To) : not aircraft(Plane,From)
  <- !print("Tried to fly ",Plane, " from an invalid location").

//***********************************************************************
//Plans to update engines and request maintenance

+!updateEngines(Plane) : aircraft(Plane,Location)
  <- .findall(engine(Engine, Plane),
  			  engine(Engine, Plane, _, _),
  			  Engines);
  	 !processEngines(Engines);
     true.
  	 
+!processEngines([]) : true
  <- !print("Done processing engines");
  	 true.

+!processEngines([engine(Engine,Plane)| Engines]) 
	: engine(Engine, Plane, Cycles, Provenance) &
	  aircraft(Plane, Location)
  <- //.broadcast(untell, engine(Engine, Plane, Cycles, Provenance));
     //.broadcast(tell, engine(Engine, Plane, (Cycles+1), Provenance));
     updateEngineLog(Engine,Plane,Cycles,Provenance);
     !processEngines(Engines).

+!sendMaintenanceRequest(Time, Plane, Location, Engine) : true
	<- .print("Requesting maintenance for ",Engine," at ", Location);
	   .send(engineman,tell,requestMaintenance(Time,Plane,Location,Engine));
	   true.
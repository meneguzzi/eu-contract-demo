{include("print.asl")}
{include("constants.asl")}
{include("contract.asl")}

//myself(simpleJet).
//contract(rollsJoyce).
//engineManufacturer(engineman)
//contractRestrictions([something,somethingElse]).

/* Initial test beliefs
+time(T) : true
    <- .print(time(T));
       .send(engineman, tell, time(T)).
*/

//*****************************************************************************
//                      Plans for gathering data
//*****************************************************************************
+aircraft(Name, Airline, Location)[target(Airline)] : myself(Airline)
  <- //+aircraft(Name,Location);
  	 //!print("New aircraft ",Name," at ",Location);
  	 true.

+engine(Engine, Plane, Cycles, Provenance) : aircraft(Plane,_,_)
  <- //+engine(Engine, Plane, Cycles, Provenance);
  	 //!print("New engine ", Engine, " at ", Plane, " with ", Cycles, " cycles, and used by ",Provenance);
  	 true.

+scheduledFlight(Time,Operator,Aircraft,Origin,Destination) : myself(Operator)
  <- //+scheduledFlight(Time,Operator,Aircraft,Origin,Destination);
  	 .print(Operator, " has a scheduled flight at time ", Time, " using ", 
  	   Aircraft, " from ", Origin, " to ", Destination).

//*****************************************************************************
//                     Plans for handling contracts
//*****************************************************************************
	   
+!requestContracts : myself(M)
	<- .broadcast(tell,requestContract(M, [maxDownTime(4)]));
	   true.

+acceptContract(Terms) [source(EngineMan)] : true
	<- .print(EngineMan, " accepted my contract.");
	   +engineManufacturer(EngineMan);
	   true.

//*****************************************************************************
//                     Plans for checking obligations
//*****************************************************************************
//Whenever we have a time tick, we need to check our obligations
+time(T) : true
	<- !print("Time is, ",T);
	   !checkObligations(T).
	
//When the system starts, broadcast a request for contracts
/*+!checkObligations(1) : true
	<- .print("Simulation started, sending request for contracts.");
	   !requestContracts;
	   true.*/

+!checkObligations(T) : true
	<-  //First check contract-making obligations
	    !checkContracts(T);
	    //Then, check flights
		!checkFlightObligations(T);
		//Then check the obligations regarding engine maintenance
		!checkEngineMaintenanceObligations(T);
		true.

//*********************************************************
//When the system starts, broadcast a request for contracts
+!checkContracts(1) : true
   <- .print("Simulation started, sending request for contracts.");
	  !requestContracts;
	  true.

+!checkContracts(T) : true
   <- !print("Nothing to be done to contracts at this point");
      true.

+!checkFlightObligations(T) : myself(Airline)
	<- .findall(flight(Aircraft,Origin,Destination),
				scheduledFlight(T, Airline, Aircraft, Origin, Destination), Flights);
		!print("Flights at time ", T,": ",Flights);
		!processFlights(Flights);
		!print("Done").

+!checkEngineMaintenanceObligations(T) : true
	<- .findall(engine(Engine, Plane),
  			  engine(Engine, Plane, _, _),
  			  Engines);
  	   !checkEngineMaintenance(Engines);
  	   true.

//*****************************************************************************
//          Plans to verify if an engine needs maintenance 
//*****************************************************************************

+!checkEngineMaintenance([]) : true
	<- true.

//We only need to check the engine if it is on a plane
+!checkEngineMaintenance([engine(Engine, Plane) | Engines]) 
   : myself(Airline) & aircraft(Plane, Airline, Location)
   <- !print("Engine ",Engine," is in my ",Plane);
	  !needsMaintenance(engine(Engine, Plane));
	  !checkEngineMaintenance(Engines).

+!checkEngineMaintenance([engine(Engine, Location) | Engines]) : true
	<- !print("Engine ",Engine," is not on a plane of mine, but on ",Location);
	   !checkEngineMaintenance(Engines).

//If I have already requested maintenance, there's no need 
//to request again
+!needsMaintenance(engine(Engine,Plane)) 
   : pendingMaintenance(Engine)
   <- !print("Maintenance already requested");
      true.

+!needsMaintenance(engine(Engine,Plane)) 
	: engine(Engine, Plane, Cycles, _) & engineHardLife(Life) &
	  aircraft(Plane,Airline,Location) & ((Cycles + 1) == Life) &
	  time(T)
	<- !print(Engine, " is nearing its hard life of ", Life);
	   !sendMaintenanceRequest(T+1,Plane,Location,Engine);
	   +pendingMaintenance(Engine);
	   //Maybe I should ground a plane after this
	   true.

+!needsMaintenance(engine(Engine,Plane)) : engine(Engine, Plane, Cycles, _)
	<- !print(Engine, " does not need maintenance at this time, it has ",Cycles," cycles");
	   true.

//*********************************************************
//Plans to send maintenance requests and acknowledge 
//maintenance is done

+!sendMaintenanceRequest(Time, Plane, Location, Engine) 
    : engineManufacturer(EngineMan)
   <- .print("Requesting maintenance for ",Engine," at ", Location);
	  //.send(engineman,tell,requestMaintenance(Time,Plane,Location,Engine));
	  //With the proper multi-party plans, we have to check who our partner is
	  //.send(EngineMan,tell,requestMaintenance(Time,Plane,Location,Engine));
	  //With an observer, we have to use the proper plans for that
	  !contractSend(EngineMan,tell,requestMaintenance(Time,Plane,Location,Engine));
	  true.

+maintenanceDone(Time,Plane,Engine) [source(EngineMan)]
    : true
    <- .print("Maintenance is done for ",Engine);
       -pendingMaintenance(Engine);
       true.

//*********************************************************
//Plans to update engines 

+!updateEngines(Plane) : aircraft(Plane, Airline, Location)
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
	  aircraft(Plane, Airline, Location)
  <- //.broadcast(untell, engine(Engine, Plane, Cycles, Provenance));
     //.broadcast(tell, engine(Engine, Plane, (Cycles+1), Provenance));
     updateEngineLog(Engine,Plane,Cycles,Provenance);
     !processEngines(Engines).

//*********************************************************
//If we have an unscheduled event, we should also request
//maintenance
+unscheduledEvent(Time, Engine) 
    : engine(Engine, Plane, Cycles, Provenance) &
      aircraft(Plane, Airline, Location) &
      myself(Airline)
	<- .print("Unscheduled event on ",Engine," at time ",Time);
	   !sendMaintenanceRequest(Time+2,Plane,Location,Engine);
	   +pendingMaintenance(Engine);
	   //Maybe I should ground a plane after this
	   true.

//*****************************************************************************
//                       Plans to fly aircraft
//*****************************************************************************

+!processFlights([]) : true
	<- !print("Finished processing flights").

+!processFlights([flight(Aircraft,Origin,Destination)|Tail]) : true
	<- !flyAircraft(Aircraft,Origin,Destination);
	   !processFlights(Tail).

//Plan to handle grounded aircraft
+!flyAircraft(Plane, From, To) 
   : aircraft(Plane, Airline, From) &
     engine(Engine, Plane, Cycles, Provenance) &
     pendingMaintenance(Engine)
   <- .print(Plane, " is grounded because ",Engine," is pending maintenance");
      true.
	

//Plan to fly an ok aircraft
+!flyAircraft(Plane, From, To) : aircraft(Plane, Airline, From)
  <- flyPlane(Plane,From,To);
  	 !print("Flying ", Plane," from ", From, " to ",To);
  	 !print("Updating engines.");
  	 !updateEngines(Plane).

-aircraft(Plane,Airline, From) : true
  <- //-aircraft(Plane,Airline, From);
  	 !print("I just took off!").

+!flyAircraft(Plane, From, To) : not aircraft(Plane, Airline, From)
  <- !print("Tried to fly ",Plane, " from an invalid location").
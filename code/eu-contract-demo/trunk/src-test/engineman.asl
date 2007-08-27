{include("print.asl")}
{include("constants.asl")}
{include("contract.asl")}

//myself(generalElectric).
//preferredPartner(simpleJet).

/*
+time(T) [source(S)] : true
    <- .print(S, " just told me ", time(T)).
*/

+engine(Name,Location,Cycles,Provenance) : true
	<- //+engine(Name,Location,Cycles,Provenance);
	   //!print("New engine ", Name, " at ", Location, " with ", Cycles, " cycles, and used by ",Provenance);
	   true.

//*****************************************************************************
//                    Plans for checking obligations
//*****************************************************************************
+time(T) : true
   <- !print("Time is, ",T);
      !checkObligations(T).
      
+!checkObligations(T) : true
   <- !print("Checking obligations");
      //First check for maintenance obligations
      !checkMaintenanceObligations(T);
      true.

//*****************************************************************************
//                    Plans for handling contracts
//*****************************************************************************
+requestContract(A, Terms) [source(Airline)] : true
	<- .print(Airline, " is requesting a contract, with terms: ", Terms);
	   !evaluateContract(Airline, Terms);
	   true.

+!evaluateContract(Airline, Terms) : preferredPartner(Airline)
	<- .print("I like ", Airline, " accepting contract.");
	   !acceptContract(Airline);
	   true.

+!evaluateContract(Airline, Terms) : true
	<- .print(Airline, " is not my preferred partner, not accepting the contract.");
	   true.

//Accepts the contract, signs it (in theory), and sends confirmation to the
//Airline
+!acceptContract(Airline) : true
	<- //.send(Airline, tell, acceptContract(Myself,[]));
	   //Changes to allow the observer to be notified
	   !contractSend(Airline, tell, acceptContract([]));
	   +airline(Airline);
	   true.

//*****************************************************************************
//                         Engine Maintenance plans
//*****************************************************************************

//*******************************************
//Plans to respond to a maintenance request 
@pb2[atomic]
+requestMaintenance(T,Plane,Location,Engine) [source(S)]
   : true
   <- .print(S," just requested maintenance.");
	   !addRequest(T,Plane,Location,Engine,S).

+!addRequest(T,Plane,Location,Engine,Airline) 
   : maintenanceRequest(T,Plane,Location,Engine,Airline)
   <- !print("Request already made ");
      true.

+!addRequest(T,Plane,Location,Engine,Airline) : airline(Airline)
   <- !print("Queueing request");
      +maintenanceRequest(T,Plane,Location,Engine,Airline);
      true.

+!addRequest(T,Plane,Location,Engine,Airline) : true
   <- !print("I do not have a contract with ",Airline);
      true.

/*
@pb2[atomic]
+requestMaintenance(T,Plane,Location,Engine) [source(S)]
	: engine(Engine, Plane, Cycles, Provenance) 
	<- .print(S," just requested maintenance.");
	   !performMaintenance(Plane,Location,Engine);
	   true.
*/

//**************************************************
//Plans to find and process maintenance obligations

+!checkMaintenanceObligations(T) : true
   <- .findall(request(T,Plane,Location,Engine,Airline),
  			  maintenanceRequest(T,Plane,Location,Engine,Airline),
  			  Requests);
      !processMaintenanceObligations(Requests);
      true.

+!processMaintenanceObligations([]) : true
   <- !print("Finished processing obligations");
      true.

+!processMaintenanceObligations([request(T,Plane,Location,Engine,Airline) | Requests])
   : engine(Engine, Plane, Cycles, Provenance)
   <- !findFreeEngines;
      !performMaintenance(Plane,Location,Engine);
      -maintenanceRequest(T,Plane,Location,Engine,Airline);
      !sendMaintenanceDone(Plane,Engine,Airline);
      !processMaintenanceObligations(Requests);
      true.

+!processMaintenanceObligations([request(T,P,L,E,A) | Requests])
   : true
   <- !print("Problem dealing with ",request(T,P,L,E,A));
      !processMaintenanceObligations(Requests);
      true.

+!sendMaintenanceDone(Plane,Engine,Airline) : time(Time)
   <- .print("Informing ",Airline," maintenance is done for ", Engine," at ",Plane);
      !contractSend(Airline,tell,maintenanceDone(Time,Plane,Engine));
      true.

//*********************************************************
//Plans to actually perform maintenance

+!performMaintenance(Plane,Location,Engine) 
	: aircraft(Plane, Airline, Location) & engine(Engine, Plane, _, _) &
	  engine(Replacement, Location, _, _) & free(Replacement)
	<- .print("Performing maintenance on ",Plane);
	   +testing(Engine);
	   swapEngine(Engine, Replacement, Plane, Location);
	   true.

+!performMaintenance(Plane,Location,Engine)
	: aircraft(Plane, Airline, Location) & engine(Engine, Plane, _, _) &
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

+!addFreeEngines([engine(Engine, Location) | Engines]) : aircraft(Location, _, _)
	<- -free(Engine);
	   !addFreeEngines(Engines);
	   true.

+!addFreeEngines([engine(Engine, Location) | Engines]) : testing(Engine)
	<- -free(Engine);
	   !addFreeEngines(Engines);
	   true.

+!addFreeEngines([engine(Engine, Location) | Engines]) : true
	<- +free(Engine);
	   !print(Engine, " is free");
	   !addFreeEngines(Engines);
	   true.
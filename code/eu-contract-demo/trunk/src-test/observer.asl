{include("print.asl")}
{include("constants.asl")}
//logging(true).

//*****************************************************************************
//                      Plans for the observer
//*****************************************************************************

//*********************************************************
//Plans to echo information
+trigger(Type,TriggerDeadline) : true
   <- !print("Adding ",trigger(Type,TriggerDeadline)).


//*********************************************************
//Inform everyone that I am the observer
+time(0) : true
   <- .print("Telling everyone that I am the observer.");
      .broadcast(tell,observer);
	  true.

//When someone broadcasts a need for an observer
+needObserver [source(Peer)] : true
   <- !print(Peer, "needs an observer, replying");
      .send(Peer, tell, observer);
	  true.

+message(From,To,Message) [source(From)] : true
   <- !print(From, " sent ", Message, " to ", To);
      !handleMessage(Message, From, To);
      true.

//*****************************************************************************
//                Plans for detecting contract violations
//*****************************************************************************
@pb1[atomic]
+time(T) : true
   <- !checkContractViolations(T);
      //What else should the observer check?
      true.

+!checkContractViolations(T) : true
   <- !checkMaintenanceTriggers(T);
      //What other triggers?      
      true.

+!checkMaintenanceTriggers(T) : trigger(maintenance,T)
   <- .findall(maintenance(Time,Plane,Engine),
				maintenanceRequested(Time,Plane,Location,Engine,From,To),
				Requests);
	  //!print("Checking ",Requests);
	  !checkMaintenanceRequests(Requests);
	  true.

+!checkMaintenanceTriggers(T) : true
   <- !print("No contract maintenance triggers at time ",T).

+!checkMaintenanceRequests([]) : true
   <- !print("Done checking maintenance requests").

+!checkMaintenanceRequests([Request | Requests]) : true
   <- !checkMaintenanceDone(Request);
      !checkMaintenanceRequests(Requests).

+!checkMaintenanceDone(maintenance(Time,Plane,Engine)) 
   : maintenanceRequested(Time,Plane,Location,Engine,From,To) &
     maintenancePerformed(TimeDone,Plane,Location,Engine2,To,From) &
     time(Now) &
     (TimeDone < Now)
   <- .print("Maintenance of ",Plane," at ",Location," for ",From," by ", To," done.");
      true.

+!checkMaintenanceDone(maintenance(Time,Plane,Engine)) 
   : maintenanceRequested(Time,Plane,Location,Engine,From,To) &
     time(Now)
   <- .print("Maintenance of ",Plane," at ",Location," for ",From," by ", To, " not done on time");
      .print("Informing manager of violation");
      //I need to modularise this message sending thing
      .send(manager, tell, violation(maintenance(Now),To,From));
      true.
//*****************************************************************************
//                Plans for handling specific messages
//*****************************************************************************

//Handles requests for maintenance
+!handleMessage(requestMaintenance(Time,Plane,Location,Engine), From, To) : true
   <- !print("Handling request for maintenance from ",From," to ", To);
      //When we hear a maintenance request, we store the request
      +maintenanceRequested(Time,Plane,Location,Engine,From,To);
      ?maintenanceDeadline(Deadline);
      TriggerDeadline = Time+Deadline;
      +trigger(maintenance,TriggerDeadline);
      true.

//Handle contract acceptance
+!handleMessage(acceptContract(Terms), From, To) : true
   <- !print("Handling contract acceptance from ",From," to ",To);
      +contract(From, To, Terms);
      true.

//Handle maintenance done
+!handleMessage(maintenanceDone(Time,Plane,Engine), From, To) 
   : maintenanceRequested(TimeRequested,Plane,Location,Engine,To,From)
   <- !print("Handling maintenance done from ",From," to ",To);
      +maintenancePerformed(Time,Plane,Location,Engine,From,To);
      true.

+!handleMessage(maintenanceDone(Time,Plane,Engine), From, To) : true
   <- !print(From, " reported maintenance done without being requested from ",From);
      true.

//Fallback plan
+!handleMessage(Message, From, To) : true
   <- !print("Don't know how to handle message: ", Message);
      true.

//*****************************************************************************
//                   Plans for querying contracts
//*****************************************************************************
//+?obligationDeadline(Party1, Party2, Obligation, Deadline) : true
//   <- true.

//This plan is not working as a means to query a contract
+?obligationDeadline(Party1, Party2, Obligation, Deadline) 
   : maintenanceDeadline(Deadline)
   <- true.

//*****************************************************************************
//                   Plans for the contracting phase
//*****************************************************************************
@observerPlan3[atomic]
+contract(From, To, Terms) : contract(From2, To2, Terms2) &
                             not(From = From2) & not(To = To2)
   <- !printContractingPhaseDone;
      true.

@observerPlan2[atomic]
+contract(From, To, Terms) : true
   <- true.
//Super-fancy printing of asterisks to denote that all contracts have been signed
@observerPlan1[atomic]
+!printContractingPhaseDone : true
   <- .println("*************************************************************");
      .println("             Contracting Phase Done                          ");
	  .println("*************************************************************");
	  true.
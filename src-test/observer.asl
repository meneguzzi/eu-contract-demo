{include("print.asl")}
{include("constants.asl")}
logging(true).

//Plans for the observer

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

//Plans for handling messages

//Handles requests for maintenance
+!handleMessage(requestMaintenance(Time,Plane,Location,Engine), From, To) : true
   <- !print("Handling request for maintenance from ",From," to ", To);
      true.

//Handle contract acceptance
+!handleMessage(acceptContract(Terms), From, To) : true
   <- !print("Handling contract acceptance from ",From," to ",To);
      +contract(From, To, Terms);
      true.

//Fallback plan
+!handleMessage(Message, From, To) : true
   <- !print("Don't know how to handle message: ", Message);
      true.

	  
//Contracting phase plans
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
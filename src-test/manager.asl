{include("print.asl")}
{include("constants.asl")}
//logging(true).

//*****************************************************************************
//                                  Manager plans
//*****************************************************************************

//*********************************************************
//Violation handing mechanisms

+violation(Violation,From,To) [source(S)] : true
   <- !print("Handling ",Violation," from ", From, " to ", To);
      !handleViolation(Violation,From,To);
      true.

@managerPlan[atomic]
+!handleViolation(maintenance(Time),From,To) : true
   <- .println("*********************  Violation  *********************************");
      .println(From, " should have done maintenance for ",To," by time ",Time,", but it did not.");
      .println("*******************************************************************");
      true.

+endSimulation : true
	<- .print("Ending simulation in 5 seconds.");
	   .wait(5000);
	   .stopMAS.
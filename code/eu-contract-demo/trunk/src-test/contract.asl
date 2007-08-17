//Contract-related library of plans
//Some of these plans ought to be done using internal actions, to ensure compliance

//Helper method to detect an agent's own name
+?myself(Name) : true
   <- .my_name(Name).

//Communication related plans
@contractPlan[atomic]
+!contractSend(Target,SpeechAct,Message) : true
   <- .send(Target, SpeechAct, Message);
      !notifyObserver(Target,SpeechAct,Message);
      true.

+!notifyObserver(Target,SpeechAct,Message) : observer(Observer)
   <- ?myself(From);
      .send(Observer, tell, message(From,Target,Message));
	  true.

//When there is no observer, we don't need to send a message to anyone
+!notifyObserver(Target,SpeechAct,Message) : true
   <- true.
	  
//Observer-related tasks
//Plans to detect an observer
+?findObserver(Observer) : true
   <- .broadcast(tell,needObserver);
      true.
	  
//The observer will reply with this message
+observer [source(Observer)] : true               
   <- +observer(Observer);
      true.

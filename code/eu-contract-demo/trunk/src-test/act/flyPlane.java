package act;

import jason.asSyntax.Literal;
import jason.asSyntax.Term;
import jason.environment.Environment;

import java.util.List;
import java.util.logging.Logger;

import org.ist.contract.jason.ContractEnvironmentImpl;
import org.kcl.jason.env.action.ExternalAction;

public class flyPlane implements ExternalAction<ContractEnvironmentImpl> {
	private static final Logger logger = Logger.getLogger(ExternalAction.class.getName());

	public List consequences(ContractEnvironmentImpl env, String agName, Term... terms) {
		// TODO Auto-generated method stub
		return null;
	}

	public boolean execute(ContractEnvironmentImpl env, String agName, Term... terms) {
		//logger.info("Takeoff*******************");
		if(terms.length != 3) {
			logger.warning("flyPlane action requires three parameters");
			return false;
		} else {
			/*Literal aircraft = Literal.parseLiteral("aircraft("+terms[0]+","+terms[1]+")");
			if(!env.getPercepts("").contains(aircraft)){
				logger.warning(terms[0]+" is not at "+terms[1]);
				return false;
			} else {
				env.removePercept(aircraft);
			}*/
			Literal aircraft = Literal.parseLiteral("aircraft("+terms[0]+","+terms[1]+")");
			env.removePercept(agName, aircraft);
			aircraft = Literal.parseLiteral("aircraft("+terms[0]+","+terms[2]+")");
			env.addPercept(agName, aircraft);
		}
		return true;
	}

	public String getFunctor() {
		return "flyPlane";
	}

}

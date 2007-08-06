package act;

import jason.asSyntax.Literal;
import jason.asSyntax.Term;

import java.util.List;

import org.ist.contract.jason.ContractEnvironmentImpl;
import org.kcl.jason.env.action.ExternalAction;

/**
 * External action to move an engine from one place to another
 * @author meneguzz
 *
 */
public class moveEngine implements ExternalAction<ContractEnvironmentImpl> {

	public List<Literal> consequences(ContractEnvironmentImpl env, String agName, Term... terms) {
		// TODO Auto-generated method stub
		return null;
	}

	public boolean execute(ContractEnvironmentImpl env, String agName, Term... terms) {
		if(terms.length != 3) {
			logger.warning("swapEngine action requires three parameters");
			return false;
		}
		//terms[0] - Engine
		//terms[1] - Location
		//terms[2] - NewLocation
		
		List<Literal> query = env.findPercepts(Literal.parseLiteral("engine("+terms[0]+","+terms[1]+", Cycles, Provenance)"));
		if(query.size() == 0) {
			logger.warning("Could not find "+terms[0]+" at "+terms[1]);
			return false;
		}
		Literal engine = query.get(0);
		//logger.info("Removing "+engine);
		env.removePercept(engine);
		
		Literal newEngine = Literal.parseLiteral("engine("+terms[0]+","+terms[2]+","+engine.getTerm(2)+", "+engine.getTerm(3)+")");
		//logger.info("Adding "+newEngine);
		env.addPercept(newEngine);
		
		return false;
	}

	public String getFunctor() {
		return "moveEngine";
	}

}

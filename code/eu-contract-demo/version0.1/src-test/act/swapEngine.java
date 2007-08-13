package act;

import jason.asSyntax.Literal;
import jason.asSyntax.Term;

import java.util.List;

import org.ist.contract.jason.ContractEnvironmentImpl;
import org.kcl.jason.env.action.ExternalAction;

/**
 * swapEngine(Engine, Replacement, Plane, Location);
 * @author meneguzz
 *
 */
public class swapEngine implements ExternalAction<ContractEnvironmentImpl> {

	public List<Literal> consequences(ContractEnvironmentImpl env, String agName, Term... terms) {
		// TODO Auto-generated method stub
		return null;
	}

	public boolean execute(ContractEnvironmentImpl env, String agName, Term... terms) {
		if(terms.length != 4) {
			logger.warning("swapEngine action requires four parameters");
			return false;
		}
		
		logger.info("Replacing "+terms[0]+" at "+terms[2]+", for "+terms[1]+" at "+terms[3]);
		
		// terms[0] - Engine
		// terms[1] - Replacement (Engine)
		// terms[2] - Plane
		// terms[3] - Location
		
		List<Literal> query = env.findPercepts(Literal.parseLiteral("engine("+terms[0]+","+terms[2]+", Cycles, Provenance)"));
		if(query.size() == 0) {
			logger.warning("Could not find "+terms[0]+" at "+terms[2]);
			return false;
		}
		Literal originalEngine = query.get(0);
		
		query = env.findPercepts(Literal.parseLiteral("engine("+terms[1]+","+terms[3]+", Cycles, Provenance)"));
		if(query.size() == 0) {
			logger.warning("Could not find "+terms[1]+" at "+terms[3]);
			return false;
		}
		Literal replacementEngine = query.get(0);
		
		Literal newEngine = Literal.parseLiteral("engine("+terms[1]+","+terms[2]+", "+replacementEngine.getTerm(2)+", "+replacementEngine.getTerm(3)+")");
		Literal oldEngine = Literal.parseLiteral("engine("+terms[0]+","+terms[3]+", "+originalEngine.getTerm(2)+", "+originalEngine.getTerm(3)+")");
		
		//logger.info("Removing: "+originalEngine+" and "+replacementEngine);
		
		env.removePercept(originalEngine);
		env.removePercept(replacementEngine);
		
		//logger.info("Adding: "+newEngine+" and "+oldEngine);
		env.addPercept(newEngine);
		env.addPercept(oldEngine);
		
		return true;
	}

	public String getFunctor() {
		return "swapEngine";
	}

}

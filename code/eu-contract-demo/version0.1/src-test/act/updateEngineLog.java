package act;

import jason.asSyntax.Literal;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.NumberTermImpl;
import jason.asSyntax.Term;

import java.util.List;

import org.ist.contract.jason.ContractEnvironmentImpl;
import org.kcl.jason.env.action.ExternalAction;

public class updateEngineLog implements ExternalAction<ContractEnvironmentImpl> {

	public List<Literal> consequences(ContractEnvironmentImpl env, String agName, Term... terms) {
		// TODO Auto-generated method stub
		return null;
	}

	public boolean execute(ContractEnvironmentImpl env, String agName, Term... terms) {
		if(terms.length != 4) {
			logger.warning("updateEngineLog action requires four parameters");
			return false;
		}
		
		//terms[0] - Engine
		//terms[1] - Location
		//terms[2] - Cycles
		//terms[3] - Provenance
		
		//logger.info("Updating log for "+terms[0]+" at "+terms[1]);
		if(!terms[2].isNumeric()) {
			logger.warning("I was expecting a numberic term, but got "+terms[2]);
			return false;
		}
		NumberTerm cycles = (NumberTerm) terms[2];
		cycles = new NumberTermImpl((cycles.solve()+1));

		Literal newEngine = Literal.parseLiteral("engine("+terms[0]+","+terms[1]+","+cycles+","+terms[3]+")");
		Literal oldEngine = Literal.parseLiteral("engine("+terms[0]+","+terms[1]+","+terms[2]+","+terms[3]+")");
		boolean bRet = true;
		//logger.info("Removing "+oldEngine);
		bRet &= env.removePercept(oldEngine);
		//logger.info("Adding "+newEngine);
		env.addPercept(newEngine);
		
		return bRet;
	}

	public String getFunctor() {
		return "updateEngineLog";
	}

}

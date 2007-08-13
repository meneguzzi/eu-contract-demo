package org.ist.contract.agent;

import org.ist.contract.Observable;

public interface ObserverAgent extends Agent {
	/**
	 * A contract event happenned.
	 * @param source
	 * @param type
	 * @param accessionID
	 */
	public void contractEvent(Observable source, int type, String accessionID); 
}

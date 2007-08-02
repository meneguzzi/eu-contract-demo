package org.ist.contract.store.simple;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.ist.contract.agent.ObserverAgent;
import org.ist.contract.model.Contract;
import org.ist.contract.store.ContractStore;
import org.ist.contract.store.SearchQuery;
import org.ist.contract.store.SearchResult;

/**
 * A simple implementation of a contract store.
 * @author meneguzz
 *
 */
public class SimpleContractStore implements ContractStore {
	public enum EventType {CHANGE, STORE};
	
	protected HashMap<String, Contract> contractMap;
	
	protected List<ObserverAgent> observerList;
	
	public SimpleContractStore() {
		this.contractMap = new HashMap<String, Contract>();
		this.observerList = new ArrayList<ObserverAgent>();
	}

	public boolean change(String accessionID, Contract contract) {
		if(contractMap.containsKey(accessionID)) {
			contractMap.put(accessionID, contract);
			this.notifyObservers(EventType.CHANGE, accessionID);
			return true;
		} else {
			return false;
		}
	}

	public Contract retrieve(String accessionID) {
		return contractMap.get(accessionID);
	}

	public SearchResult search(SearchQuery criteria) {
		// TODO Auto-generated method stub
		return null;
	}

	public void store(Contract contract, String accessionID) {
		if(!contractMap.containsKey(accessionID)) {
			contractMap.put(accessionID, contract);
			this.notifyObservers(EventType.STORE, accessionID);
		} else {
			//TODO throw an exception
		}
	}

	public void addObserver(ObserverAgent observer) {
		this.observerList.add(observer);
	}

	/**
	 * Notifies all observer agents of an event in this contract store
	 * @param type
	 * @param accessionID
	 */
	protected void notifyObservers(EventType type, String accessionID) {
		for(ObserverAgent agent : observerList) {
			agent.contractEvent(this, type.ordinal(), accessionID);
		}
	}
}

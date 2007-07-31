package org.ist.contract.store;

import org.ist.contract.Observable;
import org.ist.contract.model.Contract;

public interface ContractStore extends Observable {

	/**
	 * @param contract
	 *            TODO
	 * @param accessionID
	 *            TODO
	 */
	public abstract void store(Contract contract, String accessionID);

	/**
	 */
	public abstract Contract retrieve(String accessionID);

	/**
	 */
	public abstract SearchResult search(SearchQuery criteria);

	/**
	 */
	public abstract boolean change(String accessionID, Contract contract);

}

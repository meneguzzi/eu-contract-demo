package org.ist.contract.model;

import java.util.Iterator;

/**
 * @uml.dependency   supplier="org.ist.contract.model.ContractElement"
 */
public interface Contract extends Iterable<ContractElement>{

	/**
	 */
	public abstract Iterator getContext();

	/**
	 */
	public abstract Iterator getClauses();

	/**
	 */
	public abstract Iterator getParties();

		
		/**
		 */
		public abstract boolean isTemplate();
		

}

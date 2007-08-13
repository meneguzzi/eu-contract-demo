package org.ist.contract.model;

public interface ContractElement {

	/**
	 */
	public abstract boolean isContext();

	/**
	 */
	public abstract boolean isClause();

	/**
	 */
	public abstract ElementType getType();

	/**
	 */
	public abstract ElementValue getValue();

	/**
	 */
	public abstract boolean isParty();

	/**
	 */
	public abstract boolean isRole();

		
		/**
		 */
		public abstract String getId();

			
			/**
			 */
			public abstract boolean isObligation();

				
				/**
				 */
				public abstract boolean isProhibition();
				
			
		

}

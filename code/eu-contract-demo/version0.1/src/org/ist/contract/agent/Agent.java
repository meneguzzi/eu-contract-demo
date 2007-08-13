package org.ist.contract.agent;

import org.ist.contract.model.Contract;


public interface Agent {

		
		/**
		 */
		public abstract void storeContract(Contract contract);

			
			/**
			 */
			public abstract void sendMsg();


				
				/**
				 */
				public abstract void getMsg();


					
					/**
					 */
					public abstract void perceive();
					
				
			
		

}

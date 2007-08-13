package org.ist.contract.store;

import org.ist.contract.Observable;
import org.ist.contract.model.ContractTemplate;



public interface TemplateStore extends Observable {

		
		/**
		 */
		public abstract void publish(String id, ContractTemplate contractTemplate);

			
			/**
			 */
			public abstract SearchResult search(SearchQuery query);
			
		

}

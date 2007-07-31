package org.ist.contract.lostwax;

import java.io.IOException;
import java.util.List;


public interface EventGenerator {

		
		/**
		 * Reads a script with the LostWax simulation events for the next execution.
		 * 
		 * @param filename The file from which the script will be read.
		 */
		public void readScript(String filename) throws IOException;
		
		/**
		 * Return a list with the events to take place in the next simulation
		 * cycle.
		 * @return
		 */
		public List<String> getNextEvents();
}

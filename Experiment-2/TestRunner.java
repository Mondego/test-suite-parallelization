import org.junit.runner.JUnitCore;
import org.junit.runner.Request;
import org.junit.runner.Result;
import java.lang.ClassNotFoundException;
import org.junit.runner.notification.Failure;
import java.util.List;

public class TestRunner {
    public static void main(String... args) throws ClassNotFoundException {
    	long startTime = System.nanoTime();
    	
    	String result = "";
    	double totalTimeInSecond = 0.0;
    	String log = "NONE";

        try {

	    	String classFqn = args[0].substring(0, args[0].lastIndexOf('.'));
	    	String method = args[0].substring(args[0].lastIndexOf('.') + 1);

	    	Request request = Request.method(Class.forName(classFqn), method);

	        Result r = new JUnitCore().run(request);

	        result = (r.wasSuccessful() ? "SUCCESSFUL" : "FAILURE");

	        totalTimeInSecond = r.getRunTime() / 1000.0; // returns time in MS

	        if (!r.wasSuccessful()) {

	        	String LOG = "";
	        	
	        	List<Failure> failures = r.getFailures();
	        	for (int i = 0; i < failures.size(); i++) {
	        		LOG += failures.get(i).getMessage();
	        		System.out.println(" ********* " + LOG);
	        		LOG += ",";
	        		//LOG = LOG.replaceAll("[","("); // needed for grep
	        		//LOG = LOG.replaceAll("]",")");	
	        	}
	        	
	        	log = LOG;
	        	System.out.println(LOG);
	        }
	        
    	} catch(Exception e) {
    		result = "FAILURE";
    		log = e.getMessage().toString();
    	} 

    	finally {
    		long endTime   = System.nanoTime();
    		
    		// If the test was not run at all
    		if (totalTimeInSecond == 0.0) {
    			result = "FAILURE";
    			long totalTime = endTime - startTime;
    			totalTimeInSecond = totalTime / 1000000000.0;
    			log = "UNKNOWN";
    		}

    		System.out.println(result);
    		System.out.println(totalTimeInSecond);
    		System.out.println(log);
    	}
    }
}


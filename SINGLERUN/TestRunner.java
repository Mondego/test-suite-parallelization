import org.junit.runner.JUnitCore;
import org.junit.runner.Request;
import org.junit.runner.Result;
import java.lang.ClassNotFoundException;

public class TestRunner {
    public static void main(String... args) throws ClassNotFoundException {
    	long startTime = System.nanoTime();
    	double totalTimeInSecond = 0;
        try {

	    	String classFqn = args[0].substring(0, args[0].lastIndexOf('.'));
	    	String method = args[0].substring(args[0].lastIndexOf('.') + 1);

	    	Request request = Request.method(Class.forName(classFqn), method);

	        Result result = new JUnitCore().run(request);

	        System.out.println(result.wasSuccessful() ? "SUCCESSFUL" : "FAILURE");

	        totalTimeInSecond = result.getRunTime() / 1000.0; // returns time in MS

	        System.out.println(result.getRunTime());

	        if (!result.wasSuccessful()) {
	        	String LOG = result.getFailures();
	        	LOG = LOG.replaceAll('[','(');
	        	LOG = LOG.replaceAll(']',')');
	        	System.out.println(LOG);
	        }
	        
    	} catch(Exception e) {
    		System.out.println("FAILURE");
    		System.out.println(e.getMessage());
    	} 

    	finally {
    		long endTime   = System.nanoTime();
    		
    		// If the test was not run at all
    		if (totalTimeInSecond == 0) {
    			System.out.println("FAILURE/ERROR");
    			long totalTime = endTime - startTime;
    			System.out.println(totalTime / 1000000000.0);
    			System.out.println("UNKNOWN");
    		}
    	}
    }
}


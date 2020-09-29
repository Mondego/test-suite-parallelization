package uci.ics.mondego.testrunner.maven;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;

import uci.ics.mondego.testrunner.tool.Constants;

public final class SurefireMojoInterceptor extends AbstractMojoInterceptor {
    static final String UNSUPPORTED_SUREFIRE_VERSION_EXCEPTION = "Unsupported surefire version. ";
    
    public static void execute(Object mojo) throws Exception {
        if (!isSurefirePlugin(mojo)) {
            return;
        }
        if (isAlreadyInvoked(mojo)) {
            return;
        }
        checkSurefireVersion(mojo);
        try {
        	updateForkCounts(mojo);
        	updateThreadCounts(mojo);
        	updateTests(mojo);
        } catch (Exception ex) {
        	throw new Exception(UNSUPPORTED_SUREFIRE_VERSION_EXCEPTION);
        }
    }

    private static boolean isSurefirePlugin(Object mojo) throws Exception {
        return mojo.getClass().getName().equals(Constants.SUREFIRE_PLUGIN_BIN);
    }

    private static boolean isAlreadyInvoked(Object mojo) throws Exception {
        String key = Constants.TLDR_NAME + System.identityHashCode(mojo);
        String value = System.getProperty(key);
        System.setProperty(key, "TLDR-invoked");
        return value != null;
    }

    private static void checkSurefireVersion(Object mojo) throws Exception {
    	
    	try {
            getField(Constants.TEST_FIELD, mojo);
        } catch (NoSuchMethodException ex) {
        	throw new Exception(
        			UNSUPPORTED_SUREFIRE_VERSION_EXCEPTION
                    + "Try setting Tests in the surefire configuration.");
        }
    }
    
    private static void updateTests(Object mojo) throws Exception {
        logger.log(Level.FINE, "updating Tests");
        String testsToRun = System.getProperty(Constants.TLDR_TEST_PROPERTY);      		
        setField(Constants.TEST_FIELD, mojo, testsToRun);            
    }
    
    private static void updateForkCounts(Object mojo) throws Exception {
        logger.log(Level.FINE, "updating ForkCounts");
        String forkCounts = System.getProperty(Constants.FORK_COUNT_FIELD);      		
        setField(Constants.FORK_COUNT_FIELD, mojo, forkCounts);            
    }
    
    private static void updateThreadCounts(Object mojo) throws Exception {
        logger.log(Level.FINE, "updating ThreadCounts");
        String threadCounts = System.getProperty(Constants.THREAD_COUNT_FIELD);      		
        setField(Constants.THREAD_COUNT_FIELD, mojo, threadCounts);            
    }
    
}

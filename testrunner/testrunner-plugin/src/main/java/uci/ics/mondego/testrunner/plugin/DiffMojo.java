package uci.ics.mondego.testrunner.plugin;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugin.MojoFailureException;
import org.apache.maven.plugins.annotations.Execute;
import org.apache.maven.plugins.annotations.LifecyclePhase;
import org.apache.maven.plugins.annotations.Mojo;
import org.apache.maven.plugins.annotations.ResolutionScope;


@Mojo(name = "diff", requiresDirectInvocation = true, requiresDependencyResolution = ResolutionScope.TEST)
@Execute(phase = LifecyclePhase.TEST_COMPILE)
public class DiffMojo extends BaseMojo {
	
	private static final Logger logger = LogManager.getLogger(DiffMojo.class);
	
    public void execute() throws MojoExecutionException , MojoFailureException {
    	String impactedTests = getFailedTests();   	    	
    	logger.info("Following tests were impacted .... ");
    	logger.info(impactedTests);
    }
  
    
    protected String getFailedTests() {
    	String failedTests = "spoon.test.main.MainTest#testResourcesCopiedInTargetDirectory,spoon.test.main.MainTest#testResourcesNotCopiedInTargetDirectory,spoon.test.main.MainTest#testTest,spoon.test.main.MainTest#testGenericContract,spoon.test.model.IncrementalLauncherTest#testIncremental1,spoon.test.model.IncrementalLauncherTest#testIncremental3,spoon.test.model.IncrementalLauncherTest#testIncremental2,spoon.test.model.IncrementalLauncherTest#testCache,spoon.test.compilation.CompilationTest#testClassLoader,spoon.test.compilation.CompilationTest#testFilterResourcesFile,spoon.test.compilation.CompilationTest#testFilterResourcesDir,spoon.LauncherTest#testInitEnvironment,spoon.MavenLauncherTest#multiModulesProjectTest";
    	
    	//failedTests = "*";
    	return failedTests;
    } 
}
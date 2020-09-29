package uci.ics.mondego.testrunner.plugin;

import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugin.MojoFailureException;
import org.apache.maven.plugins.annotations.Mojo;
import org.apache.maven.plugins.annotations.ResolutionScope;

import uci.ics.mondego.testrunner.maven.AgentLoader;
import uci.ics.mondego.testrunner.tool.Constants;

@Mojo(name = "failrun", requiresDependencyResolution = ResolutionScope.TEST)
public class FailRunMojo extends DiffMojo {
	 @Override
	 public void execute() throws MojoExecutionException, MojoFailureException  {
		 System.setProperty(Constants.LOG_DIRECTORY, log_directory); 
		 System.setProperty(Constants.DEBUG_FLAG, debug_flag);
   	 
		 // TLDR is flagged on. It gets the impacted tests and set the tests field on.
	     if (AgentLoader.loadDynamicAgent()) {
	       System.setProperty(Constants.TLDR_TEST_PROPERTY, getFailedTests());
	     } else {
	            throw new MojoExecutionException("Agent attachment failed");
	     }
	 }
}

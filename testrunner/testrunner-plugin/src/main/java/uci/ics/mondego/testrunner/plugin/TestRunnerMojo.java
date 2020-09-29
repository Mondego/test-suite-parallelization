package uci.ics.mondego.testrunner.plugin;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugin.MojoFailureException;
import org.apache.maven.plugins.annotations.Execute;
import org.apache.maven.plugins.annotations.LifecyclePhase;
import org.apache.maven.plugins.annotations.Mojo;
import org.apache.maven.plugins.annotations.ResolutionScope;

import uci.ics.mondego.testrunner.tool.Constants;

/**
 * Mojo to run TLDR A sample command to run this plugin would look like  - 
 * 
 * mvn -q com.mondego.ics.uci:tldr-plugin:1.0.2-SNAPSHOT:tldr 
 * -Dcommit.serial=<serial>
 * -Dcommit.hash=<hash>
 * -Dlog.directory=<log_dir> 
 * -Ddebug.flag=<true/false>
 * -Dmultimodule.projectname=<project name>
 * -Dmaven.test.failure.ignore=true 
 * -Drat.skip=true  
 * @author demigorgan
 *
 */

@Mojo(name = "testrunner", requiresDirectInvocation = true, requiresDependencyResolution = ResolutionScope.TEST)
@Execute(phase = LifecyclePhase.TEST, lifecycle = "testrunner")
public class TestRunnerMojo extends RunMojo {
	private static final Logger logger = LogManager.getLogger(TestRunnerMojo.class);

	@Override
	 public void execute() throws MojoExecutionException, MojoFailureException  {	     		
		testRunEndTime = System.nanoTime();	 
	     
	     // test selection end time == test run start time
	     testRunElapsedTimeInSecond = testRunEndTime - testSelectionEndTime;
	     testRunElapsedTimeInSecond = (double) testRunElapsedTimeInSecond / 1000000000.0;	
	     	    
    	 if(debug_flag.equals(Constants.TRUE)) {
    		 System.out.println(Constants.DISTINCTION_LINE_STAR);
    		 System.out.println(" Project name : " + multi_module_project_name);
    		 System.out.println("Module name : " + getModuleName());
    		 System.out.println(Constants.DISTINCTION_LINE_STAR);
    	 }
	 } 
	
	private String getLogDirectory() {
		
		String logFolder = log_directory  + Constants.SLASH;
		
		File file = new File(logFolder);
        if (!file.exists()) {
            if (file.mkdirs()) {
            	logger.debug("Log Directory is created!");
            } 
            else {
            	logger.debug("Failed to create log directory!");
            }
        } 
        else {
        	logger.debug("Log directory exists already!");
        }
        return logFolder;
	}
}
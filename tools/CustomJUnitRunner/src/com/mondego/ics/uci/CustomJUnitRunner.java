package com.mondego.ics.uci;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

import org.junit.runner.JUnitCore;
import org.junit.runner.Request;
import org.junit.runner.Result;

/**
 * This class is a wrapper to run single JUnit tests. It evades the overhead
 * incurred by Maven. Since this not a Maven project, we have to add JUnit jar
 * in its path manually by eclipse or terminal.
 * 
 * @author demigorgan
 *
 */
public class CustomJUnitRunner {
	private static Map<String, Boolean> results = new HashMap<String, Boolean>();
	private static Map<String, Double> timeInSecond = new HashMap<String, Double>();
	
	/**
	 * Expected argument: 
	 * 1. File directory where all the failed test fqns are written
	 * 2. Fire directory where the output of each individual test run will be written
	 * @param args
	 * @throws ClassNotFoundException
	 */
	public static void main(String... args) throws ClassNotFoundException {        
        String sourceFile = args[0];
        String outputFile = args[1];
        FileReader fr = null;
        BufferedReader br = null;
        try{
	        fr = new FileReader(new File(sourceFile));    
	        br = new BufferedReader(fr);  //creates a buffering character input stream  
	        String line;  
	        while( (line = br.readLine()) != null ) {  
	        	runSingleTest(line);
	        } 
        } catch(IOException e) {  
        	e.printStackTrace();  
        } catch (ClassNotFoundException e) {
        	e.printStackTrace();
        } finally {
            try {
            	br.close();
				fr.close();
				
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}    
        }
        
        writeLog(outputFile);
    }
	
	private static Result runSingleTest(String fqn) 
			throws ClassNotFoundException {
		String method = fqn.substring(fqn.lastIndexOf('.') + 1);
		String claz = fqn.substring(0, fqn.lastIndexOf('.'));
		
		long begin = System.currentTimeMillis();
        Request request = Request.method(Class.forName(claz), method);

        Result result = new JUnitCore().run(request);
		long end = System.currentTimeMillis();
		double timeInSec =  (end - begin) / 1000;
		
		timeInSecond.put(fqn, timeInSec);
		results.put(fqn, result.wasSuccessful());   
		return result;
	}
	
	private static void writeLog(String fileName) {
		try (PrintWriter writer = new PrintWriter(new File(fileName))) {
			  StringBuilder header = new StringBuilder();
			  header.append("Test");
			  header.append(',');
			  header.append("Successful?");
			  header.append(',');
			  header.append("Time (sec)");
			  header.append('\n');
			  writer.write(header.toString());
			  
			  for (Map.Entry<String, Boolean> entries: results.entrySet()) {
				  String fqn = entries.getKey();
				  Boolean result = entries.getValue();
				  Double time = timeInSecond.get(fqn);
				  StringBuilder sb = new StringBuilder();
				  sb.append(fqn);
				  sb.append(',');
				  sb.append(result);
				  sb.append(',');
				  sb.append(time);
				  sb.append('\n');
				  writer.write(sb.toString());
			  }
		    } catch (FileNotFoundException e) {
		      System.out.println(e.getMessage());
		    }
	}
}


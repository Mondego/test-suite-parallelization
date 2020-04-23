package org.mondego.ics.uci;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

/**
 * This class gets a directory as input, scans in the directory for all surefire report (files that ends eith .html),
 * extracts the number of successful, failed, skipped, errored tests, and prints them on console or to a CSV file if specified
 * @author demigorgan
 *
 */
public class HTMLParser {
	private static int successCount; 
	private static int errorsCount;	
	private static int failuresCount;	
	private static int skippedCount;	
	
	public static void main(String[] args) {

		if (args == null || args.length == 0) {
			System.out.println("No argument passed... pass a directory as a parameter");
			return;
		}
		
		String directoryName = args[0];

		List<String> htmlFiles = scanHTMLFiles(directoryName);
		
		for (int i = 0; i< htmlFiles.size(); i++) {
			parseTestNumbers(htmlFiles.get(i));
		}
		// If output log file is given
		if (args.length == 2) {
			String filename = args[1];
			PrintWriter writer = null;
			try {
				  writer = new PrintWriter(new File(filename));
			      StringBuilder sb = new StringBuilder();
			      sb.append(successCount);
			      sb.append(',');
			      sb.append(errorsCount);
			      sb.append(',');
			      sb.append(failuresCount);
			      sb.append(',');  
			      sb.append(skippedCount);
			      sb.append(',');
			      sb.append('\n');

			      writer.write(sb.toString());
			    } catch (FileNotFoundException e) {
			    	e.printStackTrace();
			    } finally {
			    	writer.close();
			    }
		} else {
			System.out.println(
					successCount + " , " + 
					errorsCount + " , " + 
					failuresCount + " , " + 
					skippedCount);
		}
	}
	
	private static void parseTestNumbers(String fileName) {
		int successCount_ = 0;
		int errorsCount_ = 0;	
		int failuresCount_ = 0;	
		int skippedCount_ = 0;
		File input = new File(fileName);
		try {
			Document doc = Jsoup.parse(input, "UTF-8");
			Element table = doc.select("table").get(0); //select the first table.
			Elements rows = table.select("tr");

			for (int i = 1; i < rows.size(); i++) { //first row is the col names so skip it.
			    Element row = rows.get(i);
			    Elements cols = row.select("td");
			    successCount_ = Integer.parseInt(cols.get(0).text());
			    errorsCount_ = Integer.parseInt(cols.get(1).text());
			    failuresCount_ = Integer.parseInt(cols.get(2).text());
			    skippedCount_ = Integer.parseInt(cols.get(3).text());

			    successCount += successCount_;
		    	errorsCount += errorsCount_;
		    	failuresCount += failuresCount_;
		    	skippedCount += skippedCount_;
			}
		} catch (IOException e) {
			e.printStackTrace();
		} catch (NumberFormatException e) {
			System.err.println(
					"******** Problem in converting string to number ********");
		}
	} 

	private static List<String> scanHTMLFiles(String directoryName) {	
		List<String> pom = new ArrayList<String>();
		File directory = new File(directoryName);
	    File[] fList = directory.listFiles();	    	
	    if(fList != null) {
	    	for (File file : fList) {    	        	
	            if (file.isFile()) {
	            	String fileAbsolutePath = file.getAbsolutePath();	
	                if(fileAbsolutePath.endsWith(".html")){
	                	pom.add(fileAbsolutePath);
	                }	                	         
	            } else if (file.isDirectory()) {
	            	pom.addAll(scanHTMLFiles(file.getAbsolutePath()));
	            }
	        }
	    }
	    return pom;
    }
}

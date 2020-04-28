package org.mondego.ics.uci;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

/**
 * This class gets a directory as input, scans in the directory for all surefire report (files that ends eith .xml),
 * extracts the list of successful, failed, skipped, errored tests, and prints them on console or to a CSV file if specified
 * @author demigorgan
 * 
 * Relevant Link : 
 * https://stackoverflow.com/questions/40003460/get-the-number-of-passed-and-failed-tests-with-their-name-from-command-line
 */
public class XMLParser {

	private static List<String> successful;
	private static List<String> error;
	private static List<String> skip;
	private static List<String> failure;
	
	public static void main(String[] args) {

		if (args == null || args.length == 0) {
			System.out.println("No argument passed... pass a directory as a parameter");
			return;
		}
		
		String directoryName = args[0];
		List<String> xmlfiles = scanTestReportsInXML(directoryName);
		System.out.println(xmlfiles.size());
		for( int i = 0; i<xmlfiles.size(); i++ ) {
			processSingleXMLFile(xmlfiles.get(i));
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
					successful.size() + " , " + 
					error.size() + " , " + 
					failure.size() + " , " + 
					skip.size());
		}
	}
	
	private static void processSingleXMLFile(String xml) {
		File fXmlFile = new File(xml);
		DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
		DocumentBuilder dBuilder;
		try {
			dBuilder = dbFactory.newDocumentBuilder();
			Document doc = dBuilder.parse(fXmlFile);
			doc.getDocumentElement().normalize();
			NodeList nList = doc.getElementsByTagName("testcase");
			
			for (int i = 0; i < nList.getLength(); i++) {
				Node nNode = nList.item(i);
				
				if (nNode.getNodeType() == Node.ELEMENT_NODE) {
					Element eElement = (Element) nNode;
					String fqn = eElement.getAttribute("classname") + "." + eElement.getAttribute("name");
					if (eElement.getElementsByTagName("failure").getLength() > 0){
						failure.add(fqn);
					} else if (eElement.getElementsByTagName("error").getLength() > 0){
						error.add(fqn);
					} else if (eElement.getElementsByTagName("skipped").getLength() > 0){
						skip.add(fqn);
					} else {
						successful.add(fqn);
					}						
				}
			}		
		} catch (ParserConfigurationException e) {
			e.printStackTrace();
		} catch (SAXException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}	
	}
	
	/**
	 * Scans the repository for all xml files.
	 * @param directoryName
	 * @return
	 */
	private static List<String> scanTestReportsInXML(String directoryName) {
		List<String> pom = new ArrayList<String>();
		File directory = new File(directoryName);
	    File[] fList = directory.listFiles();	    	
	    if(fList != null) {
	    	for (File file : fList) {    	        	
	            if (file.isFile()) {
	            	String fileAbsolutePath = file.getAbsolutePath();	
	                
	            	// Test reports reside inside target/surefire-reports and has format - 
	            	// TEST_${fqn of test class}.xml
	            	if(fileAbsolutePath.endsWith(".xml")
	                	&& fileAbsolutePath.contains("target/surefire-reports/TEST-")){
	                	pom.add(fileAbsolutePath);
	                }
	            	
	            } else if (file.isDirectory()) {
	            	pom.addAll(scanTestReportsInXML(file.getAbsolutePath()));
	            }
	        }
	    }
	    return pom;
	}
}

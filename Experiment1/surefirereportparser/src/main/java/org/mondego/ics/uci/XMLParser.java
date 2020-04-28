package org.mondego.ics.uci;

import java.io.File;
import java.io.IOException;
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
					if (eElement.getElementsByTagName("failure").getLength() > 0 || 
							eElement.getElementsByTagName("error").getLength() > 0) {
							//eElement.getElementsByTagName("skipped").getLength() > 0) {
						System.out.println("Name : " + eElement.getAttribute("name"));
						System.out.println("Test Class : " + eElement.getAttribute("classname"));
						System.out.println("===================================================");
						System.out.println("Failure : " + eElement.getElementsByTagName("failure").getLength());
						System.out.println("Error : " + eElement.getElementsByTagName("error").getLength());
						System.out.println("Skipped : " + eElement.getElementsByTagName("skipped").getLength());
						System.out.println();
						System.out.println();
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

import java.io.File;
import java.lang.reflect.InvocationTargetException;
import java.util.HashSet;
import java.util.Set;

public class GenerateClassPath {
	
	private static Set<String> allJars = new HashSet<String>();

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		
		String projectDir = args[0];
		try {
			System.out.println(scanJarFiles(projectDir));
		} catch (InstantiationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IllegalArgumentException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (InvocationTargetException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (NoSuchMethodException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SecurityException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public static String scanJarFiles(String directoryName) 
			throws InstantiationException, 
			IllegalAccessException,
			IllegalArgumentException, 
			InvocationTargetException, 
			NoSuchMethodException, 
			SecurityException {	
		
		File directory = new File(directoryName);
	    File[] fList = directory.listFiles();	
	    String ret = "";
	    if(fList != null)
	        for (File file : fList) {    	        	
	            if (file.isFile()) {
	            	String fileAbsolutePath = file.getAbsolutePath();	
	                if(fileAbsolutePath.endsWith(".jar")){
	                	String jarName = fileAbsolutePath.substring(fileAbsolutePath.lastIndexOf("/") + 1);
	                	if (!allJars.contains(jarName)) {
	                		ret += fileAbsolutePath;
		                	ret += ":";
		                	allJars.add(jarName);
	                	}
	                }	                	         
	            } else if (file.isDirectory() ) {
	                ret += scanJarFiles(file.getAbsolutePath());
	            }
	        }
	    	return ret;
	    }	

}

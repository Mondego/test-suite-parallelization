import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

public class GenerateMavenTestConfig {
	public static void main(String[] args) {
	    try  {  
			File file=new File(args[0]);    //creates a new file instance  
			FileReader fr=new FileReader(file);   //reads the file  
			BufferedReader br=new BufferedReader(fr);  //creates a buffering character input stream  
			StringBuffer sb=new StringBuffer();    //constructs a string buffer with no characters  
			String line;  
			while((line=br.readLine())!=null)  {
				sb.append(line.substring(0, line.lastIndexOf(".")));
				sb.append("#");
				sb.append(line.substring(line.lastIndexOf(".")));
				sb.append(",");
			}  
			fr.close();    
			System.out.println(sb.toString());  
		} catch(IOException e) {  
			e.printStackTrace();  
		}  
	}
}

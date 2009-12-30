import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.StringWriter;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.text.*;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;


/**
 * @author Phil Cruz
 *
 * 
 */
public class cfcdoc {
		
	public static void main(String[] args)
	throws TransformerException, TransformerConfigurationException, 
    IOException, Exception
	{
		System.out.println("Doing main...");
		
		String xslfile = args[0];
		String xmlfile = args[1];	    	    	    	  
	    StreamSource xslSource = null;
	    StreamSource xmlSource = null;
	    
	    
		xslSource = new StreamSource ( new File( xslfile ) );
	    xmlSource = new StreamSource ( new File( xmlfile ) );
	        
	    TransformerFactory tFactory = new org.apache.xalan.processor.TransformerFactoryImpl();//TransformerFactory.newInstance();
	    Transformer transformer = tFactory.newTransformer(xslSource);
	    
	    StringWriter writer = new StringWriter();
	    StreamResult result = new StreamResult(writer);
	    
	    //do the actual transformation
	    transformer.transform(xmlSource, result);
	    	    
		 System.out.println("Result:" + writer.toString());
	}
	
	public String getTransformerClassNames()throws TransformerConfigurationException{
		TransformerFactory tFactory = new org.apache.xalan.processor.TransformerFactoryImpl();//TransformerFactory.newInstance();
		Transformer transformer = tFactory.newTransformer();
		return tFactory.getClass().getName() + "," + transformer.getClass().getName();
	}
	
	public String echo(String msg){
		return msg;
	}
		
	public boolean isEvaluationKey(String key){
		
		return false;
		
	}
	
	public boolean isKeyValid(String key) throws Exception {		
		//all is good
		return true;
	}
	
	public String transform(String xslfile, String xmlfile, String regKey)
    	throws TransformerException, TransformerConfigurationException, FileNotFoundException, IOException, Exception{
    
		StreamSource xslSource = null;
		StreamSource xmlSource = null;
		
		xslSource = new StreamSource ( new File( xslfile ) );
		xmlSource = new StreamSource ( new File( xmlfile ) );
		
		TransformerFactory tFactory = new org.apache.xalan.processor.TransformerFactoryImpl();//TransformerFactory.newInstance();
		Transformer transformer = tFactory.newTransformer(xslSource);   
		
		StringWriter writer = new StringWriter();
		StreamResult result = new StreamResult(writer);
		
		if (transformer != null)
		{
			//do the actual transformation
			transformer.transform(xmlSource, result);
		}
		else
		{
			throw new Exception("transformer is NULL." );		
		}
		
		return writer.toString();
	}

}

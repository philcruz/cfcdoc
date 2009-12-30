<cfcomponent output="false">

	<cffunction name="init" returnType="cfcdoc" output="false">
		<cfscript>
			variables.cfcdocInstance = this.createCFCDocObject();
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="getTransformerClassNames" returnType="string" output="false">
		<cfreturn variables.cfcdocInstance.getTransformerClassNames() />
	</cffunction>
			
	<cffunction name="getDocBook" returnType="string" output="false">
		<cfargument name="docBookFile" type="string" required="true" />
		<cfscript>
			var fileContents = "";
		</cfscript>
		<cffile action="READ" file="#arguments.docBookFile#" variable="filecontents">
		<cfreturn fileContents />
	</cffunction>
	
	<cffunction name="saveDocBook" returnType="void" output="false">
		<cfargument name="docbookxml" type="string" required="true" />
		<cfargument name="destination" type="string" required="true" />		
		<cffile action="WRITE" file="#arguments.destination#" output="#arguments.docbookxml#" addnewline="No">		
	</cffunction>
	
	<cffunction name="createDocBookForPDF" returnType="void" output="false" hint="I process the docbook xml and prepare it for PDF output, I remove the <ulink> tags">
		<cfargument name="xmlfile" type="string" required="true" />
		<cfargument name="destination" type="string" required="false" default="" />
		<cfscript>
			var xmlfilecontents = "";
			var docbookxmlforpdf = "";
			var reg_expression = "<ulink [^>]*>+([[:graph:]]+)+</ulink>";			
			var reg_expression_anchor = "<anchor [^>]*></anchor>";
			if (not len(arguments.destination)){
				arguments.destination = replaceNoCase(arguments.xmlfile,  ".xml",  "_pdf.xml"); 
			}
			// we also want to save the docbook for pdf output
			// we have to clean the <ulink> and <anchor> tags
			
		</cfscript>
		<cffile action="READ" file="#arguments.xmlfile#" variable="xmlfilecontents" addnewline="No">
		<cfset docbookxmlforpdf = reReplaceNoCase(xmlfilecontents, reg_expression,  "\1", "ALL") />
		<cfset docbookxmlforpdf = reReplaceNoCase(docbookxmlforpdf, reg_expression_anchor,  "", "ALL") />
		<cffile action="WRITE" file="#destination#" output="#docbookxmlforpdf#" addnewline="No">			
	</cffunction>
	
	<cffunction name="transformDocBook" returntype="any" output="false">
		<cfargument name="xslfile" type="string" required="true" />
		<cfargument name="xmlfile" type="string" required="true" />
		<cfargument name="licensekey" type="string" required="true" />
		<cfset var result = "" />
		<cftry>
			<cfset result = variables.cfcdocInstance.transform(arguments.xslfile, arguments.xmlfile, arguments.licensekey) />
		<cfcatch type="Any">
			<cfset result = xmlFormat(cfcatch.message) & "<br/>" & xmlFormat(cfcatch.detail) />
		</cfcatch>
		</cftry>
		<cfscript>			
			return result;
		</cfscript>					
	</cffunction>
	
	<cffunction name="xml2fo" returntype="any" output="false" hint="convert a docbook xml file to an FO file">
		<cfargument name="xslfile" type="string" required="true" />
		<cfargument name="xmlfile" type="string" required="true" />
		<cfargument name="fofile" type="string" required="true" />
		<cfargument name="licensekey" type="string" required="true" />
		<cfscript>
			var result = "";		
			result = variables.cfcdocInstance.transform(arguments.xslfile, arguments.xmlfile, arguments.licensekey);
		</cfscript>		
		<cffile action="WRITE" file="#arguments.fofile#" output="#result#" charset="utf-8">
		<cfreturn result />	
	</cffunction>
	
	<cffunction name="fo2pdf" returntype="string" output="false" hint="call the fop.bat file to create the PDF">
		<cfargument name="fopExecutablePath" type="string" required="true" />
		<cfargument name="fofile" type="string" required="true" />
		<cfargument name="pdffile" type="string" required="true" />
		<cfargument name="logfile" type="string" required="true" />
		<cfscript>
			var cmdArgs = arguments.fofile & " " & arguments.pdffile;			
			var results = "";
		</cfscript>		
		<cfexecute name="#arguments.fopExecutablePath#" arguments="#cmdArgs#" timeout="180" outputfile="#arguments.logfile#"></cfexecute>
		<cffile action="READ" file="#arguments.logfile#" variable="results" >
		<cfreturn results />
	</cffunction>
	
	<cffunction name="isEvaluationKey" returntype="boolean" output="false">
		<cfargument name="licensekey" type="string" required="true" />
		<cfscript>
			var cfcdocinst = this.createCFCDocObject();
			return cfcdocinst.isEvaluationKey(arguments.licensekey);
		</cfscript>
	</cffunction>
	
	<cffunction name="isKeyValid" returntype="boolean" output="false">
		<cfargument name="key" type="string" required="true" />
		<!--- <cfreturn variables.cfcdocInstance.isKeyValid(arguments.key) /> --->
		<cfreturn true />
	</cffunction>
	
	<cffunction name="createCFCDocObject" returntype="any" output="false">

		<cfscript>
			var currentDirectory =  GetDirectoryFromPath(getCurrentTemplatePath()); 
			var URLObject = "";			
			var URLArray = "";
			var ArrayClass = "";
			var loader = "";
			var cfcdoc = "";
			var result = "";
			
			//Turn any \ in the path into / so java doesnt choke 
			//currentDirectory = "d:\cruz\projects\cfx_cfcdoc\src\";
			currentDirectory = replace(currentDirectory,'\','/','all');
			//Create an instance of java.net.URL for passing to the URLClassLoader 
			URLObject = createObject('java','java.net.URL');
			//Initialize the object with the current directory. 
			URLObject.init("file:" & currentDirectory);
					
			URLArray = arrayNew(1);		
			URLArray[1] = URLObject;
			
			//Create and the URLClassLoader and pass it the array containing our path 
			loader = createObject('java','java.net.URLClassLoader');
			loader.init(URLArray);
		
			//Use our new class loader to load the cfcdoc class 
			cfcdoc = loader.loadClass("cfcdoc").newInstance();
			
			
			return cfcdoc;
		</cfscript>
					
	</cffunction>
	
	
</cfcomponent>

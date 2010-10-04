<cfcomponent output="false">

	<cffunction name="init" returnType="cfcdoc" output="false">
		<cfscript>
		return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="getTransformerClassNames" returnType="string" output="false">
		<cfreturn "[TransformerClass]" />
	</cffunction>
			
	<cffunction name="getDocBook" returnType="string" output="false">
		<cfargument name="docBookFile" type="string" required="true" />
		<cfscript>		
		
		var fileContents = this.fileRead( arguments.docBookFile );
		return fileContents;
		
		</cfscript>
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
		xmlfilecontents = this.fileRead(arguments.xmlfile);
		docbookxmlforpdf = reReplaceNoCase(xmlfilecontents, reg_expression,  "\1", "ALL");
		docbookxmlforpdf = reReplaceNoCase(docbookxmlforpdf, reg_expression_anchor,  "", "ALL");
		
		</cfscript>				
		<cffile action="WRITE" file="#destination#" output="#docbookxmlforpdf#" addnewline="No">			
	</cffunction>
	
	<cffunction name="transformDocBook" returntype="any" output="false">
		<cfargument name="xslfile" type="string" required="true" />
		<cfargument name="xmlfile" type="string" required="true" />
		<cfset var result = "" />
		<cftry>
			<cfset result = this.transform(arguments.xslfile, arguments.xmlfile) />
		<cfcatch type="Any">
			<cfset result = xmlFormat(cfcatch.message) & "<br/>" & xmlFormat(cfcatch.detail) />
		</cfcatch>
		</cftry>
		<cfreturn result />
	</cffunction>
	
	<cffunction name="xml2fo" returntype="any" output="false" hint="convert a docbook xml file to an FO file">
		<cfargument name="xslfile" type="string" required="true" />
		<cfargument name="xmlfile" type="string" required="true" />
		<cfargument name="fofile" type="string" required="true" />
		<cfscript>
		var result = "";		
		result = this.transform(arguments.xslfile, arguments.xmlfile);
		</cfscript>		
		<cffile action="WRITE" file="#arguments.fofile#" output="#result#" charset="utf-8">
		<cfreturn "" />	
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
				
	<cffunction name="transform" returntype="string" output="false">		
		<cfargument name="xslSource" type="string" required="true" />
		<cfargument name="xmlSource" type="string" required="true" />
		<cfargument name="stParameters" type="struct" default="#StructNew()#" required="false" />
		<cfscript>
		
		var source = ""; var transformer = ""; var aParamKeys = ""; var pKey = "";
		var xmlReader = ""; var xslReader = ""; var pLen = 0;
		var xmlWriter = ""; var xmlResult = ""; var pCounter = 0;
		var tFactory = createObject("java", "javax.xml.transform.TransformerFactory").newInstance();
		
		//if xml use the StringReader - otherwise, just assume it is a file source. 
		if(Find("<", arguments.xslSource) neq 0)
		{
			xslReader = createObject("java", "java.io.StringReader").init(arguments.xslSource);
			source = createObject("java", "javax.xml.transform.stream.StreamSource").init(xslReader);
		}
		else
		{
			source = createObject("java", "javax.xml.transform.stream.StreamSource").init("file:///#arguments.xslSource#");
		}
		
		transformer = tFactory.newTransformer(source);
		
		//if xml use the StringReader - otherwise, just assume it is a file source. 
		if(Find("<", arguments.xmlSource) neq 0)
		{
			xmlReader = createObject("java", "java.io.StringReader").init(arguments.xmlSource);
			source = createObject("java", "javax.xml.transform.stream.StreamSource").init(xmlReader);
		}
		else
		{
			source = createObject("java", "javax.xml.transform.stream.StreamSource").init("file:///#arguments.xmlSource#");
		}
		
		//use a StringWriter to allow us to grab the String out after. 
		xmlWriter = createObject("java", "java.io.StringWriter").init();
		
		xmlResult = createObject("java", "javax.xml.transform.stream.StreamResult").init(xmlWriter); 
		
		if(StructCount(arguments.stParameters) gt 0)
		{
			aParamKeys = structKeyArray(arguments.stParameters);
			pLen = ArrayLen(aParamKeys);
			for(pCounter = 1; pCounter LTE pLen; pCounter = pCounter + 1)
			{
				//set params 
				pKey = aParamKeys[pCounter];
				transformer.setParameter(pKey, arguments.stParameters[pKey]); 
			} 
		}
		
		transformer.transform(source, xmlResult);
		
		return xmlWriter.toString();
		
		</cfscript>
	</cffunction>

	<cffunction name="generateDocBookXml" hint="Generates the DocBook xml file from the cfcomponents">
		<cfargument name="title" required="true" />
		<cfargument name="introduction" default="" />
		<cfargument name="pathIndex" default="1" />
		<cfargument name="parseHeaderMode" required="true" />
		<cfargument name="cfcBasePath" required="true" />
		<cfscript>
		
		var docbookxml = "";
		var i = 1;
		var fso = "";
		var orderedQuery = "";
		var tmpquery = "";
		var result = structNew();
		
		var paths = arrayNew(1);
		var package = structNew();
		var directorySeparator = "/";
		
		package.prefix = listLast(arguments.cfcBasePath,'/\');
		var path = trim(arguments.cfcBasePath);
		package.path = path;
		arrayAppend(paths,package);

		var querystore = structNew();
		var packageRoot = listLast(arguments.cfcBasePath,'/\');

		if (lcase(server.os.name) contains "windows")
 				directorySeparator = "\";

		variables.util = createObject('component','Util').init(arguments.cfcBasePath,packageroot,directorySeparator,paths);
		util.setRootPath(arguments.cfcBasePath);

		var dtdPath = expandPath('./');
		if (right(dtdPath,  1) NEQ directorySeparator )
			dtdPath = dtdPath & directorySeparator & "docbook" & directorySeparator & "dtd" & directorySeparator & "docbookx.dtd";
		else
			dtdPath = dtdPath & "docbook" & directorySeparator & "dtd" & directorySeparator & "docbookx.dtd";		
			
		dtdPath = replace(dtdPath,  "\",  "/" ,  "ALL"); 
		
	</cfscript>
	<cfloop from="1" to="#arrayLen(paths)#" index="i">
		<cfset var currentpath = paths[i].path>
		<cfif not structKeyExists(queryStore,currentpath)>
			<cfset queryStore[currentpath] = structNew()>
		</cfif>
		<cfset fso = createObject('component','FileSystemObject').init(currentpath,directorySeparator)>
		
		<cfif not structKeyExists(queryStore[currentpath],'filequery')>
			<cfset queryStore[currentpath].fileQuery = fso.list(true,'*.cfc',paths[i].prefix) />
		</cfif>
	</cfloop>
	
	<!--- <cfdump var="#paths#">  --->
	<cfset var filequery = queryStore[arguments.cfcBasePath].filequery />
	
	<cfquery dbtype="query" name="orderedQuery">
		SELECT *, name AS lname
		FROM fileQuery
	</cfquery>
	
	<cfset orderedQuery = fso.fileQueryWithLowerCaseName(orderedQuery) />
	
	<cfset tmpquery = queryStore[paths[arguments.pathIndex].path].filequery>  
	
	<!--- <cfdump var="#tmpquery#">    
	<cfdump var="#orderedQuery#"><cfabort>     --->
	<!--- <cfset stComponent = util.getCFCInformation("D:\http\cfcdoc\MachII\filters\EventArgsFilter.cfc") /> --->
	
	<!--- test case 1 --->
	<!--- <cfset fp = util.getFilePath("cfcdoc.MachII.framework.EventFilter", "D:\http\cfcdoc\MachII\filters\") /> 
	<cfoutput>#fp#</cfoutput>
	<cfabort>       --->
	
	<!--- test case 2 --->
	<!--- <cfset du = util.getDetailURL("MachII.framework.EventFilter", "") /> 
	<cfset fp = util.getFilePath("MachII.framework.EventFilter","") />
	<cfoutput>#du#<br>#fp#</cfoutput>
	<cfabort> --->        
	
	<!--- test case 3 --->
	<!--- <cfset du = util.getDetailURL("MachII.framework.EventFilter", "") /> 
	<cfset fp = util.getFilePath("MachII.framework.EventFilter","") />
	<cfoutput>#du#<br>#fp#</cfoutput>
	<cfabort> --->        
	
	<!--- <cfoutput query="tmpquery" group="package">
		<cfset currentPackage = tmpquery.package />
		Package:#util.getPackageDisplayName(tmpquery.package)# (#trim(tmpquery.package)#)<br/>    
		<cfloop query="orderedQuery">
		
				<cfif currentPackage EQ orderedQuery.package>																	
						<cfset cfcfile = orderedQuery.fullpath & application.directorySeparator & orderedQuery.name />
						<cfset stComponent = util.getCFCInformation(cfcfile) />						
						<cfif structKeyExists(stComponent,"name")>
							&nbsp;<strong>#stComponent.name#</strong><br>
							&nbsp;#stComponent.path#<br>
							&nbsp;#stComponent.package#<br>
							&nbsp;extends:#stComponent.attributes.extends#<br>
							<cfif len(stComponent.superComponentPath)>
							&nbsp;#stComponent.superComponentPath# <span style="color:red;">#yesNoFormat(fileExists(stComponent.superComponentPath))#</span>					<br>
							</cfif>
						<cfelse>
							<span style="color:red;">Problem parsing #cfcfile#<br></span>
						</cfif>
						<br>									
				</cfif>
		</cfloop>
	</cfoutput>
	<cfabort>  --->
	
	<cfsavecontent variable="docbookxml" ><?xml version="1.0" encoding="UTF-8"?>
	<!-- <!DOCTYPE book PUBLIC "-//OASIS//DTD DocBook XML V4.2//EN"
	  "http://www.oasis-open.org/docbook/xml/4.2/docbookx.dtd" > -->
	<!DOCTYPE book SYSTEM
	  "file:///<cfoutput>#dtdpath#</cfoutput>" > 
	<book>
	  <title><cfoutput>#arguments.title#</cfoutput></title>
	  <titleabbrev></titleabbrev>
	
	  <cfif len(arguments.introduction)>
	  <preface id="introduction"><title>Introduction</title>
	    <para><cfoutput>#arguments.introduction#</cfoutput>
	    </para>
	  </preface>
	  </cfif>
	<cfoutput query="tmpquery" group="package">
		<cfset currentPackage = tmpquery.package />
		<chapter id="#trim(tmpquery.package)#"><?dbhtml dir="#trim(tmpquery.package)#" ?><?dbhtml filename="#trim(tmpquery.package)#.html" ?><title>#util.getPackageDisplayName(tmpquery.package)#</title>
	    
		<cfloop query="orderedQuery">			
			<cfif currentPackage EQ orderedQuery.package>	
			<cfset cfcfile = orderedQuery.fullpath & application.directorySeparator & orderedQuery.name />
			<cfset stComponent = util.getCFCInformation(cfcfile,arguments.parseHeaderMode) />						
			<cfset sectionID = orderedQuery.package & "." & listFirst(orderedQuery.name,'.') />
			<!--- if the cfc file is empty/invalid it might not have a name so check first--->
			<cfset isComponentValid = structKeyExists(stComponent, "name") />  			
			<cfif isComponentValid >
			<?custom-pagebreak?>
			<section id="#sectionID#"><?dbhtml filename="#listFirst(orderedQuery.name,'.')#.html" ?>
				<title>#listFirst(orderedQuery.name,'.')#</title>																			
					<cfinclude template="docbooktemplate.cfm" >
			</section>
			</cfif>
			</cfif>			
		</cfloop>
	  </chapter>
	</cfoutput>  
	</book>  
	</cfsavecontent>
	
	<!--- <textarea cols="80" rows="40">
	<cfoutput>#docbookxml#</cfoutput>
	</textarea>
	<cfabort> --->
	<cfset result.filequery = filequery />
	<cfset result.docbookxml = docbookxml />
	<cfreturn result />

	</cffunction>
	
	<cffunction name="generateEclipseTableOfContents" output="false" >
		<cfargument name="htmlBasePath" required="true" />
		<cfargument name="title" required="true" />

		
		<cfset var toc = '<?xml version="1.0" encoding="utf-8" standalone="no"?><toc label="#arguments.title#" topic="index.html">' />
		<cfset var fileList = "" />
		<cfset var topicFiles = "" />
		<cfset var subdir = "" />
		<cfset var pluginxml = "" />
		
		<CFDIRECTORY DIRECTORY="#arguments.htmlBasePath#" NAME="fileList">	
		
		<cfoutput query="fileList" >
			<cfif lcase(type) IS "dir">
				<cfset toc = toc & '<topic label="#name#" href="#name#/#name#.html">' />
				<CFDIRECTORY DIRECTORY="#arguments.htmlBasePath#/#name#" NAME="topicFiles">	
				<cfset subdir = "#name#" />
				<cfloop query="topicFiles">
					<cfif NOT lcase(type) IS "dir">
						<cfif not(find(".css",  name) or find("unknowncomponent",name) or find("nativetypes", name) ) >
						<cfset toc = toc & '<topic label="#name#" href="#subdir#/#name#"></topic>' />
						</cfif>
					</cfif>
				</cfloop>
				<cfset toc = toc & '</topic>' />
			</cfif>
		</cfoutput>			
		
		<cfset toc = toc & '</toc>' />
		<cfif not directoryExists(arguments.htmlBasePath)>
			<cfdirectory action="CREATE" directory="#arguments.htmlBasePath#">
		</cfif>
		<cffile action="WRITE" file="#arguments.htmlBasePath##application.directorySeparator#toc.xml" output="#toc#" >
		
		<cfsavecontent variable="pluginxml" >
		<?xml version="1.0" encoding="utf-8" standalone="no"?>
		<plugin name="CFCDoc Documentation" id="<cfoutput>#listLast(htmlBasePath, application.directorySeparator)#</cfoutput>" version="1.0" provider-name="provider-name">
		  <extension point="org.eclipse.help.toc">
		    <toc file="toc.xml" primary="true"/>
		  </extension>
		</plugin>
		</cfsavecontent> 
		
		<cffile action="WRITE" file="#arguments.htmlBasePath##application.directorySeparator#plugin.xml" output="#trim(pluginxml)#" >
	</cffunction>
	
	<cffunction name="generateFrames" output="false">
		<cfargument name="htmlBasePath" required="true" />
		
		<cfif not directoryExists(arguments.htmlBasePath)>
			<cfdirectory action="CREATE" directory="#arguments.htmlBasePath#">
		</cfif>
		
		<cfscript>
			var allcomponents = queryNew("component,link");
			var index_frames = "";
			var leftframe = "";
			var packageshtml = "";
			var allcomponentshtml = "";
			var filelist = "";
			var allcomponentssorted = "";
			var debugText = "";
			var result = structNew();
		</cfscript>
		
		
		<cfsavecontent variable="index_frames" >
		<frameset cols="250,*">
			<frame src="leftframe.html" name="leftframe"></frame>
			<frame src="index.html" name="content"></frame>
		
		</frameset>
		</cfsavecontent>
		
		<cfsavecontent variable="leftframe" >
		<frameset rows="40%,60%">
			<frame src="packages.html" name="packages"></frame>
			<frame src="allcomponents.html" name="components"></frame>
		</frameset><noframes></noframes>
		</cfsavecontent>
		
		<cfsavecontent variable="packageshtml" >
		<HTML>
		<HEAD>
		<META http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<TITLE></TITLE><LINK href="cfcdoc.css" rel="stylesheet" type="text/css">
		</HEAD>
		<BODY bgcolor="white" text="black" link="##0000FF" vlink="##840084" alink="##0000FF">
		<a href="allcomponents.html" target="components">All components</a>
		<h3>Packages</h3>
		</cfsavecontent>
		
		<cfsavecontent variable="allcomponentshtml" >
		<HTML>
		<HEAD>
		<META http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<TITLE></TITLE><LINK href="cfcdoc.css" rel="stylesheet" type="text/css">
		</HEAD>
		<BODY bgcolor="white" text="black" link="##0000FF" vlink="##840084" alink="##0000FF">
		<h3>All Components</h3>
		</cfsavecontent>
		
		<cfset var package_components_html = "" />
		
		
		<CFDIRECTORY DIRECTORY="#arguments.htmlBasePath#" NAME="fileList">	
		
		<cfoutput query="fileList" >
			<cfif lcase(fileList.type) IS "dir">
				<cfset debugText = debugText & "dir:" & name & "<br>" />
				<cfset package_components_html = "" />
				<!--- add a link for the dir to the packages html --->
				<cfset packageshtml = packageshtml & '<a  href="#name#_components.html" target="components">#name#</a><br/>' />
				<CFDIRECTORY DIRECTORY="#arguments.htmlBasePath#/#name#" NAME="componentFiles">	
				<cfset subdir = "#name#" />
				<cfloop query="componentFiles">
					<cfif NOT lcase(componentFiles.type) IS "dir">
						<cfset debugText = debugText & "file:" & name & "<br>" />
						<cfif not(find(".css",  name) or find("unknowncomponent",name) or find("nativetypes", name) or find(".", replace(name,  ".html",  "") ) ) >
						<cfset package_components_html = package_components_html & '<a href="#subdir#/#name#" target="content">#name#</a><br/>' />
						<!--- add the component to the allcomponents query --->
						<cfset queryAddRow(allcomponents,  1 ) />
						<cfset querySetCell(allcomponents,  "component",  "#replaceNoCase(name,  ".html",  "")#") /> 
						<cfset querySetCell(allcomponents,  "link",  "#subdir#/#name#") /> 
						</cfif>
					</cfif>
				</cfloop>
				<!--- write the package_components file --->
				<cffile action="WRITE" file="#arguments.htmlBasePath##application.directorySeparator##subdir#_components.html" output="#package_components_html#" >
			</cfif>
		</cfoutput>
		
		<!--- sort all the components --->
		<cfquery dbtype="query" name="allcomponentssorted">
			SELECT * 
			FROM allcomponents
			ORDER BY component
		</cfquery>
		
		<!--- write it the links for allcomponents --->
		<cfoutput query="allcomponentssorted">
			<cfset allcomponentshtml = allcomponentshtml & '<a href="#link#" target="content">#component#</a><br/>' />
		</cfoutput>
		
		<cfset allcomponentshtml = allcomponentshtml & '</BODY></HTML>' />
		<cfset packageshtml = packageshtml & '</BODY></HTML>' />
		
		<cffile action="WRITE" file="#arguments.htmlBasePath##application.directorySeparator#index_frames.html" output="#index_frames#" >
		<cffile action="WRITE" file="#arguments.htmlBasePath##application.directorySeparator#leftframe.html" output="#leftframe#" >
		<cffile action="WRITE" file="#arguments.htmlBasePath##application.directorySeparator#packages.html" output="#packageshtml#" >
		<cffile action="WRITE" file="#arguments.htmlBasePath##application.directorySeparator#allcomponents.html" output="#allcomponentshtml#" >

		<cfscript>
		
		result.allcomponents = allcomponents;
		result.fileList = fileList;
		//result.debugText = debugText;
		return result;
		
		</cfscript>
	</cffunction>
	
	<cffunction name="customizeStyleSheet" output="false">
		<cfargument name="originalStylesheet" required="true" />
		<cfargument name="customStylesheet" required="true" />
		<cfargument name="htmlOutputDirectory" required="true" />
		<cfargument name="header" default="" />
		<cfargument name="footer" default="" />
		<cfscript>
		
		var originalStylesheetContents = "";
		var customStylesheetContents = "";
		
		originalStylesheetContents = this.fileRead( arguments.originalStylesheet );
		//replace XSL with the custom values 	
		customStylesheetContents = replaceNoCase(originalStylesheetContents,  "@htmlOutputDirectory@",  arguments.htmlOutputDirectory);
		customStylesheetContents = replaceNoCase(customStylesheetContents,  "@header@",  arguments.header);
		customStylesheetContents = replaceNoCase(customStylesheetContents,  "@footer@",  arguments.footer);
		</cfscript>

		<cffile action="WRITE" file="#arguments.customStylesheet#" output="#customStylesheetContents#" addnewline="No" charset="UTF-8" >
		
	</cffunction>
	
	<cffunction name="fileRead" output="false" hint="wrapper for cffile so we can use it in cfscript">
		<cfargument name="file" required="true" />
		<cfset var fileContents = "" />
		<cffile action="READ" file="#arguments.file#" variable="fileContents" />
		<cfreturn fileContents />
	
	</cffunction>
	
	
	<cfscript>
	function generateArgumentList(thisMethod) {
		var result = "";
		var i = "";
		var argCount = arrayLen(thisMethod.arguments);
		for (i = 1; i LTE argCount; i = i + 1) {
			result = result & generateArgument(thisMethod.arguments[i]);
			if (i LT argCount)
				result = result & ", "; 
		}
		return result;
	}
	
	function generateArgument(argument) {
		var result = "";
		var argUrl = "";

		if (NOT argument.required)
			result = result & "["; 
		argUrl = util.getDetailURL(argument.type,stComponent.path);
		if (not findNoCase("unknowncomponent",  argUrl) ){
			result = result & '<ulink url="#argUrl#">#listLast(argument.type, '.')#</ulink> #argument.name#';
		} else {
			result = result & '#listLast(argument.type, '.')# #argument.name#';
		}
		if (NOT argument.required) {
			if (structKeyExists(argument, "default")) {
				result = result & '="' & argument["default"] &'"';
			}
			result = result & "]";
		}
		return result;
	}
	
</cfscript>
	
</cfcomponent>

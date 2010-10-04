<cfcomponent output="false" hint="main controller.">
	
	<cffunction name="init" output="false" hint="Constructor, passed in the FW/1 instance.">
		<cfargument name="fw" />
		<cfscript>
		
		variables.fw = arguments.fw;
		return this;
		
		</cfscript>		
	</cffunction>
	
	<cffunction name="default" output="false">
		<cfargument name="rc" />
		<cfscript>
		
		variables.fw.setView("main.start");
			
		</cfscript>
	</cffunction>
			
	<cffunction name="generateDocs" output="false" >
		<cfargument name="rc" />
		<cfscript>
		
		//validate the form
		var formErrors = structNew();
		var hasErrors = false;
	
		rc.cfcBasePath = trim(rc.cfcBasePath);
		rc.title = trim(rc.title);
	
		//trim any trailing slash from cfcBasePath
		if (len(rc.cfcBasePath) and find(right(rc.cfcBasePath,  1),  "/\") )
			rc.cfcBasePath = left(rc.cfcBasePath,  len(rc.cfcBasePath)-1);
	
		if (not len(rc.cfcBasePath))
		{
			formErrors.cfcBasePath_required = "Please select a directory.";
		} 
		else
		{
			if (not directoryExists(rc.cfcBasePath))
			{
				formErrors.cfcBasePath_exists = "Directory not found.";
			}
		}
		
		if (not len(rc.title))		
			formErrors.title_required = "Please enter a title.";
		
		
		hasErrors = not (structIsEmpty(formErrors));
		
		if (hasErrors)
		{
			rc.formErrors = formErrors;
			//display the form with errors
			variables.fw.setView("main.start");
		}
		else
		{
			//process the cfcomponent files and create the DocBook xml file			
			var projectDir= "#application.basePath#docs";
			rc.projectDir = projectDir;
			application.fso.refreshDirectory(projectDir); 
			var generateResults = application.cfcdoc.generateDocBookXml(title=rc.title, parseHeaderMode=rc.parseHeaderMode, cfcBasePath=rc.cfcBasePath);			
			rc.filequery = generateResults.filequery;
			
			// customize the stylesheet 
			originalStylesheet="#application.basePath#xsl#application.directorySeparator#cfcdoc_template.xsl";
			customStylesheet="#projectDir##application.directorySeparator#cfcdoc.xsl";
			application.cfcdoc.customizeStyleSheet(originalStylesheet=originalStylesheet,customStylesheet=customStylesheet,htmlOutputDirectory=rc.htmlOutputDirectory,footer=rc.footer);
			var destination="#projectDir##application.directorySeparator#cfcdoc.xml";								
			var result = application.cfcdoc.saveDocBook(docbookxml=generateResults.docbookxml,destination=destination);
			var xslfile="#projectDir##application.directorySeparator#cfcdoc.xsl";
			var xmlfile="#projectDir##application.directorySeparator#cfcdoc.xml";
			var transformresult = application.cfcdoc.transformDocBook(xslfile=xslfile,xmlfile=xmlfile);
			rc.transformresult = transformresult;
			
			//copy the supporting files to the output directory
			var cssfile = "#application.basePath#css#application.directorySeparator#cfcdoc.css";
			application.fso.copyToDirectory(source=cssfile,destination=projectDir);
			var nativetypesfile = "#application.basePath#views#application.directorySeparator#nativetypes.html";
			application.fso.copyToDirectory(source=nativetypesfile,destination=projectDir);			
			var unknowncomponentfile = "#application.basePath#views#application.directorySeparator#unknowncomponent.html";
			application.fso.copyToDirectory(source=unknowncomponentfile,destination=projectDir);
			
			//generate files for eclipse
			var htmlBasePath = "#projectDir##application.directorySeparator##rc.htmlOutputDirectory##application.directorySeparator#";
			application.cfcdoc.generateEclipseTableOfContents(htmlBasePath=htmlBasePath,title=rc.title);
			application.cfcdoc.generateFrames(htmlBasePath);
			
			//create the zipfile 
			var zipPath = "#projectDir##application.directorySeparator##rc.htmlOutputDirectory#.zip";
			application.fso.zipFileNew(zipPath=zipPath,toZip=htmlBasePath,relativeFrom=htmlBasePath);
				
		}
		</cfscript>
	</cffunction>
	
	<cffunction name="createPDF" output="false" >
		<cfargument name="rc" />
		<cfscript>	
		
		var projectDir = "#application.basePath##rc.projectOutputDirectory#";
		var xmlfile = "#projectDir##application.directorySeparator#cfcdoc.xml";
		var xmlfileforpdf = "#projectDir##application.directorySeparator#cfcdoc_pdf.xml";
		application.cfcdoc.createDocBookForPDF(xmlfile=xmlfile,destination=xmlfileforpdf);
		//create an FO file
		var xslfile = "#application.basePath#xsl#application.directorySeparator#cfcdoc_fo_template.xsl";
		var fofile = "#projectDir##application.directorySeparator#cfcdoc.fo";						
		application.cfcdoc.xml2fo(xslfile=xslfile,xmlfile=xmlfileforpdf,fofile=fofile);	
		//process the FO file into a pdf	
		var fo2pdflogfile = "#projectDir##application.directorySeparator#cfcdoc_fo2pdf_log.txt";
		rc.pdffile = "#projectDir##application.directorySeparator#cfcdoc.pdf";		
		rc.fo2pdfresults  = application.cfcdoc.fo2pdf(fopExecutablePath=application.fopExecutablePath,fofile=fofile,pdffile=rc.pdffile,logfile=fo2pdflogfile);
		
		</cfscript>
	</cffunction>
	
	<cffunction name="browseServer" output="false" >
		<cfargument name="rc" />
		<cfscript>
		
		rc.dtree = application.fso.getTree(application.rootPathsList,application.isWindowsPlatform,rc.refreshFolders);
		
		</cfscript>
	</cffunction>
			
</cfcomponent>

<cfset basePath = expandPath('./') />
<cffile action="read" file="#basePath#/config/config.xml" variable="config">

<cfscript>
	configXML = xmlParse(config);

	application.constructorNames = "init";
	application.isWindowsPlatform = (server.os.name contains "windows");
	application.licensekey = "";
	application.rootPathsList = trim(configXML.config.rootPathsList.xmlText);

	if (not len(application.rootPathsList))	{
		if (application.isWindowsPlatform){
			//get the root drive letter
			application.rootPathsList = left(expandPath('./'),  1) & ":";
		} else {
			// get the root folder
			application.rootPathsList = "/" & listFirst(basePath,"/");
		}
	}

	if (application.isWindowsPlatform){
		application.directorySeparator = "\";
		application.fopExecutablePath = basePath & "fop\fop.bat";
	} else {
		application.directorySeparator = "/";
		application.fopExecutablePath = basePath & "fop/fop.sh";
	}

</cfscript>
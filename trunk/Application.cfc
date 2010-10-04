<cfcomponent extends="framework" output="false">

<!--- processing can take a long time so give the request a lot of time --->
<cfsetting requestTimeout="500">
	
	<!--- framework defaults (as struct literal):
	variables.framework = {
		// the name of the URL variable:
		action = 'action',
		// whether or not to use subsystems:
		usingSubsystems = false,
		// default subsystem name (if usingSubsystems == true):
		defaultSubsystem = 'home',
		// default section name:
		defaultSection = 'main',
		// default item name:
		defaultItem = 'default',
		// if using subsystems, the delimiter between the subsystem and the action:
		subsystemDelimiter = ':',
		// if using subsystems, the name of the subsystem containing the global layouts:
		siteWideLayoutSubsystem = 'common',
		// the default when no action is specified:
		home = defaultSubsystem & ':' & defaultSection & '.' & defaultItem,
		-- or --
		home = defaultSection & '.' & defaultItem,
		// the default error action when an exception is thrown:
		error = defaultSubsystem & ':' & defaultSection & '.error',
		-- or --
		error = defaultSection & '.error',
		// the URL variable to reload the controller/service cache:
		reload = 'reload',
		// the value of the reload variable that authorizes the reload:
		password = 'true',
		// debugging flag to force reload of cache on each request:
		reloadApplicationOnEveryRequest = false,
		// flash scope magic key and how many concurrent requests are supported:
		preserveKeyURLKey = 'fw1pk',
		maxNumContextsPreserved = 10,
		// either CGI.SCRIPT_NAME or a specified base URL path:
		baseURL = 'useCgiScriptName',
		// change this if you need multiple FW/1 applications in a single CFML application:
		applicationKey = 'org.corfield.framework'
	};
	--->
	
	<cffunction name="setupApplication">
		
		<cfset basePath = expandPath('./') />
		<cffile action="read" file="#basePath#/config/config.xml" variable="config">
		
		<cfscript>
			configXML = xmlParse(config);
			
			application.basePath = basePath;
			application.constructorNames = "init";
			application.isWindowsPlatform = (lcase(server.os.name) contains "windows");
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
			
			application.cfcdoc = CreateObject("component", "model.cfcdoc").init();
			application.fso = CreateObject("component", "model.FileSystemObject").init("", application.directorySeparator);
		
		</cfscript>
	</cffunction>
	
	<cffunction name="setupRequest">
		<!--- use setupRequest to do initialization per request --->
		<cfset request.context.startTime = getTickCount() />
	</cffunction>
	
</cfcomponent>
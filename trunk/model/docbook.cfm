
<cfparam name="attributes.title"  />
<cfparam name="attributes.introduction" default="" />
<cfparam name="attributes.pathIndex" default="1" />
<cfparam name="attributes.parseHeaderMode"  />

<cfscript>
	isFullLicense = not(application.isEvaluationKey);
	session.skippedFiles = "";
	skipFileIncrement = 3; //in eval mode, generate 1 out of 3 files
	
	paths = arrayNew(1);
	package = structNew();
	package.prefix = listLast(attributes.cfcBasePath,'/\');
	path = trim(attributes.cfcBasePath);
	package.path = path;
	arrayAppend(paths,package);
	
	querystore = structNew();
	packageRoot = listLast(attributes.cfcBasePath,'/\');
	
	if (server.os.name contains "windows")
  		directorySeparator = "\";
	else
	  	directorySeparator = "/";

	util = createObject('component','cfcdoc.model.Util').init(attributes.cfcBasePath,packageroot,directorySeparator,paths);
	util.setRootPath(attributes.cfcBasePath);
	
	dtdPath = expandPath('./');
	if (right(dtdPath,  1) NEQ directorySeparator )
		dtdPath = dtdPath & directorySeparator & "docbook" & directorySeparator & "dtd" & directorySeparator & "docbookx.dtd";
	else
		dtdPath = dtdPath & "docbook" & directorySeparator & "dtd" & directorySeparator & "docbookx.dtd";		
		dtdPath = replace(dtdPath,  "\",  "/" ,  "ALL"); 
</cfscript>

<cfloop from="1" to="#arrayLen(paths)#" index="i">
	<cfset currentpath = paths[i].path>
	<cfif not structKeyExists(queryStore,currentpath)>
		<cfset queryStore[currentpath] = structNew()>
	</cfif>
	<cfset fso = createObject('component','cfcdoc.model.FileSystemObject').init(currentpath,directorySeparator)>
	
	<cfif not structKeyExists(queryStore[currentpath],'filequery')>
		<cfset queryStore[currentpath].fileQuery = fso.list(true,'*.cfc',paths[i].prefix) />
	</cfif>
</cfloop>

<!--- <cfdump var="#paths#">  --->
<cfset filequery = queryStore[attributes.cfcBasePath].filequery />

<cfquery dbtype="query" name="orderedQuery">
	SELECT *, name AS lname
	FROM fileQuery
</cfquery>

<cfset orderedQuery = fso.fileQueryWithLowerCaseName(orderedQuery) />

<cfset tmpquery = queryStore[paths[attributes.pathIndex].path].filequery>  

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
  <title><cfoutput>#attributes.title#</cfoutput></title>
  <titleabbrev></titleabbrev>

  <cfif len(attributes.introduction)>
  <preface id="introduction"><title>Introduction</title>
    <para><cfoutput>#attributes.introduction#</cfoutput>
    </para>
  </preface>
  </cfif>
<cfoutput query="tmpquery" group="package">
	<cfset currentPackage = tmpquery.package />
	<chapter id="#trim(tmpquery.package)#"><?dbhtml dir="#trim(tmpquery.package)#" ?><title>#util.getPackageDisplayName(tmpquery.package)#</title>
    
	<cfloop query="orderedQuery">		
		<cfif isFullLicense OR ( application.isEvaluationKey AND NOT (orderedQuery.currentrow MOD skipFileIncrement)) > 
			<cfif currentPackage EQ orderedQuery.package>	
			<cfset cfcfile = orderedQuery.fullpath & application.directorySeparator & orderedQuery.name />
			<cfset stComponent = util.getCFCInformation(cfcfile,attributes.parseHeaderMode) />						
			<cfset sectionID = orderedQuery.package & "." & listFirst(orderedQuery.name,'.') />
			<!--- if the cfc file is empty/invalid it might not have a name so check first--->
			<cfset isComponentValid = structKeyExists(stComponent, "name") />  			
			<cfif isComponentValid >
			<?custom-pagebreak?>
			<section id="#sectionID#">
				<title>#listFirst(orderedQuery.name,'.')#</title>																			
					<cfinclude template="docbooktemplate.cfm">
			</section>
			</cfif>
			</cfif>
		<cfelse> <!--- skipped a file due to eval mode --->
			<cfset session.skippedFiles = listAppend(session.skippedFiles,  orderedQuery.name) /> 
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

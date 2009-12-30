<!--- I generate the files for the frame-based view --->

<cfif not directoryExists(attributes.htmlBasePath)>
	<cfdirectory action="CREATE" directory="#attributes.htmlBasePath#">
</cfif>

<cfscript>
	allcomponents = queryNew("component,link");
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
<BODY bgcolor="white" text="black" link="#0000FF" vlink="#840084" alink="#0000FF">
<a href="allcomponents.html" target="components">All components</a>
<h3>Packages</h3>
</cfsavecontent>

<cfsavecontent variable="allcomponentshtml" >
<HTML>
<HEAD>
<META http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<TITLE></TITLE><LINK href="cfcdoc.css" rel="stylesheet" type="text/css">
</HEAD>
<BODY bgcolor="white" text="black" link="#0000FF" vlink="#840084" alink="#0000FF">
<h3>All Components</h3>
</cfsavecontent>

<cfset package_components_html = "" />


<CFDIRECTORY DIRECTORY="#attributes.htmlBasePath#" NAME="fileList">	

<cfoutput query="fileList" >
	<cfif type IS "dir">
		<cfset package_components_html = "" />
		<!--- add a link for the dir to the packages html --->
		<cfset packageshtml = packageshtml & '<a  href="#name#_components.html" target="components">#name#</a><br/>' />
		<CFDIRECTORY DIRECTORY="#attributes.htmlBasePath#/#name#" NAME="componentFiles">	
		<cfset subdir = "#name#" />
		<cfloop query="componentFiles">
			<cfif NOT type IS "dir">
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
		<cffile action="WRITE" file="#attributes.htmlBasePath##application.directorySeparator##subdir#_components.html" output="#package_components_html#" >
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

<cffile action="WRITE" file="#attributes.htmlBasePath##application.directorySeparator#index_frames.html" output="#index_frames#" >
<cffile action="WRITE" file="#attributes.htmlBasePath##application.directorySeparator#leftframe.html" output="#leftframe#" >
<cffile action="WRITE" file="#attributes.htmlBasePath##application.directorySeparator#packages.html" output="#packageshtml#" >
<cffile action="WRITE" file="#attributes.htmlBasePath##application.directorySeparator#allcomponents.html" output="#allcomponentshtml#" >

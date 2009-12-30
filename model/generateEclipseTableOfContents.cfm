<cfparam name="attributes.htmlBasePath" >
<cfparam name="attributes.title" >

<cfset toc = '<?xml version="1.0" encoding="utf-8" standalone="no"?><toc label="#attributes.title#" topic="index.html">' />

<CFDIRECTORY DIRECTORY="#attributes.htmlBasePath#" NAME="fileList">	

<cfoutput query="fileList" >
	<cfif type IS "dir">
		<cfset toc = toc & '<topic label="#name#" href="#name#/#name#.html">' />
		<CFDIRECTORY DIRECTORY="#attributes.htmlBasePath#/#name#" NAME="topicFiles">	
		<cfset subdir = "#name#" />
		<cfloop query="topicFiles">
			<cfif NOT type IS "dir">
				<cfif not(find(".css",  name) or find("unknowncomponent",name) or find("nativetypes", name) ) >
				<cfset toc = toc & '<topic label="#name#" href="#subdir#/#name#"></topic>' />
				</cfif>
			</cfif>
		</cfloop>
		<cfset toc = toc & '</topic>' />
	</cfif>
</cfoutput>			

<cfset toc = toc & '</toc>' />
<cfif not directoryExists(attributes.htmlBasePath)>
	<cfdirectory action="CREATE" directory="#attributes.htmlBasePath#">
</cfif>
<cffile action="WRITE" file="#attributes.htmlBasePath##application.directorySeparator#toc.xml" output="#toc#" >

<cfsavecontent variable="pluginxml" >
<?xml version="1.0" encoding="utf-8" standalone="no"?>
<plugin name="CFCDoc Documentation" id="htmlfiles" version="1.0" provider-name="provider-name">
  <extension point="org.eclipse.help.toc">
    <toc file="toc.xml" primary="true"/>
  </extension>
</plugin>
</cfsavecontent> 

<cffile action="WRITE" file="#attributes.htmlBasePath##application.directorySeparator#plugin.xml" output="#trim(pluginxml)#" >
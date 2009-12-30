<cfparam name="attributes.projectOutputDirectory" >
<cfparam name="attributes.htmlOutputDirectory" >

<cfscript>
	hasErrors = isDefined("transformresult") and len(trim(transformresult));
</cfscript>


<cfif hasErrors  >
	<h3><span style="color: red">CFCDoc error:</span></h3>
	<h3><span style="color: black"><cfoutput>#transformResult#</cfoutput></span></h3>
<cfelse>
	<h3>Documentation finished</h3>
	<br/>
	<br/>


	<a href="projects/<cfoutput>#attributes.projectOutputDirectory#/#attributes.htmlOutputDirectory#</cfoutput>/index.html" target="_blank">&gt;&gt;&nbsp;View the documentation</a> &nbsp;&nbsp;&nbsp;<a href="projects/<cfoutput>#attributes.projectOutputDirectory#/#attributes.htmlOutputDirectory#</cfoutput>/index_frames.html" target="_blank">(View with frames)</a>
	
	<br/>
	<br/>
	
	<a href="projects/<cfoutput>#attributes.projectOutputDirectory#/#attributes.htmlOutputDirectory#.zip</cfoutput>" >&gt;&gt;&nbsp;Download the documentation</a>
	<br>
	<br>
	<a href="index.cfm?do=cfcdoc.generatePDF&projectOutputDirectory=<cfoutput>#attributes.projectOutputDirectory#</cfoutput>" >&gt;&gt;&nbsp;Create PDF</a>
	
	<br/>
	<br/>
	<a href="index.cfm" >&gt;&gt;&nbsp;Start over</a>
	
	<br/>
	<br/>
	<P>
		<strong>To use in Eclipse IDE:</strong> Expand the zip file inside the Eclipse plugins directory.  If 
		you change the directory name you must change ID value in the plugin.xml file to match the directory name.
	</P>
	
	<P>
		<strong>To use in CFStudio/Homesite IDE:</strong> Expand the zip file inside the Help directory.
		The name of the directory will be the name displayed in the Help References Window.  Feel free to rename the directory.
	</P>
</cfif>
<hr/>
<u><strong>Summary of CFCs processed:</strong></u>
<cfif listLen(session.skippedFiles)>
	<br/><br/><span style="color: #c60;"><strong>Files in orange were skipped in evaluation mode.</strong></span>
</cfif>
<br/>
<br/>  
<cfoutput query="filequery" group="package">
Package:&nbsp;<strong>#package#</strong>&nbsp;(#fullpath#)	
	<ul>
		<cfoutput>
			<cfif not listFindNoCase(session.skippedFiles,  name) >
				<li>#name#</li>
			<cfelse>
				<span style="color: ##c60;"><li>#name#</li></span>
			</cfif>
		</cfoutput>
	</ul>
	<br/>	
</cfoutput>

<!--- <cfdump var=#orderedQuery#> --->
<!--- <cfdump var=#querystore#> --->
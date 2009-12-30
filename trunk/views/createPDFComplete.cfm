<cfparam name="attributes.projectOutputDirectory" >
<cfparam name="pdffile" type="string">


<cfif not fileExists(pdffile)  >
	<h3><span style="color: red">Error creating PDF:</span></h3>
	Log file:
	<textarea rows="20" cols="80"><cfoutput>#fo2pdfresults#</cfoutput></textarea>
<cfelse>
	<h3>PDF documentation finished</h3>
	<br/>
	<br/>
	
	
	<a href="projects/<cfoutput>#attributes.projectOutputDirectory#</cfoutput>/cfcdoc.pdf" target="_blank">&gt;&gt;&nbsp;View the PDF</a>
</cfif>

<br/>
<br/>
<a href="index.cfm" >&gt;&gt;&nbsp;Start over</a>

 
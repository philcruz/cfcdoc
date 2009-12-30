
<cfparam name="originalStylesheet" >
<cfparam name="customStylesheet" >

<cfparam name="attributes.htmlOutputDirectory" >
<cfparam name="attributes.header" default="" >

<!--- read in the original stylesheet --->
<cffile action="READ" file="#originalStylesheet#" variable="originalStylesheetContents">

<cfscript>
	//replace XSL with the custom values 	
	customStylesheetContents = replaceNoCase(originalStylesheetContents,  "@htmlOutputDirectory@",  attributes.htmlOutputDirectory);
	customStylesheetContents = replaceNoCase(customStylesheetContents,  "@header@",  attributes.header);
	customStylesheetContents = replaceNoCase(customStylesheetContents,  "@footer@",  attributes.footer);
</cfscript>

<cffile action="WRITE" file="#customStylesheet#" output="#customStylesheetContents#" addnewline="No" charset="UTF-8" >

 
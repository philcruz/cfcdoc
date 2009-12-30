<cffile action="READ" file="c:\temp\machii_info\userDAO_test.cfc" variable="filecontents">
<cfset attributes.parseHeaderMode = 'javadoc' />
<cfset parser = createObject('component','cfcdoc.model.CFCParser')>
<cfset parser.init()>
			
<cfset stComponent = parser.parse(fileContents,attributes.parseHeaderMode) />

<cfdump var=#stComponent.attributes#> 
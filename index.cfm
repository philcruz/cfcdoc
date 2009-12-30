









<cfif structKeyExists(url,"reloadapp") >
	<cfset structDelete(application,"fusebox") />
	<cfset structDelete(application,"init") />
</cfif>

<cfset FUSEBOX_APPLICATION_PATH = "" />
<cfinclude template="fb41corefiles/fusebox4.runtime.cfmx.cfm" />




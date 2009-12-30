
<cfapplication name="cfcdoc" sessionmanagement="yes" />

<cfparam name="application.initialized" default="false">

<cfscript>
	if (isDefined('url.reloadapp')) application.initialized = false;
</cfscript>



<cfparam name="attributes.cfcBasePath"  >
<cfparam name="attributes.title" default="" >


<cfscript>
	formErrors = structNew();
	hasErrors = false;
	
	attributes.cfcBasePath = trim(attributes.cfcBasePath);
	attributes.title = trim(attributes.title);
	
	//trim any trailing slash from cfcBasePath
	if (len(attributes.cfcBasePath) and find(right(attributes.cfcBasePath,  1),  "/\") )
		attributes.cfcBasePath = left(attributes.cfcBasePath,  len(attributes.cfcBasePath)-1);
	
	if (not len(attributes.cfcBasePath)){
		formErrors.cfcBasePath_required = "Please select a directory.";
	} else {
		if (not directoryExists(attributes.cfcBasePath)){
			formErrors.cfcBasePath_exists = "Directory not found.";
		}
	}
		
	if (not len(attributes.title)){
		formErrors.title_required = "Please enter a title.";
	}
	hasErrors = not (structIsEmpty(formErrors));
</cfscript>
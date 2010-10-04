
<!--- <cfparam name="rc.projectOutputDirectory" default="CFCDoc" > --->
<cfparam name="rc.htmlOutputDirectory" default="html" >
<cfparam name="rc.title" default="Enter a title" >
<cfparam name="rc.header" default="Header" >
<cfparam name="rc.footer" default="Made with CFCDoc" >
<cfparam name="formErrors" default="" >
<cfparam name="rc.isOutputForEclipse" default="0" >

	
<cfset isKeyValid = true />
	

<cfscript>	
	if (isDefined('rc.formErrors'))
		formErrors = rc.formErrors;

	if (not isDefined("rc.cfcBasePath")){
		rc.cfcBasePath = expandPath('./');
		if (right(rc.cfcBasePath,  1) NEQ application.directorySeparator )
			rc.cfcBasePath = rc.cfcBasePath & application.directorySeparator & "samples" & application.directorySeparator & "MachII";
		else
			rc.cfcBasePath = rc.cfcBasePath & "samples" & application.directorySeparator & "MachII";		
	}
	
	function displayFormErrors(formField, formErrors){
		var result = "";
		if (isStruct(formErrors) AND findNoCase(formField,  structKeyList(formErrors)) ){
			result = '<div class="formErrors" >';
			for (formerror in formErrors){		
				if (findNoCase(formfield,  formerror) ){		
					result = result & formErrors[formerror] & "<br/>";
				}
			}		
			result = result & '</div>';
		} 
		return result;
	}
</cfscript>

<h3>Step 1: Select the directory with your CFCs</h3>



<form name="selectPathForm" action="index.cfm?action=main.generateDocs" method="POST">
<!--- <input type="hidden" name="projectOutputDirectory" value="<cfoutput>#rc.projectOutputDirectory#</cfoutput>" /> --->
<input type="hidden" name="htmlOutputDirectory" value="<cfoutput>#rc.htmlOutputDirectory#</cfoutput>" />
<table border="0" style="padding: 10px;background: whitesmoke;">
	<tr>
		<td valign="top" nowrap="nowrap">
			<span class="formLabel">Directory Path:</span><br>
			<span style="font-size: 10px;"><a href="index.cfm?action=main.browseServer&refreshFolders=0" onclick="NewWindow(this.href,'browseServer','400','350','yes');return false">Browse&gt;&gt;</a></span>
		</td>
		<td>
			<input name="cfcBasePath" value="<cfoutput>#rc.cfcBasePath#</cfoutput>" size="50" />
			<cfoutput>#displayFormErrors("cfcBasePath",formErrors)#</cfoutput>
		</td>		
	</tr>	
	<tr>
		<td valign="top"><span class="formLabel">Title:</span></td>
		<td>
			<input name="title" value="<cfoutput>#rc.title#</cfoutput>" size="50" maxlength="100" />
			<cfoutput>#displayFormErrors("title",formErrors)#</cfoutput>
		</td>
	</tr>	
	<tr>
		<td valign="top"><span class="formLabel">Footer:</span></td>
		<td>
			<input name="footer" value="<cfoutput>#rc.footer#</cfoutput>" size="50" maxlength="200" />
		</td>
	</tr>	
	<tr>
		<td valign="top" nowrap="nowrap"><span class="formLabel">Header Comments:</span></td>
		<td>
			<select name="parseHeaderMode" >
				<option value="">None</option>
				<option value="javadoc">Javadoc</option>
				<option value="custom">Custom</option>
			</select>&nbsp;**
		</td>
	</tr>	
	<tr>
		<td>&nbsp;</td>
		<td>
			<input  type="submit" name="submit" value="Next &gt;&gt;" />
		</td>
	</tr>	
</table>
</form>

<br/>
<br/>

** &nbsp;CFC.Doc supports comments in the file header of CFC files.  The valid choices are
<ul>
	<li>None - ignores any comments above the starting &lt;CFCOMPONENT&gt; tag</li> 
	<li>Javadoc - CFC.Doc will parse the comments for Javadoc-like tag parameters: @author,@version</li>
	<li>Custom - CFC.Doc will not parse the comments but the entire file header will be displayed in the generated documentation</li>
</ul>

<!---// this code must execute after the end </FORM> tag //--->
<SCRIPT LANGUAGE="JavaScript">
	objForm = new qForm("selectPathForm");
	objForm.required("cfcBasePath");
</SCRIPT>



<!--- create some white space to make the left border extend --->
<cfoutput>#repeatString("<br/>",  15)#</cfoutput>	


<!--- <cfdump var=#rc#> --->

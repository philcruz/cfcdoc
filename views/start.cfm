
<cfparam name="attributes.projectOutputDirectory" default="CFCDoc" >
<cfparam name="attributes.htmlOutputDirectory" default="htmlfiles" >
<cfparam name="attributes.title" default="Enter a title" >
<cfparam name="attributes.header" default="Header" >
<cfparam name="attributes.footer" default="Made with CFCDoc" >
<cfparam name="formErrors" default="" >
<cfparam name="attributes.isOutputForEclipse" default="0" >

	
<cfset isKeyValid = application.cfcdoc.isKeyValid(application.licensekey) />
	

<cfscript>	
	if (not isDefined("attributes.cfcBasePath")){
		attributes.cfcBasePath = expandPath('./');
		if (right(attributes.cfcBasePath,  1) NEQ application.directorySeparator )
			attributes.cfcBasePath = attributes.cfcBasePath & application.directorySeparator & "MachII";
		else
			attributes.cfcBasePath = attributes.cfcBasePath & "MachII";		
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



<form name="selectPathForm" action="index.cfm" method="POST">
<input type="hidden" name="do" value="cfcdoc.generatedocbook" />
<input type="hidden" name="projectOutputDirectory" value="<cfoutput>#attributes.projectOutputDirectory#</cfoutput>" />
<input type="hidden" name="htmlOutputDirectory" value="<cfoutput>#attributes.htmlOutputDirectory#</cfoutput>" />
<table border="0" style="padding: 10px;background: whitesmoke;">
	<tr>
		<td valign="top" nowrap="nowrap">
			<span class="formLabel">Directory Path:</span><br>
			<span style="font-size: 10px;"><a href="index.cfm?do=cfcdoc.browseServer&refreshFolders=0" onclick="NewWindow(this.href,'browseServer','400','350','yes');return false">Browse&gt;&gt;</a></span>
		</td>
		<td>
			<input name="cfcBasePath" value="<cfoutput>#attributes.cfcBasePath#</cfoutput>" size="50" />
			<cfoutput>#displayFormErrors("cfcBasePath",formErrors)#</cfoutput>
		</td>		
	</tr>	
	<tr>
		<td valign="top"><span class="formLabel">Title:</span></td>
		<td>
			<input name="title" value="<cfoutput>#attributes.title#</cfoutput>" size="50" maxlength="100" />
			<cfoutput>#displayFormErrors("title",formErrors)#</cfoutput>
		</td>
	</tr>	
	<tr>
		<td valign="top"><span class="formLabel">Footer:</span></td>
		<td>
			<input name="footer" value="<cfoutput>#attributes.footer#</cfoutput>" size="50" maxlength="200" />
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


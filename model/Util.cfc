<cfcomponent hint="The util component provides utility methods for the rest of the application">
	
	
	<cfset variables.rootpath = "">
	<cfset variables.packageroot = "">
	<cfset variables.directorySeparator = "">
	<cfset variables.nativetypes = "any,array,binary,boolean,date,guid,numeric,query,string,struct,uuid,variablename,void">
	<cfset variables.paths = "">
	
	<cffunction name="init" access="public" returntype="Util" output="false" hint="Initializes the component and sets up the variables that the other methods in the component need.">
		<cfargument name="rootpath" type="string" required="yes" />
		<cfargument name="packageRoot" type="string" required="yes" />
		<cfargument name="directorySeparator" type="string" required="yes" />
    	<cfargument name="paths" type="array" required="true" />
		
		<cfset variables.rootpath = arguments.rootpath>
		<cfset variables.packageRoot = arguments.packageRoot>
		<cfset variables.directorySeparator = arguments.directorySeparator>
    	<cfset variables.paths = arguments.paths>
    
		<cfreturn this>
	
	</cffunction>
	
  <cffunction name="setRootPath" access="public" returntype="void">
    <cfargument name="rootpath" required="true" type="string">
    <cfset variables.rootpath = arguments.rootpath>
  </cffunction>
  


	<cffunction name="getDetailURL" access="public" returntype="string" output="false" hint="Figures out whether or not the passed string is a component in the current package. If so it generates the appropriate URL to view the documentation for that component. If not it returns a non-functioning URL.">
		<cfargument name="str" type="string" required="true" hint="Any string to be turned into a detail link">
		<cfargument name="currentpath" type="string" required="true" hint="The path to the directory containing the current component">
		<cfset var cfcfilepath = "" />
		<cfset var packagepath = "" />
		<cfset var result = "" />
		<cftry>
			<cfset cfcfilepath = getFilePath(str, currentpath) />
			<cfif not fileExists(cfcfilepath) >
				<cfthrow type="UnknownComponentException" >
			</cfif>
			<cfset packagePath = getPackageFromPath(cfcfilepath) />
			<cfif len(packagePath) >
				<!--- if it's in a package then we must go up from the current directory --->
				<cfset packagePath = "../" & packagePath  & "/" />
				<cfset result = "#packagePath##listLast(arguments.str,".")#.html" />
			<cfelse>
				<cfset result = "#arguments.str#.html" />
			</cfif>			
			<cfcatch type="UnknownComponentException">
				<cfset result =  "unknowncomponent.html" />
			</cfcatch>
			<cfcatch type="NativeTypeException">
				<cfset result =  "nativetypes.html##detail_#cfcatch.detail#" />
			</cfcatch>
		</cftry>
		<cfreturn result />
	</cffunction>


	<cffunction name="getFilePath" access="public" returntype="string" output="false" hint="Figures out whether or not the passed string is a component in the current package. If so it generates the appropriate file path to that component. If not it throws an exception." throws="UnknownComponentException,NativeTypeException">
		<cfargument name="str" type="string" required="true" hint="Any string to be turned into a detail link">
		<cfargument name="currentpath" type="string" required="true" hint="The path to the directory containing the current component">
		<cfset var path = "" />
		<cfset var filePath = "" />
		<cfset var matches = structNew() />
		<cfset var prefix = "" />
	    <cfset var newpath = "" />
	    <cfset var subPath = "" />
		<cfset var i = "" />
    
		<cfif listFirst(str,'./') eq variables.packageRoot>
			<cfset filePath = variables.rootpath & variables.directorySeparator & listChangeDelims(listRest2(arguments.str,'./'),variables.directorySeparator,'.') & '.cfc' />
    
    	<cfelseif reFind("[/\.]",str)>
      
	      <cfset str = listChangeDelims(str,'.','./') /> 
			
	      <cfloop from="1" to="#arrayLen(variables.paths)#" index="i">
	        <cfif findNoCase(variables.paths[i].prefix,str)>
	          <cfset path = variables.paths[i].path />
	          <cfset prefix = variables.paths[i].prefix />
	        </cfif>
	      </cfloop>
		  
		  <cfif path EQ variables.rootpath>
			<cfset str = listRest2(str, "/.") />			
			<!---
				 there's issue where if component is "MachII.framework.BaseComponent" 
				 and the path is like c:\cfusionmx\wwwroot\MachII\framework
				 it was not stripping the component down to BaseComponent
				 so check if the first part of the component is equal to the last part of the path
				 and if it is strip it.  This may be better of done recursively.
			--->
			<cfif findNoCase(listFirst(str,  "/.") ,  listLast(path,  variables.directorySeparator) ) >
				<cfset str = listRest2(str, "/.") />
			</cfif>
			<cfset path = "" />
		  </cfif>
      
	      <cfif len(path) GT 0>
	        <cfset str = listChangeDelims(str,variables.directorySeparator,'/.') />
			<cfset str = listRest(str, variables.directorySeparator) />
	        
			<cfloop list="#path#" index="i" delimiters="#variables.directorySeparator#">
			  <cfset newpath = listAppend(newPath,i,variables.directorySeparator) />
			  <cfset subPath = replaceNoCase(path,newPath & variables.directorySeparator,"") />
			  <cfif len(subPath) AND left(str,len(subPath)) EQ subPath>
				<cfbreak>
			  </cfif>
			</cfloop>
			<cfset filePath = newpath />
			<cfset filePath = filePath & variables.directorySeparator & str & '.cfc' />
		  <cfelse>		  	
	        <cfset str = listChangeDelims(str, variables.directorySeparator, ".") /> 
		  	<cfset filePath = variables.rootpath & variables.directorySeparator & str & ".cfc" />
	      </cfif>
        
		<cfelseif not listFindNoCase(variables.nativetypes,str)>
	
		  <cfset path = arguments.currentpath &  arguments.str & '.cfc' />
		  
		  <cflock type="READONLY" name="cfcdocfileaccess" timeout="5">
			<cfif fileExists(path)>
			  <cfset filePath = path />
			<cfelse>
			  <cfthrow type="UnknownComponentException" />
			</cfif>
		  </cflock>
		<cfelse>
			<cfthrow type="NativeTypeException"
		   		detail="#str#" />
		</cfif>

		<cfreturn filePath />
	</cffunction>
	
	
	<cffunction name="getPackageFromPath" access="public" returntype="string" output="false" hint="The getPackageFromPath method gets the package path for any given directory under the root path.">
		<cfargument name="path">
		
		<cfset var prefix = "">
		<cfset var subPath = "">
		<cfset var package = "">
    <cfset var matches = structNew()>
    <cfset var packagepath = "">
    

    <cfloop from="1" to="#arrayLen(variables.paths)#" index="i">
      <cfif findNoCase("#variables.paths[i].path#",path)>
        <cfset packagepath = variables.paths[i].path>
        <cfset prefix = variables.paths[i].prefix>
      </cfif>
    </cfloop>


    <cfif len(packagepath)>
  		<cfset subPath = prefix & variables.directorySeparator & replaceNoCase(arguments.path,packagepath,'')>
  		<cfif listLast(subPath,'.') is 'cfc'>
  			<cfset subPath = listDeleteAt(subPath,listLen(subPath,'/\'),'/\')>
  		</cfif>
  		
  		<cfset package = listChangeDelims(subPath,'.','/\')>
    <cfelse>
      <cfset package = "Unknown package">
		</cfif>
		
		<cfreturn package>
	</cffunction>
	
	
	
	<cffunction name="getPackageDisplayName" access="public" output="false" returntype="string"
		hint="I take a full package name and return the proper display string to represent it">
		<cfargument name="package" type="string" required="true" hint="The package name to translate for display" />
		<cfset package = getPackagePathFromRoot(package) />
		<cfif len(trim(package)) EQ 0>
			<cfset package = arguments.package />
		</cfif>
		<cfreturn trim(package) />
	</cffunction>
	
	
	
	<cffunction name="getPackageDisplayPrefix" access="public" output="false" returntype="string"
		hint="I take a full package name and return the proper display string to represent it as a prefix for a fully qualified CFC name">
		<cfargument name="package" type="string" required="true" hint="The package name to translate for display" />
		<cfset package = getPackagePathFromRoot(package) />
		<cfif len(trim(package)) GT 0>
			<cfset package = package & "." />
		</cfif>
		<cfreturn package />
	</cffunction>
	
	
	
	<cffunction name="getPackagePathFromRoot" access="private" output="false" returntype="string"
		hint="I take a full package name, and return the relative path from the root">
		<cfargument name="package" type="string" required="true" hint="The package name to translate" />
		
		<cfset var i = "" />
		
		<cfloop from="1" to="#arrayLen(variables.paths)#" index="i">
			<cfif left(package, len(variables.paths[i].prefix)) EQ variables.paths[i].prefix>
				<cfset package = removeChars(package, 1, len(variables.paths[i].prefix)) />
				<cfif len(trim(package)) NEQ 0>
					<!--- kill the leading period --->
					<cfset package = removeChars(package, 1, 1) />
				</cfif>
				<cfreturn package />
			</cfif>
		</cfloop>
		
		<cfthrow type="UnknownPackageRootException"
			message="The package root from the full package path was not recognized" />
	</cffunction>
	
	
	
	<cffunction name="getCFCInformation" access="public" output="false" returntype="struct"
		hint="I create complete CFC information for the specified CFC, including information about all it's superclasses">
		<cfargument name="file" type="string" required="true" hint="the file to generate information about" />
		<cfargument name="parseHeaderMode" type="string" required="true" hint="javadoc|custom|disabled - mode to parse file header" />

		<cfset var fileContents = "" />
		<cfset var parser = "" />
		<cfset var stComponent = structNew() />
		<cfset var stSuperComponent = structNew() />
		<cfset var filename = "" />
		<cfset var filepath = "" />
		<cfset var i = "" />

		<cffile action="read" file="#file#"  variable="fileContents">
		
		<cfif len(trim(filecontents))>
			<cfset parser = createObject('component','CFCParser')>
			<cfset parser.init()>
			
			<cfset stComponent = parser.parse(fileContents,arguments.parseHeaderMode) />
			<cfset filename = listLast(file,'/\') />
			<cfset filepath = replace(file,filename,'') />
			<cfset stComponent.name = listFirst(filename,'.') />
			<cfset stComponent.path = filepath />
			<cfset stComponent.package = getPackageFromPath(file) />
			<cfset stComponent.pathindex = 1 />
			<cfloop from="1" to="#arrayLen(paths)#" index="i">
				<cfif findNoCase(paths[i].path,file)>
					<cfset stComponent.pathindex = i />
					<cfbreak>
				</cfif>
			</cfloop> 
			<cfset stComponent.code = fileContents />
			
			<cfset variables.objectCache[file] = stComponent />
			
			<!--- duplicate to definitively sever from the cache --->
			<cfset stComponent = duplicate(stComponent) />
			
			<cfset stComponent.superComponentPath = "" />
			<cfif stComponent.attributes.extends NEQ "cfcomponent">			
				<!--- check if we can get a file path --->
				<cftry>
					<cfset stComponent.superComponentPath = getFilePath(stComponent.attributes.extends, stComponent.path) />
					<cfcatch type="Any">
						<cfset stComponent.superComponentPath = "unknownComponent">
					</cfcatch>
				</cftry>
				<cfif fileExists(stComponent.superComponentPath) >
					<cfset stComponent.superComponent = getCFCInformation(stComponent.superComponentPath,arguments.parseHeaderMode) />
				<cfelse>
					<!--- can't resolve the component --->
				</cfif>
			</cfif>
		</cfif>
		
		<cfreturn stComponent />
	</cffunction>
	
	<cffunction name="listRest2" output="false" hint="BD has a bug 1591 with list rest so implement a workaround">
		<cfargument name="alist" required="true" />
		<cfargument name="delimiters" required="true" type="string" />
		<cfif findNoCase("coldfusion",  server.coldfusion["productname"])>
			<cfreturn listRest(arguments.alist, arguments.delimiters) />
		<cfelse>
			<cfif findNoCase(mid(arguments.delimiters,  1,  1),  arguments.alist)>
				<cfreturn listRest(arguments.alist, mid(arguments.delimiters,  1,  1)) />
			<cfelse>
				<cfreturn listRest(arguments.alist, mid(arguments.delimiters,  2,  1)) />
			</cfif> 
		</cfif>
	</cffunction>
		
	<!---
	Replacement for XmlFormat that also replaces all special characters.
	
	@param txt      String to format. (Required)
	@return Returns a string. 
	@author David Hammond (dave@modernsignal.com) 
	@version 0, July 12, 2009 
	--->
	<cffunction name="XmlSafeText" hint="Replaces all characters that would break an xml file." returnType="string" output="false">        
	    <cfargument name="txt" type="string" required="true">
	    <cfset var chars = "">
	    <cfset var replaced = "">
	    <cfset var i = "">
	    
	    <!--- Use XmlFormat function first --->
	    <cfset txt = XmlFormat(txt)>
	    <!--- Get all other characters to replace. ---> 
	    <cfset chars = REMatch("[^[:ascii:]]",txt)>
	    <!--- Loop through characters and do replace. Maintain a list of characters already replaced to avoid duplicate work. --->
	    <cfloop index="i" from="1" to="#ArrayLen(chars)#">
	        <cfif listFind(replaced,chars[i]) is 0>
	            <cfset txt = Replace(txt,chars[i],"&##" & asc(chars[i]) & ";","all")>
	            <cfset replaced = ListAppend(replaced,chars[i])>
	        </cfif>
	    </cfloop>
	    <cfreturn txt>
	</cffunction>

</cfcomponent>

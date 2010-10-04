<cfcomponent hint="The FileSystemObject component provides methods to access and interact with the filesystem.">

	<cfset variables.rootpath = "" />
	<cfset variables.directorySeparator = "" />
	
	<cffunction name="init" access="public" output="false" returnType="FileSystemObject" hint="This method initializes the component setting the root path and directory separator that are used by the other methods.">
		<cfargument name="rootPath" type="string" required="false" default="" />
		<cfargument name="directorySeparator" required="true" type="string" />
		<cfscript>
			variables.directorySeparator = arguments.directorySeparator;
			variables.treeid = 0;
			variables.dtree = "";
			if ( isDefined("arguments.rootPath") and directoryExists(arguments.rootpath) ){
				variables.rootpath = arguments.rootpath;
			}		
			return this;
		</cfscript>
	</cffunction>
	
	
	
	<cffunction name="list" access="public" returntype="query" output="false" hint="The list method returns a list of all files in the directory path that match the given filter. It adds fullpath and package columns to the standard query returned by the cfdirectory tag. If the recurse argument is set to true, the method will also return the contents of all sub-directories of the rootpath.">
		<cfargument name="recursive" default="false" type="boolean" />
		<cfargument name="filter" default="" type="string" />
    	<cfargument name="prefix" required="yes">
		<cfargument name="path" required="false" default="#variables.rootpath#" />
		
		<cfset var tempFiles = "" />
		<cfset var qFiles = "" />
		<cfset var qSubDirectoryFiles = "" />
		<cfset var aPath = arrayNew(1) />
		<cfset var aPackage = arrayNew(1) />
		<cfset var aQueries = arrayNew(1) />
		<cfset var i = 0 />
		<cfset var packageStart = "" />
		<cfset var subPath = "" />
		<cfset var package = "" />
		<cfset var q1 = "" />
		<cfset var q2 = "" />
		
		<cfset arguments.filter = lcase(replace(arguments.filter,'*','%','all')) />
		
		<cfdirectory action="list" directory="#arguments.path#" name="qFiles">
				
		<cfif qFiles.recordcount>
		
			<cfset subPath = prefix & directorySeparator & replaceNoCase(arguments.path,variables.rootpath,'') />
			<!--- replace any double slashes with single slashes --->
			<cfset subPath = replace(subPath,  variables.directorySeparator & variables.directorySeparator,  variables.directorySeparator ,  "ALL") />  
			<!--- change slash delimiters to dots --->
			<cfset package = replace(subpath, variables.directorySeparator,'.', "ALL") />
			<cfif right(package,  1) EQ '.'>
				<!--- remove a trailing . --->
				<cfset package = left(package, len(package)-1) />
			</cfif>
		
			<cfset arraySet(aPath,1,qFiles.recordcount,arguments.path) />
			<cfset arraySet(aPackage,1,qFiles.recordcount,package) />
		
		</cfif>
		
		<cfset queryAddColumn(qFiles,'fullpath',aPath) />
		<cfset queryAddColumn(qFiles,'package',aPackage) />
		
		
		<cfif arguments.recursive>
			<cfloop query="qFiles">
				<cfif qFiles.type is 'dir'>
					<cfset arrayAppend(aQueries,this.list(true,arguments.filter,arguments.prefix,arguments.path & variables.directorySeparator & qFiles.name)) />
				</cfif>
			</cfloop>
								
			<cfloop from="1" to="#arrayLen(aQueries)#" index="i">
				<cfset q = aQueries[i] />
				<cfif q.recordCount>		
					<cfquery dbtype="query" name="q1">
						SELECT *
						FROM qFiles
						<cfif len(arguments.filter)>
						WHERE qFiles.name LIKE('#arguments.filter#')
						</cfif>
					</cfquery>
					<cfquery dbtype="query" name="q2">
						SELECT *
						FROM q
						<cfif len(arguments.filter)>
						WHERE q.name LIKE('#arguments.filter#')
						</cfif>
					</cfquery>
					<cfset qFiles = this.union(q1,q2) />
				</cfif>
			</cfloop>
			
		</cfif>
		
		<cfquery dbtype="query" name="qFiles">
			SELECT *
			FROM qFiles
			<cfif len(arguments.filter)>
				WHERE qFiles.name LIKE('#arguments.filter#')
			</cfif> 
		</cfquery>
		
		<cfreturn qFiles />
		
	</cffunction>
	
	<cffunction name="deleteDirectory" returntype="void" output="false">
		<cfargument name="directory" type="string" required="true" />
		<cfscript>
			var fileList = 0;
			var tempDir = "";
		</cfscript>
		
		<cfif directoryExists(arguments.directory) >
			<CFDIRECTORY DIRECTORY="#arguments.directory#" NAME="fileList">	
			<!--- delete files --->
			<cfoutput query="fileList" >
				<cfif lcase(type) IS "dir">
					<cfset tempDir = "#arguments.directory#/#name#" />
					<cfset this.deleteDirectory(tempDir) />
				<cfelse>
					<cffile action="delete" file="#arguments.directory##variables.directorySeparator##name#">
				</cfif>
			</cfoutput>			
			<!--- directory is now empty so we can delete --->
			<cfdirectory action="DELETE" directory="#arguments.directory#">
		</cfif>
	</cffunction>
	
	<cffunction name="createDirectory" returntype="void" output="false">
		<cfargument name="directory" type="string" required="true" />
		<cfif not directoryExists(arguments.directory) >
			<cfdirectory action="CREATE" directory="#arguments.directory#" >
		</cfif>
	</cffunction>
	
	<cffunction name="refreshDirectory" returntype="void" output="false" hint="use to empty a directory">
		<cfargument name="directory" type="string" required="true" />
		<cfscript>
			this.deleteDirectory(arguments.directory);
			//getting some errors on create directory that directory already exists
			//put in a delay to make sure the dir is completely deleted
			var thread = CreateObject("java", "java.lang.Thread");
			thread.sleep(500);
			this.createDirectory(arguments.directory);
		</cfscript>
	</cffunction>
	
	<cffunction name="copyToDirectory" returntype="void" output="false">
		<cfargument name="source" type="string" required="true" />
		<cfargument name="destination" type="string" required="true" />
		<cfscript>
			var subDir = "";
		</cfscript>
		
		<!--- copy the file to this directory --->
		<cffile action="COPY" source="#arguments.source#" destination="#arguments.destination#" >			
		<!--- copy to any subdirectories --->
		<CFDIRECTORY DIRECTORY="#arguments.destination#" NAME="fileList">	
		<cfoutput query="fileList" >
			<cfif lcase(type) IS "dir">
				<cfset subDir = "#arguments.destination#/#name#" />
				<cfset this.copyToDirectory(arguments.source,subDir) />				
			</cfif>
		</cfoutput>				
	</cffunction>
	
	<cffunction name="fileQueryWithLowerCaseName" returntype="query" output="false" hint="convert names to lowercase due to BDs lack of lower() function">
		<cfargument name="fileQuery" type="query" required="true" />
		<cfset var lcaseQuery = arguments.fileQuery />
		<cfset var orderedQuery = "" />
		<cfset var i = "" />
		<cfset var lcasename = "" />
		<cfset var numRecords = lcaseQuery.recordCount />
		
		<cfif numRecords >
			<cfloop from="1" to="#numRecords#" index="i">
				<cfset lcasename = lcase(lcaseQuery.name[i]) />
				<cfset querySetCell(lcaseQuery,  "lname",  lcasename ,  i) />  
			</cfloop>
		</cfif>
		<!--- order the query by lname --->
		<cfquery dbtype="query" name="orderedQuery">
			SELECT *
			FROM 	lcaseQuery
			ORDER BY lname ASC
		</cfquery>
		<cfreturn orderedQuery />
	</cffunction>
			
	<cffunction name="union" returntype="query" output="false" hint="BD can't union cffile queries bug 1587">
		<cfargument name="q1" type="query" required="true" />
		<cfargument name="q2" type="query" required="true" />
		<cfset var q = arrayNew(1) />		
		<cfset var collist = "name,size,type,datelastmodified,attributes,mode,fullpath,package" />
		<cfset var q3 = queryNew("name,size,type,datelastmodified,attributes,mode,fullpath,package") />
		<cfset var currentq = "" />
		<cfset var colname = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />
		
		<cfif findNoCase("coldfusion",server.coldfusion["productname"]) >
			<cfquery dbtype="query" name="q3">
				SELECT *
				FROM q1
				
				UNION
				
				SELECT *
				FROM q2
				
				ORDER BY fullpath
			</cfquery>
		<cfelse>
			<!--- BD can't UNION queries from CFFILE --->
			<cfset q[1] = arguments.q1 />
			<cfset q[2] = arguments.q2 />
			<cfloop from="1" to="2" index="i">
				<cfset currentQ = q[i] />
				<cfloop from="1" to="#currentQ.recordCount#" index="j">
					<cfscript>
						queryAddRow(q3,  1); 
						for (k=1; k lte listLen(collist); k=k+1) {
							colname = listGetAt(collist,k);
							querySetCell(q3,  colname,  currentQ[colname][j]); 
							}					
					</cfscript>
				</cfloop>		
			</cfloop>
			<!--- need to order the union by fullpath --->
			<cfquery dbtype="query" name="q3">
				SELECT *
				FROM q3
				ORDER BY fullpath
			</cfquery>
		</cfif>
		
		<cfreturn q3 />	
	</cffunction>
	
	<!--- <cffunction name="zipFileNew" output="false" >
		<cfargument name="zipPath" type="string" required="true" />
		<cfargument name="toZip" type="string" required="true" />
		<cfzip file="#arguments.zipPath#" source="#arguments.toZip#" />
	</cffunction> --->
	
	<cffunction name="zipFileNew" returntype="string" output="false" >
		<cfargument name="zipPath" type="string" required="true" />
		<cfargument name="toZip" type="string" required="true" />
		<cfargument name="relativeFrom" type="string" required="false" default="" hint="which part of the file path should be excluded in the zip?"/>
		<cfscript>
			/**
			 * Create a zip file of a directory or just a file.
			 * 
			 * @param zipPath 	 File name of the zip to create. (Required)
			 * @param toZip 	 Folder or full path to file to add to zip. (Required)
			 * @param relativeFrom 	 Some or all of the toZip path, from which the entries in the zip file will be relative (Optional)
			 * @return Returns nothing. 
			 * @author Nathan Dintenfass (nathan@changemedia.com) 
			 * @version 1.1, January 19, 2004 
			 */

			//make a fileOutputStream object to put the ZipOutputStream into
			var output = createObject("java","java.io.FileOutputStream").init(zipPath);
			//make a ZipOutputStream object to create the zip file
			var zipOutput = createObject("java","java.util.zip.ZipOutputStream").init(output);
			//make a byte array to use when creating the zip
			//yes, this is a bit of hack, but it works
			var byteArray = repeatString(" ",1024).getBytes();
			//we'll need to create an inputStream below for writing out to the zip file
			var input = "";
			//we'll be making zipEntries below, so make a variable to hold them
			var zipEntry = "";
			var zipEntryPath = "";
			//we'll use this while reading each file
			var len = 0;
			//a var for looping below
			var ii = 1;
			//a an array of the files we'll put into the zip
			var fileArray = arrayNew(1);
			//an array of directories we need to traverse to find files below whatever is passed in
			var directoriesToTraverse = arrayNew(1);
			//a var to use when looping the directories to hold the contents of each one
			var directoryContents = "";
			//make a fileObject we can use to traverse directories with
			var fileObject = createObject("java","java.io.File").init(toZip);				
			
			//
			// first, we'll deal with traversing the directory tree below the path passed in, so we get all files under the directory
			// in reality, this should be a separate function that goes out and traverses a directory, but cflib.org does not allow for UDF's that rely on other UDF's!!
			//
			
			//if this is a directory, let's set it in the directories we need to traverse
			if(fileObject.isDirectory())
				arrayAppend(directoriesToTraverse,fileObject);
			//if it's not a directory, add it the array of files to zip
			else
				arrayAppend(fileArray,fileObject);	
			//now, loop through directories iteratively until there are none left
			while(arrayLen(directoriesToTraverse)){
				//grab the contents of the first directory we need to traverse
				directoryContents = directoriesToTraverse[1].listFiles();
				//loop through the contents of this directory
				for(ii = 1; ii LTE arrayLen(directoryContents); ii = ii + 1){			
					//if it's a directory, add it to those we need to traverse
					if(directoryContents[ii].isDirectory())
						arrayAppend(directoriesToTraverse,directoryContents[ii]);	
					//if it's not a directory, add it to the array of files we want to add
					else
						arrayAppend(fileArray,directoryContents[ii]);	
				}
				//now kill the first member of the directoriesToTraverse to clear out the one we just did
				arrayDeleteAt(directoriesToTraverse,1);
			} 
			
			//
			// And now, on to the zip file
			//
			
			//let's use the maximum compression
			zipOutput.setLevel(9);
			//loop over the array of files we are going to zip, adding each to the zipOutput
			for(ii = 1; ii LTE arrayLen(fileArray); ii = ii + 1){
				//make a fileInputStream object to read the file into
				input = createObject("java","java.io.FileInputStream").init(fileArray[ii].getPath());
				//make an entry for this file
				zipEntryPath = fileArray[ii].getPath();
				//if we are making the zip relative from a certain directory, exclude that from the zipEntryPath
				if(len(relativeFrom)){
					zipEntryPath = replace(zipEntryPath,relativeFrom,"");
				} 
				zipEntry = createObject("java","java.util.zip.ZipEntry").init(zipEntryPath);
				//put the entry into the zipOutput stream
				zipOutput.putNextEntry(zipEntry);
				// Transfer bytes from the file to the ZIP file
				len = input.read(byteArray);
				while (len GT 0) {
					zipOutput.write(byteArray, 0, len);
					len = input.read(byteArray);
				}
				//close out this entry
				zipOutput.closeEntry();
				input.close();
			}
			//close the zipOutput
			zipOutput.close();
			//return nothing
			return "";
			
			</cfscript>

	</cffunction>
	
	<cffunction name="getNextTreeID" returntype="numeric" output="false" >
		<cfset variables.treeid = variables.treeid  + 1 />
		<cfreturn variables.treeid />
	</cffunction>
	
	<cffunction name="setTreeID" returntype="void" output="false">
		<cfargument name="treeid" type="numeric" required="true" />
		<cfset variables.treeid = arguments.treeid />
	</cffunction>
	
	<cffunction name="getTree" returntype="query" output="false"> 
		<cfargument name="rootPathsList" type="string" required="true" hint="list of paths to search for CFCs" />
		<cfargument name="isWindowsPlatform" type="boolean" required="true" />
		<cfargument name="refreshFolders" type="numeric" required="false" default="0" />
		<cfscript>
			var dtree = "";
			if ((not isQuery(variables.dtree)) or arguments.refreshFolders){
				variables.dtree = generateTree(arguments.rootPathsList,arguments.isWindowsPlatform);				
			} 
			return  variables.dtree;
		</cfscript>
	</cffunction>
	
	<cffunction name="generateTree" returnType="query" output="false" hint="return a query object of all the directories" >
		<cfargument name="rootPathsList" type="string" required="true" hint="list of paths to search for CFCs" />
		<cfargument name="isWindowsPlatform" type="boolean" required="true" />
		<cfscript>
			var dtree  = queryNew("id,parentid,label,fullpath");
			var searchDirList = "";
			var rootFileList = "";
			var currentDirectoryID = 0;
			
			//init the treeid
			variables.treeid = 0;
			// create the root node
			queryAddRow(dtree,  1); 
			querySetCell(dtree,  "id",  variables.treeid); 
			querySetCell(dtree,  "parentid",  -1); 
			querySetCell(dtree,  "label",  "My Computer"); 				
		</cfscript>
		
		<cfif arguments.rootPathsList EQ "/" >
			<!--- dynamically set the root paths as all the directories off the root --->
			<cfdirectory action="LIST" directory="/" name="rootFileList">	
			<cfoutput query="rootFileList">
				<cfif lcase(type) IS "dir" >
					<cfset searchDirList = listAppend(searchDirList,  "/" & name) /> 
				</cfif>
			</cfoutput>
		<cfelse>
			<!--- root paths were set explicitly --->
			<cfset searchDirList = arguments.rootPathsList />
		</cfif>
		<cfloop list="#searchDirList#" index="searchDir">
			<cfscript>
			if (directoryExists(searchDir) ){
				//add the root dir to the tree
				dtree = addDirToTree(searchDir,0,dtree);
				//get the sub directory tree for this root
				dtree = this.getDirectoryTree(searchDir,variables.treeid,dtree);				
			}				
			</cfscript>
		</cfloop>
		<cfreturn dtree />		
	</cffunction>
	
	<cffunction name="addDirToTree" rerturnType="query" output="false" >
		<cfargument name="directory" type="string" required="true" />
		<cfargument name="parentID" type="numeric" required="true"  />
		<cfargument name="dirQuery" type="query" required="true" />
		<cfscript>
			var dtree = arguments.dirQuery;
			var folderName = "";
			var currentDirectoryID = "";
			var currentParentID = arguments.parentID;
		</cfscript>
		<cfloop list="#arguments.directory#" delimiters="#variables.directorySeparator#" index="folderName">
			<cfscript>
				currentDirectoryID = this.getNextTreeID();
				queryAddRow(dtree,  1); 
				querySetCell(dtree,  "id",  currentDirectoryID); 
				querySetCell(dtree,  "parentid",  currentParentID); 
				querySetCell(dtree,  "label",  folderName ); 	
				currentParentID = currentDirectoryID;
			</cfscript>
		</cfloop>
		<cfreturn dtree />
	</cffunction>
	
	<cffunction name="getDirectoryTree" returnType="query" output="false" hint="return a query object of all the directories" >
		<cfargument name="directory" type="string" required="false" default="" />
		<cfargument name="directoryID" type="numeric" required="false" default="0" />
		<cfargument name="dirQuery" type="query" required="false" />
		<cfscript>
			var dtree = ""; 
			var subdtree = "";
			var qry_dir = "";
			var subdirid = "";
			var currentDirectory = arguments.directory;
			var currentDirectoryID = arguments.directoryID;
			var skipFolderList = "RECYCLER"; // folders names to skip when looking for cfcs
			
			if (not isDefined('arguments.dirQuery')){
				dtree = queryNew("id,parentid,label,fullpath");
			} else {
				//writeOutput("checking subdir...");
				dtree = arguments.dirQuery;
			}

			
			if (variables.treeid EQ 0){
				queryAddRow(dtree,  1); 
				querySetCell(dtree,  "id",  variables.treeid); 
				querySetCell(dtree,  "parentid",  -1); 
				querySetCell(dtree,  "label",  "My Computer"); 				
			}
			
			if (not len(currentDirectory)){
				if (true){
					currentDirectoryID = this.getNextTreeID();
					currentDirectory = left(expandPath('./'),  1) & ":";
					queryAddRow(dtree,  1); 
					querySetCell(dtree,  "id",  currentDirectoryID); 
					querySetCell(dtree,  "parentid",  0); 
					querySetCell(dtree,  "label",  currentDirectory ); 				
				} else {
				
				}
			}
		</cfscript>
		<!--- <cfoutput>checking #currentDirectory#...</cfoutput> --->
		<cfdirectory action="LIST" directory="#currentDirectory#" name="qry_dir" >
		<!--- <cfdump var="#qry_dir#"> --->
		<cfoutput query="qry_dir" maxrows="200">
			<cfif lcase(type) IS "dir" and this.containsComponents(currentDirectory & variables.directorySeparator & name) and not listFindNoCase(skipFolderList,  name) >
				<cfset subdirid = this.getNextTreeID() />
				<cfset queryAddRow(dtree,1) />
				<cfset querySetCell(dtree,"id", subdirid ) />
				<cfset querySetCell(dtree,"parentid", currentDirectoryID) />
				<cfset querySetCell(dtree,"label", name) />
				<cfset querySetCell(dtree, "fullpath", currentDirectory & variables.directorySeparator & name) /> 
				<cfset dtree = this.getDirectoryTree(currentDirectory & variables.directorySeparator & name,subdirID,dtree) /> 
			</cfif>
		</cfoutput>
		<cfreturn dtree />
	</cffunction>
	
	<cffunction name="containsComponents" returnType="boolean" output="false" hint="returns boolean if the folder contains CFCs">
		<cfargument name="directoryPath" type="string" required="true" />
		<cfscript>
			var dirList = "";
			var qryComponents = "";			
		</cfscript>
		
		<cfdirectory action="LIST" directory="#arguments.directoryPath#" name="dirList"  >	
		<cfquery dbtype="query" name="qryComponents">
			SELECT * 
			FROM dirList
			WHERE name LIKE '%.cfc'
		</cfquery>
		<cfif qryComponents.recordCount GT 0>
			<cfreturn true />
		</cfif>
		<cfoutput query="dirList">
			<cfif lcase(type) IS "dir">
				<cfif this.containsComponents(arguments.directoryPath & variables.directorySeparator & name) >
					<cfreturn true />
				</cfif>
			</cfif>			
		</cfoutput>
		 <cfreturn false />
	</cffunction>


</cfcomponent>
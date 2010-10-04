<cfset request.layout = false />
<cfparam name="rc.dtree" type="query" >

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Select Folder</title>
	<style type="text/css" media="screen">
		@import "css/dtree.css"; 		
	</style>
	<script type="text/javascript" src="lib/dtree.js"></script>
</head>

<body>
	
	<span style="font-family: Verdana; font-size: 10px;"><a href="index.cfm?do=cfcdoc.browseServer&refreshFolders=1" >Refresh Folders</a></span>
	<br/>
	<cfprocessingdirective suppressWhiteSpace = "No">
	<div class="dtree">
		
			<!--- <p><a href="javascript: d.openAll();">open all</a> | <a href="javascript: d.closeAll();">close all</a></p> --->			
			<script type="text/javascript">
			<!--		
				function selectFolder(dirPath){
					if (dirPath.length){
						opener.document.selectPathForm.cfcBasePath.value = dirPath;						
						self.close();
					}
				}
				
				d = new dTree('d');
				d.config.useStatusText = true;
				d.config.closeSameLevel = true;
				target = '';
				<cfoutput query="rc.dtree">
					<cfif label contains ":" >
					<!--- show the root drive letter with a drive icon --->
					d.add(#id#,#parentid#,'#jsstringformat(label)#','','#jsstringformat(fullpath)#','','images/drive.gif','images/drive.gif');
					<cfelse>
					d.add(#id#,#parentid#,'#jsstringformat(label)#',"javascript:selectFolder('#jsstringformat(replace(fullpath,  "\",  "\\" ,  "ALL") )#');",'#jsstringformat(fullpath)#',target,'images/folder.gif','images/folderopen.gif');
					</cfif>
				</cfoutput>
																
				document.write(d);
		
				//-->
			</script>
		
		</div>
		</cfprocessingdirective>

</body>
</html>

<cfparam name="selfwithtoken" default="">
<cfparam name="attributes.contentAlign" default="center">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title>CFC.Doc</title>
	
	<style type="text/css" media="screen">
		@import "css/default.css"; 				
	</style>

	<SCRIPT SRC="lib/qforms.js"></SCRIPT>	
	<cfprocessingdirective suppressWhiteSpace = "No">
	<SCRIPT LANGUAGE="JavaScript">
		qFormAPI.setLibraryPath("lib/");	
		qFormAPI.include("*");
		qFormAPI.errorColor = "#ccddee";	
	
		/* Auto center window script- Eric King (http://redrival.com/eak/index.shtml) */	
		var win = null;
		function NewWindow(mypage,myname,w,h,scroll){
			LeftPosition = (screen.width) ? (screen.width-w)/2 : 0;
			TopPosition = (screen.height) ? (screen.height-h)/2 : 0;
			settings =
			'height='+h+',width='+w+',top='+TopPosition+',left='+LeftPosition+',scrollbars='+scroll+',resizable'
			win = window.open(mypage,myname,settings)
		}
	
	</SCRIPT>
	</cfprocessingdirective>
	
</head>

<body leftmargin=0 topmargin=0 rightmargin="0" marginheight="0" marginwidth="0">
<div id="header">			
	&nbsp;&nbsp;<span class="headerTitle">CFC.Doc</span>
	<span id="topnav">
		<cfif application.isEvaluationKey >				
				<a href="http://philcruz.com/cfcdoc" style="color:white" title="Purchase a license!">Buy now</a>&nbsp;			
			</cfif>			
	</span>
</div>

<div id="leftsidecontent">
	
	<a href="index.cfm?do=cfcdoc.start" class="menuLink">Start</a>
	<img src="images/dotted_line.gif" width="139" height="1" border="0" alt="">
	<a href="index.cfm?do=cfcdoc.help" class="menuLink">Help</a>
	<img src="images/dotted_line.gif" width="139" height="1" border="0" alt="">	
	<a href="index.cfm?do=cfcdoc.about" class="menuLink">About</a>
	<img src="images/dotted_line.gif" width="139" height="1" border="0" alt="">	
	<br/><br/>
		
</div>

<div id="maincontent" >

	<cfoutput>#content#</cfoutput>
	
	<!--- <cfoutput>#request.urltoken#</cfoutput>
	<cfdump var="#request.session#">
	<cfif isDefined("form")>
	<cfdump var="#form#">
	</cfif>
	<cfif isDefined("url")>
	<cfdump var="#url#">
	</cfif> --->
	<!--- <cfdump var="#application.fusebox#" > --->
	
	<!--- <cfdump var="#application.paths#" >  --->
	<!--- <cfdump var="#application.querystore#" >  --->
</div>

<!--- <div id="rightsidecontent">right side</div> --->
<div id="footer">
	Copyright &copy; 2005 Phil Cruz. All rights reserved.
</div>


</body>
</html>

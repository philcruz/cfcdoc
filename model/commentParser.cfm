<cfsilent>
<!---
	Name         : UDFDoc
	Author       : Raymond Camden 
	Created      : June 28, 2001
	Last Updated : August 27, 2001
	History      : Error when /* */ comments were used in funcs. 
	Purpose		 : 
					Attempts to parse a file for UDF Declarations. Implements a pseudo-Javadoc functionality
					If r_stUDF is passed, we return the data.
					If DocDir is passed, we create HTML files in DocDir
				
					This is version 1.
					
				   	Attributes:
				   		File - File to be parsed
						r_stUDF - Structure of UDFs to return to caller scope
						DocDir - Output data in DocDir
--->

<!--- <CFIF NOT IsDefined("Attributes.File")>
	<CFTHROW MESSAGE="File attribute must be passed.">
</CFIF> --->
<CFIF IsDefined("Attributes.r_stUDF")>
	<CFPARAM NAME="Attributes.r_stUDF" TYPE="VariableName">
</CFIF>
<CFPARAM NAME="Attributes.bMakeDir" DEFAULT=False TYPE="Boolean">

<CFIF IsDefined("Attributes.DocDir")>
	<!--- fix dir --->
	<CFSET Attributes.DocDir = Replace(Attributes.DocDir,"\","/","ALL")>
	<CFIF Right(Attributes.DocDir,1) NEQ "/">
		<CFSET Attributes.DocDir = Attributes.DocDir & "/">
	</CFIF>
	<CFIF NOT DirectoryExists(Attributes.DocDir) AND NOT Attributes.bMakeDir>
		<CFTHROW MESSAGE="#Attributes.DocDir# does not exist. Pass bMakeDir to create directory.">
	<CFELSEIF NOT DirectoryExists(Attributes.DocDir)>
		<CFDIRECTORY ACTION="Create" DIRECTORY="#Attributes.DocDir#">
	</CFIF>
</CFIF>

<CFSET NL = Chr(10)>

<CFIF isDefined("attributes.file") AND NOT FileExists(Attributes.File)>
	<CFTHROW MESSAGE="#Attributes.File# does not exist.">
</CFIF>

<cfif not isDefined("attributes.file")>
	<cfset UDFFile = attributes.filecontents >
<cfelse>
	<CFFILE ACTION="Read" FILE="#Attributes.File#" VARIABLE="UDFFile">
</cfif>


<!--- Data structure --->
<CFSET Functions = ArrayNew(1)>

<!--- 
	Begin to parse the file. We parse until we stop finding function ... 
	We don't care if we are in CFSCRIPT, why? cuz this file may be included
	by another file that has the CFSCRIPT instead
--->
<CFSET Regex = "<cfcomponent[[:space:]]">
<CFSET Finder = REFindNoCase(Regex,UDFFILE,1,1)>
<CFSET Pos = Finder.Pos[1]>
<CFSET LastPos = 1>
<CFLOOP CONDITION="Pos GT 0">
	<CFSET FPos = ArrayLen(Functions)+1>
	<CFSET Functions[FPos] = StructNew()>

	<CFSET Function = StripCR(Mid(UDFFILE,Pos,Finder.Len[1]))>
	<CFSET Functions[FPos].Declaration = Function>
	<!--- Parse declaration for function name --->
	<CFSET Name = REReplaceNoCase(Function,"function[[:space:]]+","")>
	<CFSET Name = REReplaceNoCase(Name,"\(.*","")>
	<CFSET Functions[FPos].Name = Name>
	<!--- Parse declaration for args --->
	<CFSET Args = REReplaceNoCase(Function,".*\(","")>
	<CFSET Args = REReplaceNoCase(Args,"\).*","")>
	<CFSET Functions[FPos].Args = ArrayNew(1)>
	<CFIF Len(Args)>
		<CFLOOP INDEX="arg" LIST="#Args#">
			<CFSET Functions[FPos].Args[ArrayLen(Functions[FPos].Args)+1] = Trim(Arg)>
		</CFLOOP>
	</CFIF>
	
	<!--- Attempt JavaDoc style help --->
	<!--- 
		We begin by going backwards from Pos to find /**
		and */. If the match is prior to LASTPOS, we ignore
	--->
	<CFSET PotentialJDMatch = Find("/**",UDFFILE,LastPos)>
	<CFIF PotentialJDMatch AND PotentialJDMatch LT Pos>
		<!--- Grab entire JD --->
		<CFSET End = Find("*/",UDFFILE,PotentialJDMatch)>
		<CFSET JD = Mid(UDFFILE,PotentialJDMatch+3,End-PotentialJDMatch-3)>
		<!--- 
			Javadocs assume that the first N lines are comment about the function in general.
			Everything is a comment until we get to a row with just *
			But for our purposes, we will just assume it's a comment if no @arg
		--->
		<CFSET Comment = "">
		<CFLOOP INDEX="line" LIST="#JD#" DELIMITERS="*">

			<CFSET Line = Trim(Line)>
			<CFIF Left(Line,1) IS NOT "@" AND Len(Trim(Line))>
				<CFSET Comment = Comment & Line>
			<CFELSE>

				<!--- @ARG parsing --->
				<CFIF FindNoCase("@param",Line)>
					<CFSET Line = Trim(Replace(Line,"@param",""))>
					<!--- format is x(space)comment --->
					<!--- convert first SPACE meta to one space, this allows for tabs between x and comment --->
					<CFSET Line = REReplace(Line,"[[:space:]]+"," ")>
					<CFSET ThisArg = ListFirst(Line," ")>
					<CFSET ThisComment = ListRest(Line," ")>
					<!--- If we need to, create ArgComments struct --->
					<CFIF NOT StructKeyExists(Functions[FPos],"ArgComments")>
						<CFSET Functions[FPos].ArgComments = StructNew()>
					</CFIF>
					<CFSET Functions[FPos].ArgComments[ThisArg] = ThisComment>
				</CFIF>
				
				<CFIF FindNoCase("@return",Line)>
					<CFSET Line = Trim(Replace(Line,"@return",""))>
					<!--- Format is simple, we just use the text remaining --->
					<CFSET Functions[FPos].Return = Line>
				</CFIF>
				
				<CFIF FindNoCase("@author",Line)>
					<CFSET Line = Trim(Replace(Line,"@author",""))>
					<!--- Format is simple, we just use the text remaining --->	
					<CFSET Functions[FPos].Author = Line>
				</CFIF>
				
				<!--- Formal Javadoc for @version specifies a format of:
						%I%, %G%
					  which translates to version string and last updated. So, we will attempt to find I,G
					  and if so, we store I in version and G in last updated --->
				<CFIF FindNoCase("@version",Line)>
					<CFSET Line = Trim(Replace(Line,"@version",""))>
					<CFIF ListLen(Line) GT 1>
						<CFSET Functions[FPos].Version = Trim(ListFirst(Line)) >
						<CFIF IsDate(trim(ListRest(Line)))>
							<CFSET Functions[FPos].LastUpdated = Trim(ListRest(Line))>
						</CFIF>
					<CFELSE>
						<CFSET Functions[FPos].Version = Trim(Line) >
					</CFIF>
				</CFIF>
			</CFIF>
		</CFLOOP>
		<CFIF Len(Comment)>
			<CFSET Functions[ArrayLen(Functions)].Comment = Comment>
		</CFIF>
	</CFIF>
	
	<!--- Find next function --->
	<CFSET LastPos = Pos>
	<CFSET Start = Pos + Finder.Len[1]>
	<CFSET Finder = REFindNoCase(Regex,UDFFILE,Start,1)>
	<CFSET Pos = Finder.Pos[1]>
</CFLOOP>

<!--- Sort --->
<CFIF ArrayLen(Functions)>
	<CFSET Foo = StructNew()>
	<CFLOOP INDEX="X" FROM=1 TO="#ArrayLen(Functions)#">
		<CFSET Foo["#X#"] = Functions[X].Name>
	</CFLOOP>
	<CFSET Sorted = StructSort(Foo,"textnocase","asc")>
	<CFSET Functions2 = ArrayNew(1)>
	<CFLOOP INDEX="X" FROM=1 TO="#ArrayLen(Sorted)#">
		<CFSET Functions2[X] = Duplicate(Functions[Sorted[X]])>
	</CFLOOP>
	<CFSET Functions = Duplicate(Functions2)>
</CFIF>

<CFIF IsDefined("Attributes.r_stUDF")>
	<CFSET "Caller.#Attributes.r_stUDF#" = Functions>
</CFIF>
<CFIF IsDefined("Attributes.DocDir") AND ArrayLen(Functions)>
	<!--- 
		Begin to write data. Begin with the index.html
	--->
	<CFSET INDEX_STR = '<html><head><title>Generated Documentation for #Attributes.File#</title><frameset cols="20%,80%"><frame src="list.html" name="list"><frame src="" name="main"></frameset></head><body>This document requires frames.</body></html>'>
	<CFSET CREDIT_STR = '<BR><I>Generated by UDFDoc 1.0<BR>Created by:<BR><A HREF="http://www.camdenfamily.com/morpheus">Raymond Camden</A></I>'>
	<CFFILE ACTION="Write" FILE="#Attributes.DocDir#index.html" OUTPUT="#INDEX_STR#">
	<!--- generate left side which is an index listing --->
	<CFSET LEFT_STR = '<FONT FACE="Arial" SIZE=2><B>Function List</B></FONT><P><FONT FACE="Arial" SIZE=2>'>
	<CFLOOP INDEX="X" FROM=1 TO="#ArrayLen(Functions)#">
		<CFSET Name = Functions[X].Name>
		<!--- file name based on function name, which should be safe due to function name rules --->
		<CFSET LEFT_STR = LEFT_STR & '<A HREF="#Name#.html" TARGET="main">#Functions[X].Name#</A><BR>'>
		<!--- Create a file for the function as well ---->
		<CFSET MAIN_STR = '<html><head><title>Documentation for #Name#</title></head><body><P>'>
		<CFSET MAIN_STR = MAIN_STR & '<FONT FACE="Arial" SIZE=3><B>Documentation for #Name#</B></FONT><P>'>
		<!--- Add comments --->
		<CFIF StructKeyExists(Functions[X],"Comment")>
			<CFSET MAIN_STR = MAIN_STR & '<FONT FACE="Arial" SIZE=2>#Functions[X].Comment#</FONT><P>'>
		</CFIF>
		<!--- Add author, version, last updated --->
		<CFIF StructKeyExists(Functions[X],"Author")>
			<CFSET MAIN_STR = MAIN_STR & '<FONT FACE="Arial" SIZE=2><B>Author:</B> #Functions[X].Author#</FONT><BR>'>
		</CFIF>
		<CFIF StructKeyExists(Functions[X],"Version")>
			<CFSET MAIN_STR = MAIN_STR & '<FONT FACE="Arial" SIZE=2><B>Version:</B> #Functions[X].Version#</FONT><BR>'>
		</CFIF>
		<CFIF StructKeyExists(Functions[X],"LastUpdated")>
			<CFSET MAIN_STR = MAIN_STR & '<FONT FACE="Arial" SIZE=2><B>Last Updated:</B> #Functions[X].LastUpdated#</FONT>'>
		</CFIF>
		
		<CFSET MAIN_STR = MAIN_STR & '<P><HR NOSHADE SIZE=1><FONT FACE="Arial" SIZE=2><B>Arguments</B></FONT>'>
		<CFIF ArrayLen(Functions[X].Args)>
			<CFSET MAIN_STR = MAIN_STR & "<dl>">
			<CFLOOP INDEX="Y" FROM=1 TO="#ArrayLen(Functions[X].Args)#">
				<CFSET MAIN_STR = MAIN_STR & '<DT><FONT FACE="ARIAL" SIZE=2>#Functions[X].Args[Y]#</FONT></DT>'>
				<CFIF StructKeyExists(Functions[X],"ArgComments") AND StructKeyExists(Functions[X].ArgComments,Functions[X].Args[Y])>
					<CFSET MAIN_STR = MAIN_STR & '<DD><FONT FACE="ARIAL" SIZE=2>#Functions[X].ArgComments[Functions[X].Args[Y]]#</FONT></DD>'>
				</CFIF>
			</CFLOOP>
			<CFSET MAIN_STR = MAIN_STR & "</DL>">
		</CFIF>
		<CFSET MAIN_STR = MAIN_STR & "<P>">
		<CFIF StructKeyExists(Functions[X],"Return")>
			<CFSET MAIN_STR = MAIN_STR & '<HR NOSHADE SIZE=1><FONT FACE="Arial" SIZE=2><B>Return</B></FONT><BR><FONT FACE="Arial" SIZE=2>#Functions[X].Return#</FONT>'>
		</CFIF>
		<CFFILE ACTION="Write" FILE="#Attributes.DocDir##Name#.html" OUTPUT="#MAIN_STR#">
	</CFLOOP>
	<CFSET LEFT_STR = LEFT_STR & CREDIT_STR>
	<CFFILE ACTION="Write" FILE="#Attributes.DocDir#list.html" OUTPUT="#LEFT_STR#">

</CFIF>
</cfsilent>
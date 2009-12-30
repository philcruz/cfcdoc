
<!-- ======== START OF CLASS DATA ======== -->
<cfoutput>

<informaltable tabstyle="inheritsfromtable" frame="none" pgwide="1">
	<tgroup cols="1" align="left" colsep="1" rowsep="1">
		<colspec colname="c1" />
		<tbody>
		<row>
			<entry>
				<phrase  role="inheritsfromrole">Package:</phrase>	
				<cfif isDefined("stComponent.package")>
				<ulink url="#stComponent.package#.html" >#stComponent.package#</ulink> 
				</cfif>
			</entry>
		</row>
		</tbody>
	</tgroup>
</informaltable>


<!--- build up the inheritance hierarchy from bottom to top --->
<cfscript>
	temp = stComponent;
	components = arrayNew(1);
	s = structNew();
	s.package = temp.package;
	s.name = temp.name;
	arrayPrepend(components, s);
	while (structKeyExists(temp, "superComponent")) {
		temp = temp.superComponent;
		s = structNew();
		s.package = temp.package;
		s.name = temp.name;
		arrayPrepend(components, s);
	}
	// if there are no super components (that could be resolved), just get the extends 
	if ( arrayLen(components) EQ 1 and len(stComponent.attributes.extends) and lcase(stComponent.attributes.extends) NEQ "cfcomponent"){
		s = structNew();
		s.name = stComponent.attributes.extends;
		s.package = stComponent.package;
		s.disableLink = true;
		arrayPrepend(components,s);
	}
</cfscript>



<cfif (arrayLen(components) - 1)>
	<informaltable tabstyle="inheritsfromtable" frame="none" pgwide="1">
	<tgroup cols="1" align="left" colsep="1" rowsep="1">
		<colspec colname="c1" />
		<tbody>
		<row>
			<entry><phrase  role="inheritsfromrole">Inherits from:</phrase>
			<cfloop from="1" to="#arrayLen(components) - 1#" index="i">
			<cfif not structKeyExists(components[i],  "disableLink") >
				<ulink url="#util.getDetailURL(components[i].package & '.' & components[i].name, '')#">#util.getPackageDisplayPrefix(components[i].package)##components[i].name#</ulink>
			<cfelse>		
				#components[i].name#
			</cfif>
			<cfif i LT arrayLen(components)-1>&nbsp;&lt;&nbsp;</cfif>
			</cfloop> 
			</entry>
		</row>
		</tbody>
	</tgroup>
	</informaltable>
</cfif>

<cfif lcase(attributes.parseHeaderMode) EQ "javadoc">
	<cfif isArray(stComponent.attributes.headerMetaData) and arrayLen(stComponent.attributes.headerMetaData)>		
		<cfset headerMetaData = stComponent.attributes.headerMetaData[1] /> 
	</cfif>
	<cfif isDefined('headerMetaData') AND structCount(headerMetaData) >
		<informaltable tabstyle="inheritsfromtable" frame="none" pgwide="1">
		<tgroup cols="1" align="left" colsep="1" rowsep="1">
			<colspec colname="c1" />
			<tbody>
			<cfif isDefined('headerMetaData.comment')>
			<row>
				<entry><phrase  role="inheritsfromrole">Comment:</phrase>
				<cfoutput>#headerMetaData.comment#</cfoutput>
				</entry>
			</row>
			</cfif>
			<cfif isDefined('headerMetaData.author')>
			<row>
				<entry><phrase  role="inheritsfromrole">Author:</phrase>
				<cfoutput>#headerMetaData.author#</cfoutput>
				</entry>
			</row>
			</cfif>
			<cfif isDefined('headerMetaData.version')>
			<row>
				<entry><phrase  role="inheritsfromrole">Version:</phrase>
				<cfoutput>#headerMetaData.version#</cfoutput>
				</entry>
			</row>
			</cfif>
			<cfif isDefined('headerMetaData.LastUpdated')>
			<row>
				<entry><phrase  role="inheritsfromrole">Last Updated:</phrase>
				<cfoutput>#headerMetaData.LastUpdated#</cfoutput>
				</entry>
			</row>
			</cfif>
			</tbody>
		</tgroup>
		</informaltable>	
	</cfif>
</cfif>


<cfif len(trim(stComponent.attributes.hint)) or ( lcase(attributes.parseHeaderMode) EQ "custom" AND len(trim(stComponent.attributes.fileHeader))) >
	<informaltable tabstyle="hint" frame="none" pgwide="1">
	<tgroup cols="1" align="left" colsep="1" rowsep="1">
		<colspec colname="c1" />
		<tbody>		
		<cfif len(trim(stComponent.attributes.hint))>
		<row>
			<entry>#stComponent.attributes.hint#</entry>
		</row>	
		</cfif>
		<cfif lcase(attributes.parseHeaderMode) EQ "custom" AND len(trim(stComponent.attributes.fileHeader))>
		<row>
			<entry><simpara role="fileheadercomments"><![CDATA[#stComponent.attributes.fileHeader# ]]></simpara></entry>			
		</row>	
		</cfif>
		</tbody>
	</tgroup>
	</informaltable>
</cfif>

</cfoutput>

<cfoutput>
<!-- ========== PROPERTY SUMMARY =========== -->
<cfset propertyNameSet = createObject("java", "java.util.HashSet").init() />
<cfif structCount(stComponent.properties)>
	<cfset aNames = structKeyArray(stComponent.properties)>
	<cfset arraySort(aNames,'textnocase')>
	
	<informaltable tabstyle="propertysummary" pgwide="1" frame="none" >
	<tgroup cols="2" align="left" colsep="1" rowsep="1">
	<colspec colname="c1" colwidth="100px" />
	<colspec colname="c2" />
	<thead>
	<row>
		<entry namest="c1" nameend="c2">Property Summary</entry>
	</row>
	</thead>
	
	<tbody>	
	<cfloop from="1" to="#arrayLen(aNames)#" index="i">
		<cfset thisProperty = stComponent.properties[aNames[i]]>
		<cfset propertyNameSet.add(thisProperty.name) />
		<row>
			<entry <cfif not len(trim(thisProperty.hint))>namest="c1" nameend="c2"<cfelse>align="right"</cfif>>				
				<ulink url="##propertydetail_#thisProperty.name#">#thisProperty.name#</ulink>
			</entry>			
				<cfif len(trim(thisProperty.hint))>
				<entry>
					#thisProperty.hint#
				</entry>		
				</cfif>			
		</row>
	</cfloop>
	</tbody>
	</tgroup>
	</informaltable>

</cfif>

<cfset thisComponent = stComponent />
<cfloop condition="structKeyExists(thisComponent, 'superComponent')">
	<cfset thisComponent = thisComponent.superComponent />
	<cfset propertyNames = structKeyArray(thisComponent.properties) />
	<cfset inheritedPropertyNames = arrayNew(1) />
	<cfloop from="1" to="#arrayLen(propertyNames)#" index="i">
		<cfif propertyNameSet.add(propertyNames[i])>
			<cfset arrayAppend(inheritedPropertyNames, propertyNames[i]) />
		</cfif>
	</cfloop>

	<cfif arrayLen(inheritedPropertyNames) GT 0>
		<!--- check if there were properties, if not then we use alternate style --->
		<cfif structCount(stComponent.properties)>
			<cfset inheritedpropertysummarystyle = "inheritedpropertysummary" />
		<cfelse>
			<cfset inheritedpropertysummarystyle = "inheritedpropertysummary2" />
		</cfif>
		<informaltable tabstyle="#inheritedpropertysummarystyle#" pgwide="1">
			<tgroup cols="1" align="left" colsep="1" rowsep="1">
			<colspec colname="c1" />			
			<thead>					
				<row>
					<entry align="left">				
						Properties inherited from <ulink url="#util.getDetailURL(thisComponent.package & '.' & thisComponent.name, '')#">#util.getPackageDisplayPrefix(thisComponent.package)##thisComponent.name#</ulink>:&nbsp;&nbsp;
						<cfset count = arrayLen(inheritedPropertyNames) />
				<cfloop from="1" to="#count#" index="i">
					<ulink url="#util.getDetailURL(thisComponent.package & '.' & thisComponent.name, '')###propertydetail_#inheritedPropertyNames[i]#">#inheritedPropertyNames[i]#</ulink><cfif i LT count>,</cfif>
				</cfloop>
					</entry>
				</row>
			</thead>
			<tbody>
			</tbody>
			</tgroup>
		</informaltable>		
		
	</cfif>
</cfloop>
</cfoutput>

<!-- ========== METHOD SUMMARY =========== -->

<cfoutput>
<cfset methodNameSet = createObject("java", "java.util.HashSet").init() />
<cfset aNames = structKeyArray(stComponent.methods)>

<cfif arrayLen(aNames) GT 0>
<informaltable tabstyle="methodsummary" pgwide="1" frame="none">
	<tgroup cols="2" align="left" colsep="1" rowsep="1">
	<colspec colname="c1" colwidth="100px" />
	<colspec colname="c2" />
	<thead>
	<row>
		<entry namest="c1" nameend="c2">Method Summary</entry>
	</row>
	</thead>
	<tbody>


<cfset arraySort(aNames,'textnocase')>
<cfset constructorContent = "" />
<cfset methodContent = "" />

<cfloop from="1" to="#arrayLen(aNames)#" index="i">
<cfset thisMethod = stComponent.methods[aNames[i]]>
<cfset methodNameSet.add(thisMethod.name) />
<cfif listFindNoCase(application.constructorNames, thisMethod.name) GT 0>
	<cfsavecontent variable="constructorContent">#constructorContent#
	<row>
		<entry align="right">
			#thisMethod.access# 
			<ulink url="#util.getDetailURL(thisMethod.returntype,stComponent.path)#" >#listLast(thisMethod.returnType, ".")#</ulink>
		</entry>
		<entry>
			<ulink url="###thismethod.name#">#thismethod.name#</ulink>(#generateArgumentList(thisMethod)#)				
			<cfif len(trim(thisMethod.hint))>
			<para>
				#thisMethod.hint#
			</para>
		</cfif>		
		</entry>
	</row>
	</cfsavecontent>
<cfelse>
	<cfsavecontent variable="methodContent">#methodContent#
	<row>
	<entry align="right">		
		#thisMethod.access# 
		<ulink url="#util.getDetailURL(thisMethod.returntype,stComponent.path)#" >#listLast(thisMethod.returnType, ".")#</ulink>
	</entry>
	<entry>
		<ulink url="###thismethod.name#">#thismethod.name#</ulink>(#generateArgumentList(thisMethod)#)				
		<cfif len(trim(thisMethod.hint))>
			<para>
				#thisMethod.hint#
			</para>
		</cfif>		
	</entry>
	</row>
	</cfsavecontent> 
</cfif>
</cfloop>
#constructorContent#
#methodContent#
</tbody>
</tgroup>
</informaltable>
</cfif>


<cfset thisComponent = stComponent />
<cfloop condition="structKeyExists(thisComponent, 'superComponent')">
	<cfset thisComponent = thisComponent.superComponent />
	<cfset methodNames = structKeyArray(thisComponent.methods) />
	<cfset inheritedMethodNames = arrayNew(1) />
	<cfloop from="1" to="#arrayLen(methodNames)#" index="i">
		<cfif methodNameSet.add(methodNames[i])>
			<cfset arrayAppend(inheritedMethodNames, methodNames[i]) />
		</cfif>
	</cfloop>

	<cfif arrayLen(inheritedMethodNames) GT 0>
		<informaltable tabstyle="inheritedmethodsummary" pgwide="1">
			<tgroup cols="1" align="left" colsep="1" rowsep="1">
			<colspec colname="c1" />			
			<thead>					
				<row>
					<entry align="left">				
						Methods inherited from <ulink url="#util.getDetailURL(thisComponent.package & '.' & thisComponent.name, '')#">#util.getPackageDisplayPrefix(thisComponent.package)##thisComponent.name#</ulink>:&nbsp;&nbsp;
						<cfset count = arrayLen(inheritedMethodNames) />
				<cfloop from="1" to="#count#" index="i">
					<ulink url="#util.getDetailURL(thisComponent.package & '.' & thisComponent.name, '')####inheritedMethodNames[i]#">#inheritedMethodNames[i]#</ulink> 				
					<cfif i LT count>,</cfif>
				</cfloop>
					</entry>
				</row>
			</thead>
			<tbody>
			</tbody>
			</tgroup>
		</informaltable>
	</cfif>
</cfloop>


</cfoutput>


<cfif structCount(stComponent.properties) >
<!-- ============ PROPERTY DETAIL ========== -->

<cfset aNames = structKeyArray(stComponent.properties)>

<cfif arrayLen(aNames)>
<!--- if there are properties then put in a head for property  detail --->
<informaltable pgwide="1" tabstyle="propertydetail">
<tgroup cols="1" align="left" colsep="1" rowsep="1">
	<colspec colname="c1" />
	<thead>
	<row>
		<entry>Property Detail</entry>
	</row>
	</thead>
	<tbody></tbody>
</tgroup>
</informaltable> 
</cfif>

<cfset arraySort(aNames,'textnocase')>

<cfoutput>
<cfloop from="1" to="#arrayLen(aNames)#" index="i">
<cfset thisProperty = stComponent.properties[aNames[i]]>

<anchor id="propertydetail_#thisProperty.name#"></anchor>
<informaltable pgwide="1" tabstyle="propertytitle">
	<tgroup cols="1" align="left" colsep="1" rowsep="1">
		<colspec colname="c1" />
		<thead>
		<row>
			<entry>#thisProperty.name#</entry>
		</row>
		</thead>
		<tbody></tbody>
	</tgroup>
	</informaltable>
	
	<cfset attribArray = structKeyArray(thisProperty)>
    <cfset arraySort(attribArray,'textnocase')>   
      <simplelist>
        <cfloop from="1" to="#arrayLen(attribArray)#" index="i">
			<cfif attribArray[i] NEQ "FULLTAG">
				<member>#attribArray[i]#:&nbsp;#thisProperty[attribArray[i]]#</member>
			</cfif>
		</cfloop>		
      </simplelist>

<!--- <H3>#thisProperty.name#</H3>
<DL>
  <DD>#thisProperty.hint#</DD>
  <BR />
  <DD>
    <B>Attributes:</B>
    <cfset attribArray = structKeyArray(thisProperty)>
    <cfset arraySort(attribArray,'textnocase')>
    <!--- <PRE> --->
      <table border="1" cellspacing="0" cellpadding="3" bordercolor="Black">
        <cfloop from="1" to="#arrayLen(attribArray)#" index="i"><tr><td bgcolor="##EEEEFF">#attribArray[i]#:</td><td>&nbsp;#thisProperty[attribArray[i]]#</td></tr></cfloop>
      </table>
    <!--- </PRE> --->
    <cfif revealCode>
      <DL>
        <DT><B>Code:</B></DT>
        <DD>
        <cf_coloredcode data="#thisProperty.fullTag#">
        </DD>
      </DL>
    </cfif>
  </DD>
</DL>
<HR /> --->
</cfloop>
</cfoutput>

</cfif>
<!--- ============ METHOD DETAIL ========== --->


<!--- <A NAME="method_detail"><!-- --></A> --->

<cfif arrayLen(aNames) AND arrayLen(structKeyArray(stComponent.methods))>
<!--- if there are properties and methods then put in a head for method detail --->
<informaltable pgwide="1" tabstyle="methoddetail">
<tgroup cols="1" align="left" colsep="1" rowsep="1">
	<colspec colname="c1" />
	<thead>
	<row>
		<entry>Method Detail</entry>
	</row>
	</thead>
	<tbody></tbody>
</tgroup>
</informaltable> 
</cfif>

<cfset aNames = structKeyArray(stComponent.methods)>

<cfset arraySort(aNames,'textnocase')>

<cfoutput>


<cfloop from="1" to="#arrayLen(aNames)#" index="i">
<cfset thisMethod = stComponent.methods[aNames[i]] />
<cfset argumentList = generateArgumentList(thisMethod) />
	
	<anchor id="#thisMethod.name#"></anchor>
	
	<informaltable pgwide="1" tabstyle="methodtitle">
	<tgroup cols="1" align="left" colsep="1" rowsep="1">
		<colspec colname="c1" />
		<thead>
		<row>
			<entry>#thisMethod.name#</entry>
		</row>
		</thead>
		<tbody></tbody>
	</tgroup>
	</informaltable>

		<para role="methodsignature">
			#thisMethod.access# 
			<ulink url="#util.getDetailURL(thisMethod.returntype,stComponent.path)#" >#listLast(thisMethod.returnType, ".")#</ulink> <phrase role="methodname">#thisMethod.name#</phrase>( #trim(argumentList)# )
		</para>	
		<para role="methodhint">
			#thisMethod.hint#						
		</para>
		<para role="parameters">
			<phrase role="parameterlabel">Parameters:</phrase> 
			<cfif listlen(argumentList)>
				<simplelist role="simplelistofarguments">
				<cfloop from="1" to="#listlen(argumentList)#" index="argindex">
				<member>#listGetAt(argumentlist,  argindex)#</member>
				</cfloop>
				</simplelist>
			</cfif>
		</para>
		<para role="code">
			<phrase role="codelabel">Code:</phrase>
			<programlisting><![CDATA[#thisMethod.fullTag# ]]></programlisting>
		</para>

</cfloop>

</cfoutput>




<cfscript>
	tablestyle = "border: solid ##aaaaaa 1px;";
	transformerClassNames = application.cfcdoc.gettransformerClassNames();
	tfactory =  listFirst(transformerClassNames);
	tformer = listLast(transformerClassNames);
	sysProps = createObject("java", "java.lang.System");
</cfscript>

<table  width="300" cellpadding="0" cellspacing="0" style="<cfoutput>#tablestyle#</cfoutput>">
	<tr>
		<td>
			<table  width="300" cellpadding="5" cellspacing="2" >
				<tr style="background-color: ccddee;">
					<td colspan="2"><strong>About CFCDoc</strong></td>
				</tr>
				<tr>
					<td><strong>Product Name:</strong></td>
					<td><cfoutput>CFCDoc</cfoutput></td>
				</tr>
				<tr>
					<td><strong>Version:</strong></td>
					<td>1.0</td>
				</tr>
				<tr>
					<td><strong>Build Number:</strong></td>
					<td>@@buildnumber@@</td>
				</tr>
				<tr>
					<td nowrap="nowrap"><strong>Transformer Factory:</strong></td>
					<td><cfoutput>#tfactory#</cfoutput></td>
				</tr>				
				<tr>
					<td><strong>Transformer:</strong></td>
					<td><cfoutput>#tformer#</cfoutput></td>
				</tr>		
				<tr>
					<td><strong>FOP script:</strong></td>
					<td><cfoutput>#application.fopExecutablePath#</cfoutput></td>
				</tr>
				<tr>
					<td><strong>CFML Server:</strong></td>
					<td><cfoutput>#server.coldfusion.productname#</cfoutput></td>
				</tr>
				<tr>
					<td><strong>CFML Server Version:</strong></td>
					<td><cfoutput>#server.coldfusion.productversion#</cfoutput></td>
				</tr>
				<tr>
					<td><strong>CFML Server Edition:</strong></td>
					<td><cfoutput>#server.coldfusion.productLevel#</cfoutput></td>
				</tr>
				<tr>
					<td><strong>Operating system:</strong></td>
					<td><cfoutput>#sysProps.getProperty("os.name")# (#sysProps.getProperty("os.version")#)</cfoutput></td>
				</tr>
				<tr>
					<td><strong>Java version:</strong></td>
					<td><cfoutput>#sysProps.getProperty("java.version")#</cfoutput></td>
				</tr>
				<tr>
					<td valign="top"><strong>Java classpath:</strong></td>
					<td><textarea rows="5" cols="50"><cfoutput>#sysProps.getProperty("java.class.path")#</cfoutput></textarea></td>
				</tr>

			</table>

		
		</td>
	</tr>
</table>

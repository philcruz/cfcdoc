


<h3>Help</h3>

<p>
	CFC.Doc is very simple to use.  Simply give it an absolute path to a directory containing your CFCs.
	For example, on Windows, it might be c:\cfusionmx\wwwroot\mycomponents.  The folder doesn't 
	have to be in the webroot.  Provide a title and a footer and press Next. 
</p>

<p>
	The application will recursively search the given directory for all CFCs and generate the appropriate
	documentation.  Depending on the number of CFCs to be processed this can take few seconds or a few minutes.  
	You can preview the results and then download the generate documentation as a zip file. 
</p>

<p>
	<strong>Browse:</strong>The Browse link displays a tree control that allows you to choose the folder
	containing your CFCs.  By default, the root directory of the tree control will be the root folder
	that contains the application.  To add other directories, edit the &lt;rootPathsList&gt; entry in the config.xml file.
	Only directories that contain CFCs will be shown in the tree control.
</p>

<P>
	<strong>To use in Eclipse IDE:</strong> Expand the zip file inside the Eclipse plugins directory.  If 
	you change the directory name you must change ID value in the plugin.xml file to match the directory name.
</P>

<P>
	<strong>To use in CFStudio/Homesite IDE:</strong> Expand the zip file inside the Help directory. The
	name of the directory will be the name displayed in the Help References Window.  Feel free to rename the directory.
</P>


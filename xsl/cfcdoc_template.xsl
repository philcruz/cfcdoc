<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">
	<xsl:import href="../docbook/htmlhelp/htmlhelp.xsl"/>  
	<xsl:param name="base.dir" select="'@htmlOutputDirectory@/'"/>
	<xsl:param name="generate.legalnotice.link" select="0"/>
	<xsl:param name="chunk.first.sections" select="1"/>
	<xsl:param name="suppress.navigation" select="1"/>
	<xsl:param name="chapter.autolabel" select="0"/>
	<xsl:param name="css.decoration" select="1" />
	<xsl:param name="htmlhelp.hhp" select="'cfcdoc.hhp'" />
	<xsl:param name="htmlhelp.autolabel" select="0"/>
	<xsl:param name="html.stylesheet" select="'cfcdoc.css'"/>
	<xsl:param name="htmlhelp.chm" select="'CFCDoc.chm'"/>
	<xsl:param name="htmlhelp.hhc.binary" select="0"/>
	<xsl:param name="htmlhelp.hhc.folders.instead.books" select="1"/>
	<xsl:param name="htmlhelp.hhc.show.root" select="0" />
	<xsl:param name="htmlhelp.hhc" select="'cfcdoc_toc.hhc'" />
	<xsl:param name="para.propagates.style" select="1" />
	<xsl:param name="phrase.propagates.style" select="1" />
	<xsl:param name="ulink.target" select="'_self'" />
	<xsl:param name="use.id.as.filename" select="0" />
	<xsl:param name="generate.toc">
	appendix  toc,title
	article/appendix  nop
	article   toc,title
	book      toc,title,figure,table,example,equation
	chapter   toc
	part      toc,title
	preface   toc,title
	qandadiv  toc
	qandaset  toc
	reference nop
	sect1     toc
	sect2     toc
	sect3     toc
	sect4     toc
	sect5     toc
	section   toc
	set       toc,title
	</xsl:param>
	<xsl:param name="toc.section.depth" select="1"/>
	<xsl:param name="generate.section.toc.level" select="1"/>
	
	
	
	<xsl:template name="user.footer.navigation">
		<div id="footer">@footer@</div> 
	</xsl:template>
  		
	<xsl:template name="href.target.with.base.dir">
		<xsl:param name="object" select="."/>
		<xsl:if test="$manifest.in.base.dir = 0">
		<xsl:value-of select="$base.dir"/>
		</xsl:if>
		<xsl:call-template name="href.target.uri">
		<xsl:with-param name="object" select="$object"/>
		</xsl:call-template>
	</xsl:template>
	
</xsl:stylesheet>
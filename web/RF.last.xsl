<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ex="http://exslt.org/dates-and-times"
	xmlns="http://www.w3.org/1999/xhtml">
	<xsl:output method="text"
doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" />

	<xsl:variable name="now" select="ex:seconds()" />

	<xsl:template match="/">
		<xsl:apply-templates select='/fortunes/fortune'>
			<xsl:sort data-type='number' order='descending' select='@lastPost'/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match='fortune'>
		<xsl:if test='position() = 1'>
			<xsl:value-of select="." disable-output-escaping='yes'/>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>

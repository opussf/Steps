<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ex="http://exslt.org/dates-and-times"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:math="http://exslt.org/math"
	extension-element-prefixes="math">
	<xsl:output method="text"
doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" />

	<xsl:variable name="now" select="ex:seconds()" />
	<xsl:variable name='numFortunes' select='count(/fortunes/fortune)'/>
	<xsl:variable name='chooseThis' select='(floor(math:random()*$numFortunes) mod $numFortunes) + 1'/>

	<xsl:template match="/">
		<xsl:apply-templates select='/fortunes/fortune'>
			<xsl:sort data-type='number' order='descending' select='@lastPost'/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match='fortune'>
		<xsl:if test='position() = $chooseThis'>
			<xsl:value-of select="." disable-output-escaping='yes'/>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>

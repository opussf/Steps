<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ex="http://exslt.org/dates-and-times"
	xmlns="http://www.w3.org/1999/xhtml">
	<xsl:output method="html"
doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" />

	<xsl:variable name="now" select="ex:seconds()" />

	<xsl:template match="/">
		<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
		<head>
		<title>Random Fortune</title>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<link href='RF.css' rel='stylesheet' type='text/css'/>
		<link href='rss' rel='alternate' type='application/rss+xml' title='Char RSS Feed'/>
		</head>
		<body>
		<div class="top">
		<div class="main">
		<xsl:apply-templates select='/fortunes/fortune'>
			<xsl:sort data-type='number' order='descending' select='@lastPost'/>
		</xsl:apply-templates>
		</div>
		</div>
		</body>
		</html>
	</xsl:template>

	<xsl:template match='fortune'>
		<xsl:if test='position() &lt;= 30'>
			<div class='RandomFortuneWrapper'>
			<div class='RandomFortuneDate'>
				<xsl:call-template name='convertSecsToTimeStamp'>
					<xsl:with-param name='seconds'>
						<xsl:value-of select='@lastPost'/>
					</xsl:with-param>
				</xsl:call-template>
			</div>
			<div class='RandomFortune'>
			<xsl:value-of select="." disable-output-escaping='yes'/>
			</div>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- support code -->
	<xsl:template name='convertSecsToTimeStamp'>
		<xsl:param name='seconds'/>
		<xsl:variable name='year' select="floor($seconds div (31557600)) + 1970"/>
		<xsl:variable name='noYear' select="$seconds mod 31557600"/>
		<xsl:value-of select='$year'/>:   
		<xsl:value-of select='$seconds'/>
	</xsl:template>
</xsl:stylesheet>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ex="http://exslt.org/dates-and-times"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xsl:output method="xml" indent="yes"/>

	<xsl:variable name="now" select="ex:seconds()" />

	<xsl:template match="/">
		<xsl:text disable-output-escaping="yes">&lt;?xml-stylesheet title='XSL_formatting' type='text/xsl' href='/include/xsl/rss.xsl'?&gt;
		</xsl:text>
		<rss version="2.0">
		<channel>
			<title>Steps</title>
			<link>http://www.zz9-za.com/~opus/steps/</link>
			<description>Steps</description>
			<generator>xslt</generator>
			<ttl>30</ttl>
		<xsl:apply-templates select='/steps/char'>
			<xsl:sort data-type='number' order='descending' select='@steps'/>
		</xsl:apply-templates>
		</channel>
		</rss>
	</xsl:template>

	<xsl:template match="char">
		<item>
		<title><xsl:value-of select="position()"/>. <xsl:value-of select="@name"/> of <xsl:value-of select="@realm"/> has <xsl:value-of select="@steps"/> steps..</title>
		<link>http://www.zz9-za.com/~opus/steps</link>
		<guid isPermaLink='false'><xsl:value-of select='@name'/>-<xsl:value-of select="@realm"/>-<xsl:value-of select='@steps'/></guid>
		<description><xsl:value-of select="@name"/>-<xsl:value-of select="@realm"/> has <xsl:value-of select="@steps"/> steps.</description>
		<xsl:apply-templates select='./day'>
			<xsl:sort data-type='text' order='descending' select='@date'/>
		</xsl:apply-templates>
		</item>
	</xsl:template>

	<xsl:template match="day">
		<xsl:if test='position() &lt;= 1'>
			<xsl:variable name='xslDate' select='ex:date(@date)'/>
			<xsl:variable name='pubDate'>
				<xsl:value-of select="concat(ex:day-abbreviation($xslDate), ', ',
					format-number(ex:day-in-month($xslDate), '00'), ' ',
					ex:month-abbreviation($xslDate), ' ', ex:year($xslDate), ' GMT')"/>
			</xsl:variable>
			<pubDate><xsl:value-of select='$pubDate'/></pubDate>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>

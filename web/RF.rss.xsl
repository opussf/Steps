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
			<title>Random Fortunes</title>
			<link>http://www.zz9-za.com/~opus/RF/</link>
			<description>Random Fortunes</description>
			<generator>xslt</generator>
			<ttl>30</ttl>
		<xsl:apply-templates select='/fortunes/fortune'>
			<xsl:sort data-type='number' order='descending' select='@lastPost'/>
		</xsl:apply-templates>
		</channel>
		</rss>
	</xsl:template>

	<xsl:template match="fortune">
		<xsl:if test='position() &lt;= 30'>
		    <xsl:variable name='xslDate' select='ex:add("1970-01-01T00:00:00", ex:duration(@lastPost))'/>
			<xsl:variable name='pubDate'>
				<xsl:value-of select="concat(ex:day-abbreviation($xslDate), ', ', 
					format-number(ex:day-in-month($xslDate), '00'), ' ',
					ex:month-abbreviation($xslDate), ' ', ex:year($xslDate), ' ',
					format-number(ex:hour-in-day($xslDate), '00'), ':',
					format-number(ex:minute-in-hour($xslDate), '00'), ':',
					format-number(ex:second-in-minute($xslDate), '00'), ' GMT')"/>
			</xsl:variable>

			<item>
			<title><xsl:value-of select='.' disable-output-escaping='yes'/></title>
			<link>http://www.zz9-za.com/~opus/RF</link>
			<guid isPermaLink='false'><xsl:value-of select='@lastPost'/></guid>
			<pubDate><xsl:value-of select='$pubDate'/></pubDate>
			<description>
				<xsl:value-of select='.' disable-output-escaping='yes'/>
			</description>
			</item>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>

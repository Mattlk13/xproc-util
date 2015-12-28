<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tr="http://transpect.io"
  exclude-result-prefixes="#all" 
  version="2.0">
  
  <xsl:import href="http://transpect.io/xslt-util/mime-type/xsl/mime-type.xsl"/>

  <xsl:param name="base-uri"/>

  <xsl:template match="text()">
    <xsl:analyze-string select="." regex="url\((.+?)\)">
      <xsl:matching-substring>
        <xsl:variable name="href" select="resolve-uri(replace(regex-group(1), '''|&quot;', ''), $base-uri)" as="xs:anyURI"/>
        <xsl:text>url('</xsl:text>
        <tr:data-uri href="{$href}" mime-type="{tr:fileext-to-mime-type($href)}">tobereplaced</tr:data-uri>
        <xsl:text>')</xsl:text>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>

  </xsl:template>

  <xsl:template match="@*|*">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>


</xsl:stylesheet>
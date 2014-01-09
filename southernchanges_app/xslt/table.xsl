<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  version="1.0">

<!-- simple table test by Alice Hickcox, March 8, 2006 -->
<!-- parameters added by Rebecca Sutton Koeser, November 19, 2003 -->
<!-- these variables set in teihtml-param.xsl (not included here) -->
<!--    <xsl:param name="tableAlign">left</xsl:param> -->
   <xsl:param name="tableAlign">center</xsl:param>
   <xsl:param name="cellAlign">left</xsl:param>

<xsl:template match="table">
<table>
<xsl:for-each select="@*">
<xsl:copy-of select="."/>
</xsl:for-each>
<xsl:apply-templates/></table>
</xsl:template>

<xsl:template match="row">
<tr><xsl:apply-templates/>
</tr>
</xsl:template>

<xsl:template match="cell">
<td valign="top">
<xsl:apply-templates/>
</td>
</xsl:template>

</xsl:stylesheet>
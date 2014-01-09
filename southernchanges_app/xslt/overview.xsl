<?xml version="1.0" encoding="ISO-8859-1"?>  

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:html="http://www.w3.org/TR/REC-html40" 
	xmlns:ino="http://namespaces.softwareag.com/tamino/response2" 
	xmlns:xql="http://metalab.unc.edu/xql/">

<xsl:template match="/">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="head">
<h2><xsl:apply-templates/></h2>
</xsl:template>

<xsl:template match="epigraph">
<p class="epigraph"><xsl:apply-templates/></p>
</xsl:template>

<xsl:template match="div/@class">
  <xsl:element name="div">
    <xsl:attribute name="class">credit</xsl:attribute>
  </xsl:element>
</xsl:template>

<xsl:template match="p">
  <xsl:element name="p">
    <xsl:apply-templates /> 
  </xsl:element>
</xsl:template>



<xsl:template match="bibl">
<span id="bibl"><xsl:apply-templates/></span>
</xsl:template>

<xsl:template match="title">
<i><xsl:apply-templates/></i>
</xsl:template>

<xsl:template match="lb">
<br/><xsl:apply-templates/>
</xsl:template>

<xsl:template match="//*[@rend]">
<xsl:choose>
  <xsl:when test="@rend='italic'">
    <xsl:element name="i">
	<xsl:apply-templates/>
    </xsl:element>
  </xsl:when>
  <xsl:when test="@rend='bold'">
    <xsl:element name="b">
	<xsl:apply-templates/>
    </xsl:element>
  </xsl:when>
 </xsl:choose>
</xsl:template>
</xsl:stylesheet>
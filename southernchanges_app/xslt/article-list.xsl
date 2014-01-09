<?xml version="1.0" encoding="ISO-8859-1"?> 

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:html="http://www.w3.org/TR/REC-html40" version="1.0"
	xmlns:xq="http://metalab.unc.edu/xq/"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:exist="http://exist.sourceforge.net/NS/exist" exclude-result-prefixes="exist">


<xsl:param name="mode">article</xsl:param>
<!-- param for flat mode: all volumes or single volume -->
<xsl:param name="vol">all</xsl:param>
<xsl:variable name="mode_name">Browse</xsl:variable> 

<xsl:output method="html"/>
<xsl:template match="/">

<!-- begin content -->
<xsl:element name="div">
<xsl:attribute name="class">contents</xsl:attribute>
<xsl:element name="h3">
   Issue: <xsl:value-of select="//issue-id/tei:head"/>
  </xsl:element>
  <xsl:apply-templates select="//result"/>
</xsl:element>
<xsl:element name="p"/> <!-- spacer -->
<xsl:call-template name="next-prev"/>
</xsl:template>


<xsl:template match="result">
  <xsl:element name="table">
    <xsl:attribute name="class">contents</xsl:attribute>
    <xsl:element name="tr">
      <xsl:element name="th">Author</xsl:element>
      <xsl:element name="th">Title</xsl:element>
      <xsl:element name="th">Type</xsl:element>
      <xsl:element name="th">Pages</xsl:element>
    </xsl:element>
    <xsl:for-each select="article">
  <xsl:element name="tr">
    <xsl:element name="td"><xsl:attribute name="width">15%</xsl:attribute><xsl:attribute name="valign">top</xsl:attribute><xsl:apply-templates
    select="tei:name/tei:choice/tei:sic"/></xsl:element> 
    <xsl:element name="td"><xsl:attribute name="valign">top</xsl:attribute><xsl:element name="a">
      <xsl:attribute name="href">article.php?id=<xsl:value-of
      select="@xml:id"/></xsl:attribute><xsl:value-of
      select="tei:head"/></xsl:element></xsl:element>
      <xsl:element name="td"><xsl:attribute name="width">10%</xsl:attribute><xsl:attribute name="valign">top</xsl:attribute><xsl:value-of
      select="@type"/></xsl:element>
      <xsl:element name="td"><xsl:attribute name="width">25%</xsl:attribute><xsl:attribute name="valign">top</xsl:attribute><xsl:value-of select="tei:docDate"/></xsl:element>
    </xsl:element> <!-- tr -->
    </xsl:for-each>
  </xsl:element><!-- table -->

</xsl:template>

<!-- handle multiple authors -->

<xsl:template match="tei:name//tei:sic">
    <xsl:choose>
      <xsl:when test="position() = 1"/>
 <xsl:when test="position() = last()">
        <xsl:text> and </xsl:text>
      </xsl:when>
    <xsl:otherwise>
	<xsl:text>, </xsl:text>
      </xsl:otherwise>
  </xsl:choose>
  

    <xsl:apply-templates />
 

</xsl:template>



<!-- generate next & previous links (if present) -->
<!-- note: all div2s, with id, head, and bibl are retrieved in a
     <siblings> node -->
 <!-- Use head not n attribute (normalized caps) for article title; if
      n is blank, label as untitled -->
<xsl:template name="cleantitle">
  <xsl:choose>
    <xsl:when test="tei:head = ''">
      <xsl:text>[Untitled]</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="normalize-space(./tei:head)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="next-prev">
<xsl:element name="table">
  <xsl:attribute name="width">75%</xsl:attribute>

<!-- display issues relative to position of current article -->
<xsl:element name="tr">
<xsl:if test="//prev/@xml:id">
<xsl:element name="th">
    <xsl:text>Previous issue: </xsl:text>
</xsl:element>
<xsl:element name="td">
 <xsl:element name="a">
   <xsl:attribute name="href">articlelist.php?id=<xsl:value-of
		select="//prev/@xml:id"/></xsl:attribute>
   <xsl:apply-templates select="//prev/tei:head"/>
 </xsl:element><!-- end td -->
</xsl:element></xsl:if>
</xsl:element><!-- end  prev row --> 

<xsl:element name="tr">
<xsl:if test="//next/@xml:id">
<xsl:element name="th">
    <xsl:text>Next issue: </xsl:text>
</xsl:element>
<xsl:element name="td">
 <xsl:element name="a">
   <xsl:attribute name="href">articlelist.php?id=<xsl:value-of
		select="//next/@xml:id"/></xsl:attribute>
   <xsl:apply-templates select="//next/tei:head"/>
 </xsl:element><!-- end td -->
</xsl:element><!-- end td -->
</xsl:if>
</xsl:element><!-- end  next row --> 


</xsl:element> <!-- table -->
</xsl:template>
<!-- print next/previous link with title & summary information -->
<xsl:template match="sibling/issueidlist">
<xsl:param name="mode"/>

<xsl:variable name="linkrel">
    <xsl:choose>
        <xsl:when test="$mode='Previous'">
            <xsl:text>prev</xsl:text>
        </xsl:when>
        <xsl:when test="$mode='Next'">
            <xsl:text>next</xsl:text>
        </xsl:when>
    </xsl:choose>
</xsl:variable>


<xsl:element name="tr">
 <xsl:element name="th">
  <xsl:attribute name="valign">top</xsl:attribute>
   <xsl:attribute name="align">left</xsl:attribute>
   <xsl:value-of select="concat($mode, ': ')"/>
 </xsl:element> <!-- th -->

 <xsl:element name="td">
  <xsl:attribute name="valign">top</xsl:attribute>
  <xsl:element name="a">
   <xsl:attribute name="href">articlelist.php?id=<xsl:value-of select="dcidentifier"/></xsl:attribute>
    <!-- use rel attribute to give next / previous information -->
    <xsl:attribute name="rel"><xsl:value-of select="$linkrel"/></xsl:attribute>
      <xsl:value-of select="dcdescription"/><!-- <xsl:call-template name="cleantitle"/> -->
  </xsl:element> <!-- a -->   
  </xsl:element> <!-- td -->

  </xsl:element> <!-- font -->

</xsl:template>


</xsl:stylesheet>

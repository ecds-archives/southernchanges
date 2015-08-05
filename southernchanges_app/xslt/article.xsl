<?xml version="1.0" encoding="utf-8"?>  
<xsl:stylesheet version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:tei="http://www.tei-c.org/ns/1.0" 
                xmlns:html="http://www.w3.org/TR/REC-html40"
                xmlns:exist="http://exist.sourceforge.net/NS/exist">


<xsl:output method="html"/> 

<xsl:template match="/">
    <div>
      <xsl:apply-templates select="//tei:div2" />
    </div>
</xsl:template>

<xsl:template match="tei:div2">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="tei:pb">
  <hr class="pb"/>
    <p class="pagebreak">
      Page <xsl:value-of select="@n"/>
</p>
</xsl:template>

<xsl:template match="tei:div2/tei:head">
  <xsl:element name="h1">
   <xsl:apply-templates />
  </xsl:element>
</xsl:template>

<xsl:template match="tei:byline">
  <xsl:element name="i">
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>
<xsl:template match="tei:docAuthor">
  <xsl:apply-templates/>
</xsl:template>
<xsl:template match="tei:name">
 <xsl:apply-templates select="tei:choice/tei:sic"/>
</xsl:template>

<xsl:template match="tei:docDate">
<xsl:element name="p">
  <xsl:apply-templates/>
</xsl:element>
</xsl:template>

<xsl:template match="tei:bibl">
<xsl:element name="p">
  <xsl:apply-templates/>
</xsl:element>
</xsl:template>

<xsl:template match="tei:div3">
  <xsl:if test="@type='About'">
    <xsl:element name="i">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:if>
  <xsl:if test="@type='Section'">
    <xsl:apply-templates />
  </xsl:if>
  <xsl:if test="@type='Sidebar'">
  <xsl:element name="span">
      <xsl:attribute name="class">sidebar</xsl:attribute>
  <xsl:apply-templates />
  </xsl:element>
  </xsl:if>
  <xsl:if test="@type='sidebar'">
  <xsl:element name="span">
      <xsl:attribute name="class">sidebar</xsl:attribute>
  <xsl:apply-templates />
  </xsl:element>
  </xsl:if>

</xsl:template>


<xsl:template match="tei:div3/tei:head">
    <xsl:element name="h2">
    Sidebar: <xsl:value-of select="."/>
  </xsl:element>
</xsl:template>


<xsl:template match="tei:p/tei:title">
  <xsl:element name="i">
    <xsl:apply-templates />
  </xsl:element>
</xsl:template>  

<xsl:template match="tei:bibl/tei:title">
  <xsl:element name="i">
    <xsl:apply-templates />
  </xsl:element>
</xsl:template>  

<xsl:template match="tei:p">
  <xsl:element name="p">
    <xsl:apply-templates/> 
  </xsl:element>
</xsl:template>

<xsl:template match="tei:p[@rend]">

  <xsl:element name="p">
<xsl:choose>
    <xsl:when test="@rend='center'">
      <xsl:element name="center">
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
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
    <xsl:when test="@rend='smallcaps'">
      <xsl:element name="span">
        <xsl:attribute name="class">smallcaps</xsl:attribute>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
  </xsl:choose>
  </xsl:element>
</xsl:template>

<xsl:template match="tei:q">
  <xsl:element name="blockquote">
    <xsl:apply-templates /> 
  </xsl:element>
</xsl:template>

<xsl:template match="tei:list">
  <xsl:element name="ul">
   <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="tei:item">
  <xsl:element name="li">
   <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="tei:speaker">
<xsl:element name="br"/>
<xsl:element name="span">
<xsl:attribute name="class">speaker</xsl:attribute>
<xsl:apply-templates/>
</xsl:element>
</xsl:template>

<xsl:template match="tei:sp/tei:p">
<xsl:element name="span">
<xsl:attribute name="class">speech</xsl:attribute>
<xsl:apply-templates/>
</xsl:element>
<xsl:element name="br"/>
</xsl:template>

<!-- convert rend tags to their html equivalents 
     so far, converts: center, italic, smallcaps, bold   -->
<xsl:template match="//*[@rend]">
  <xsl:choose>
    <xsl:when test="@rend='center'">
      <xsl:element name="center">
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
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
    <xsl:when test="@rend='smallcaps'">
      <xsl:element name="span">
        <xsl:attribute name="class">smallcaps</xsl:attribute>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="tei:lb">
  <xsl:element name="br" />
</xsl:template>

<!-- sic : show 'sic' as an editorial comment -->
<xsl:template match="tei:sic">
<xsl:choose>
<xsl:when test="not(ancestor::tei:name)">
  <xsl:apply-templates select="text()"/>
  <!-- show the text between the sic tags -->
  <xsl:element name="span">
    <xsl:attribute name="class">editorial</xsl:attribute>
	[sic]
  </xsl:element>
</xsl:when>
<xsl:otherwise>
<xsl:apply-templates/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>


<!-- line group -->
<xsl:template match="tei:lg">
  <xsl:element name="p">
     <xsl:attribute name="class"><xsl:value-of select="@type"/></xsl:attribute>
    <xsl:apply-templates />
  </xsl:element>
</xsl:template>

<!-- line  -->
<!--   Indentation should be specified in format rend="indent#", where # is
       number of spaces to indent.  --> 
<xsl:template match="tei:l[@rend]">
  <!-- retrieve any specified indentation -->
  <xsl:if test="@rend">
    <xsl:element name="span">
    <xsl:attribute name="class">
      <xsl:value-of select="@rend"/>
    </xsl:attribute>
    </xsl:element>
  </xsl:if>
  <xsl:apply-templates/>
  <xsl:element name="br"/>
</xsl:template>

<xsl:template match="tei:l">
  <xsl:apply-templates/>
  <xsl:element name="br"/>
</xsl:template>

<!-- mark exist matches for highlighting -->
  <xsl:template match="exist:match">
    <span class="match"><xsl:apply-templates/></span>
  </xsl:template>

<!-- simple table test by Alice Hickcox, March 8, 2006 -->
<!-- this works -->

   <xsl:param name="tableAlign">center</xsl:param>
   <xsl:param name="cellAlign">left</xsl:param>

<xsl:template match="tei:table">
<table class="table">
<xsl:for-each select="@*">
<xsl:copy-of select="."/>
</xsl:for-each>
<xsl:apply-templates/></table>
</xsl:template>

<!--add class to center-->
<xsl:template match="tei:table/tei:head">
<h3><xsl:apply-templates/>
</h3>
</xsl:template>

<xsl:template match="tei:row">
<tr><xsl:apply-templates/>
</tr>
</xsl:template>

<xsl:template match="tei:cell">
<td valign="top">
<xsl:apply-templates/>
</td>
</xsl:template>

</xsl:stylesheet>

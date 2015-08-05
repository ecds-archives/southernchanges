<?xml version="1.0" encoding="utf-8"?>  
<xsl:stylesheet version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:tei="http://www.tei-c.org/ns/1.0" 
                xmlns:html="http://www.w3.org/TR/REC-html40"
                xmlns:exist="http://exist.sourceforge.net/NS/exist">

<!-- default indentation if number of spaces is not specified -->
<xsl:param name="defaultindent">5</xsl:param>  

<!-- code adapted from ewwrp -->
<!-- <xsl:variable name="imgserver">http://wilson.library.emory.edu/~ahickco/yjallen/image-content/</xsl:variable> -->
<xsl:variable name="imgserver">http://beck.library.emory.edu/youngjohnallen/image-content/</xsl:variable>
<!-- <xsl:variable name="genrefiction">tgfw/</xsl:variable> need this? -->
<xsl:variable name="figure-prefix">
    <xsl:value-of select="$imgserver"/>
</xsl:variable>
<xsl:variable name="thumbs-prefix"><xsl:value-of select="$figure-prefix"/>thumbs/</xsl:variable>
<xsl:variable name="figure-suffix">.jpg</xsl:variable>

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
    <xsl:apply-templates /> 
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

<xsl:template match="tei:pb">
  <hr class="pb"/>
    <p class="pagebreak">
      Page <xsl:value-of select="@n"/>
</p>
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
<xsl:template match="l">
  <!-- retrieve any specified indentation -->
  <xsl:if test="@rend">
  <xsl:variable name="rend">
    <xsl:value-of select="./@rend"/>
  </xsl:variable>
  <xsl:variable name="indent">
     <xsl:choose>
       <xsl:when test="$rend='indent'">		
	<!-- if no number is specified, use a default setting -->
         <xsl:value-of select="$defaultindent"/>
       </xsl:when>
       <xsl:otherwise>
         <xsl:value-of select="substring-after($rend, 'indent')"/>
       </xsl:otherwise>
     </xsl:choose>
  </xsl:variable>
   <xsl:call-template name="indent">
     <xsl:with-param name="num" select="$indent"/>
   </xsl:call-template>
 </xsl:if>

  <xsl:apply-templates/>
  <xsl:element name="br"/>
</xsl:template>


<!-- generate next & previous links (if present) -->
<!-- note: all div2s, with id, head, and bibl are retrieved in a <siblings> node -->
<xsl:template name="next-prev">

<xsl:element name="table">
  <xsl:attribute name="width">100%</xsl:attribute>

<!-- display articles relative to position of current article -->
<xsl:element name="tr">
<xsl:if test="//prev/@id">
<xsl:element name="th">
    <xsl:text>Previous: </xsl:text>
</xsl:element>
<xsl:element name="td">
 <xsl:element name="a">
   <xsl:attribute name="href">article.php?id=<xsl:value-of
                select="//prev/@id"/></xsl:attribute>
   <xsl:apply-templates select="//prev/head"/>
 </xsl:element><!-- end td -->
<xsl:element name="td"><xsl:apply-templates select="//prev/@type"></xsl:apply-templates></xsl:element><!-- end td -->
<xsl:element name="td"><xsl:apply-templates
select="//prev/docDate"/></xsl:element>
</xsl:element><!-- end td -->
</xsl:if>
</xsl:element><!-- end  prev row -->

<xsl:element name="tr">
<xsl:if test="//next/@id">
<xsl:element name="th">
    <xsl:text>Next: </xsl:text>
</xsl:element>
<xsl:element name="td">
 <xsl:element name="a">
   <xsl:attribute name="href">article.php?id=<xsl:value-of
                select="//next/@id"/></xsl:attribute>
   <xsl:apply-templates select="//next/head"/>
 </xsl:element><!-- end td -->
<xsl:element name="td"><xsl:apply-templates select="//next/@type"></xsl:apply-templates></xsl:element><!-- end td -->
<xsl:element name="td"><xsl:apply-templates
select="//next/docDate"/></xsl:element>
</xsl:element><!-- end td -->
</xsl:if>
</xsl:element><!-- end  next row -->


</xsl:element> <!-- table -->
</xsl:template>



<xsl:template name="return">
      <xsl:element name="p">
        Go to <xsl:element name="a">
          <xsl:attribute
              name="href">index.php</xsl:attribute>
<xsl:attribute name="rel">Contents</xsl:attribute>Document List
</xsl:element> <!-- a -->
</xsl:element> <!-- p -->

</xsl:template>

<!-- mark exist matches for highlighting -->
  <xsl:template match="exist:match">
    <span class="match"><xsl:apply-templates/></span>
  </xsl:template>

<!-- simple table test by Alice Hickcox, March 8, 2006 -->
<!-- this works -->
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

<xsl:template match="table/head">
<h3><xsl:apply-templates/>
</h3>
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

<!-- figure code from ewwrp -->
<xsl:template match="figure">
  <xsl:element name="div">      <!-- wrap image in a div so it can be centered -->
    <xsl:attribute name="class">figure</xsl:attribute>
    <xsl:element name="img">
      <xsl:apply-templates select="@rend"/>
      <xsl:attribute name="src"><xsl:value-of select="concat($figure-prefix, @entity, $figure-suffix)"/></xsl:attribute>
      <xsl:attribute name="alt"><xsl:value-of select="normalize-space(figDesc)"/></xsl:attribute>
    </xsl:element>  <!-- img -->
  </xsl:element> <!-- div -->
</xsl:template>

<xsl:template match="figure/@rend">
  <xsl:attribute name="class"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

</xsl:stylesheet>

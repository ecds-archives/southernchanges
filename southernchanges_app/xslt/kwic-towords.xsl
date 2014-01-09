<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:exist="http://exist.sourceforge.net/NS/exist">

<xsl:param name="context">150</xsl:param>
<xsl:param name="minParaSize">10</xsl:param>

  <xsl:output method="xml" omit-xml-declaration="yes"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- do nothing with page itself -->
  <xsl:template match="context/page">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="context//p | context//item">
    <xsl:choose>
      <xsl:when test="string-length(.) &gt; $minParaSize">      
      <!-- only display a paragraph if it is larger than a certain size -->
      <!-- NOTE: this was added to deal with parts of Lincoln Sermon titles tagged as paragraphs -->
        <xsl:element name="p">
          <xsl:attribute name="class">kwic</xsl:attribute>
<!--
          <xsl:variable name="page">
            <xsl:choose>
              <xsl:when test="@pn">
                <xsl:value-of select="@pn"/>
              </xsl:when>
              <xsl:when test="parent::page/@n = ''">
                <xsl:value-of select="./pb/@n"/>
              </xsl:when>
              <xsl:otherwise> -->
                <!-- note: xquery max function returns numbers as 11.0; strip off the decimal -->
<!--                <xsl:value-of select="substring-before(parent::page/@n, '.')"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
-->
    <!--      <xsl:attribute name="pn"><xsl:value-of
    select="$page"/></xsl:attribute> -->
          <!-- FIXME: how to check if a pb occurs within paragraph, before first keyword ? -->
          <xsl:apply-templates mode="split"/> 
       </xsl:element>
     </xsl:when>
     <xsl:otherwise/>	<!-- don't display -->
    </xsl:choose>
  </xsl:template>

  <!-- keyword mark in exist -->
  <xsl:template match="exist:match">
    <match>
      <xsl:if test="../@rend">
         <xsl:attribute name="rend"><xsl:value-of select="../@rend"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </match>
  </xsl:template>

  <!-- keyword mark in tamino -->
  <!-- get only the text immediately between the start (+) and end (-) processing instructions -->
   <xsl:template match="text()[preceding-sibling::processing-instruction('MATCH')[1][starts-with(., '+')] and 
                        following-sibling::processing-instruction('MATCH')[1][starts-with(., '-')]]" mode="split"> 
    <match>
      <xsl:if test="../@rend">
         <xsl:attribute name="rend"><xsl:value-of select="../@rend"/></xsl:attribute>
      </xsl:if>
      <xsl:value-of select="."/>
    </match>

  </xsl:template> 

  <!-- get rid of figures (not needed for kwic) -->
  <xsl:template match="context//p/figure" mode="split"/>
  <!-- get rid of pbs also  -->
  <xsl:template match="context//p/pb" mode="split"/>

  <!-- added for Yeats. -->
  <!-- ignore stage directions in middle of paragraph -->
  <xsl:template match="context//p/stage" mode="split"/>
  <xsl:template match="context//p/ln" mode="split"/>

  <!-- make sure to tokenize text in hi tags, too -->
  <xsl:template match="context//hi" mode="split">
      <xsl:apply-templates mode="split"/>	<!-- handle text nodes -->
  </xsl:template>

<!-- make sure to tokenize text in title tags, too -->
  <xsl:template match="context//p/title" mode="split">
      <xsl:apply-templates mode="split"/>	<!-- handle text nodes -->
  </xsl:template>

<!-- ignore list items inside p in SC; items are matched separately -->
  <xsl:template match="context//p/list" mode="split"/>


   

  <!-- special case: if a single word is inside a hi tag, the tamino
       highlighting may not necessarily be nested properly 
       (e.g., looks something like <hi><MATCH>word</hi><MATCH> ) -->
<!--   <xsl:template match="context//p/hi[processing-instruction('MATCH')]" mode="split">
    <xsl:choose>
      <xsl:when test="contains(., ' ')">
      <xsl:apply-templates mode="split"/> -->	<!-- handle text nodes normally -->
<!--      </xsl:when>
      <xsl:otherwise>
        <match>
         <xsl:attribute name="rend"><xsl:value-of select="@rend"/></xsl:attribute>
         <xsl:value-of select="."/>
        </match>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
-->


  <!-- for anything besides text, do default action -->
  <xsl:template match="context//p//*" mode="split" priority="-1">   
    <xsl:apply-templates select="."/> 
 </xsl:template>  

 <!-- split on list items also -->
  <xsl:template match="context//item//*" mode="split" priority="-1">   
    <xsl:apply-templates select="."/> 
 </xsl:template>  


  <!-- tokenization logic from Jeni Tennison -->
  <xsl:template match="text()" mode="split" name="split">
    <xsl:param name="string" select="string()"/>
    <xsl:param name="rend" select="../@rend"/>		<!-- if parent has a rend tag (e.g., hi), get it -->
    <xsl:variable name="space"><xsl:text> </xsl:text></xsl:variable>
      <xsl:variable name="multiword" select="contains($string, $space)"/>

      <xsl:variable name="word">
        <xsl:choose>
          <xsl:when test="$multiword">
            <xsl:value-of select="normalize-space(substring-before($string, $space))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="normalize-space($string)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:if test="string($word)">
        <w>
          <xsl:if test="$rend">
            <xsl:attribute name="rend"><xsl:value-of select="$rend"/></xsl:attribute>
          </xsl:if>
	<xsl:value-of select="$word"/></w> <!-- word -->
      </xsl:if>

      <xsl:if test="$multiword">
        <xsl:call-template name="split">
          <xsl:with-param name="string" select="substring-after($string, $space)"/>
        </xsl:call-template>
      </xsl:if>

  </xsl:template>


<!-- default template -->
<xsl:template match="@*|node()">
            <xsl:copy>
              <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>

</xsl:template>


</xsl:stylesheet>

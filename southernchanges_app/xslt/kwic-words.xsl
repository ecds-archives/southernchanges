<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
                version="1.0" >

<xsl:param name="context">15</xsl:param>
<!-- <xsl:param name="minParaSize">30</xsl:param> -->

  <xsl:output method="xml" omit-xml-declaration="yes"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="context/p|context/l|context/item">
    <p class="kwic">
     <!-- <xsl:attribute name="pn">
        <xsl:value-of select="@pn"/> 
      </xsl:attribute> -->
      <!-- FIXME: how to get the page number if it is INSIDE the paragraph? -->
      <xsl:choose>
        <xsl:when test="count(.//match) > 1">
          <xsl:apply-templates select=".//match[1]" mode="kwic-multiple"/>           
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select=".//match" mode="kwic"/>           
        </xsl:otherwise>
      </xsl:choose>

   </p>
  </xsl:template>


  <xsl:template match="match" mode="kwic">
    <!--     <xsl:text>...</xsl:text> -->
    <!-- DEBUG: in match='match'-->

    <!-- note: not using sibling axis because words may be inside hi tags -->
    <xsl:apply-templates select="preceding-sibling::w[1]" mode="kwic-prev">
      <xsl:with-param name="count"><xsl:value-of select="$context"/></xsl:with-param>
    </xsl:apply-templates>

      <xsl:apply-templates select="."/>

    <xsl:apply-templates select="following-sibling::w[1]" mode="kwic-next">
      <!--      <xsl:with-param name="count"><xsl:value-of select="$context"/></xsl:with-param> -->
      <xsl:with-param name="count"><xsl:value-of select="$context"/></xsl:with-param>
    </xsl:apply-templates>

    <!--       <xsl:text>...</xsl:text> -->
  </xsl:template>


  <!-- multiple matches within a single paragraph -->
  <xsl:template match="match" mode="kwic-multiple">
    <xsl:param name="second" value="false"/>	<!-- if true, this is a second match within $context words -->
    <!-- count # of words to next match -->
    <xsl:variable name="wcount"><xsl:apply-templates select="following-sibling::*[1]" mode="count"/></xsl:variable>

    <xsl:if test="$second != 'true'">
      <!--       <xsl:text>...</xsl:text>  -->
      <xsl:apply-templates select="preceding-sibling::w[1]" mode="kwic-prev">
        <xsl:with-param name="count"><xsl:value-of select="$context"/></xsl:with-param>
      </xsl:apply-templates>
    </xsl:if>

    <!-- pick up & pass on any formatting on the keyword itself, e.g. highlighting -->
    <xsl:choose>
       <xsl:when test="@rend">
         <!-- use tei style hi rend, because this will still be translated to html -->
         <hi><xsl:attribute name="rend"><xsl:value-of select="@rend"/></xsl:attribute>
         <!-- make sure there are spaces around keyword -->
 	  <xsl:text> </xsl:text><xsl:apply-templates select="."/><xsl:text> </xsl:text> 
	  </hi>
       </xsl:when>
       <xsl:when test="title"> 
	 <!-- in SC titles are sometimes marked with this element -->
	  <hi><xsl:attribute name="rend">italic</xsl:attribute><xsl:value-of select="title"/>
         <!-- make sure there are spaces around keyword -->
 	  <xsl:text> </xsl:text><xsl:apply-templates select="."/><xsl:text> </xsl:text> 
	  </hi>
       </xsl:when>
       <xsl:otherwise>	  
         <xsl:text> </xsl:text><xsl:apply-templates select="."/><xsl:text> </xsl:text>
       </xsl:otherwise>
    </xsl:choose>


    <xsl:apply-templates select="following-sibling::w[1]" mode="kwic-next">
      <xsl:with-param name="count">
        <xsl:choose>
          <xsl:when test="$wcount &gt; ($context * 2)">
            <!-- if count to next match is more than double context, only display context -->
            <xsl:value-of select="$context"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$wcount"/>
          </xsl:otherwise>
        </xsl:choose>
	</xsl:with-param>
    </xsl:apply-templates>

    <xsl:if test="$wcount &gt; ($context * 2)"><xsl:text>...</xsl:text></xsl:if>      

    <xsl:choose>
      <xsl:when test="following-sibling::match">
        <!-- apply templates to the next match, if there is one -->
        <xsl:apply-templates select="following-sibling::match[1]" mode="kwic-multiple">
          <xsl:with-param name="second"><xsl:value-of select="$wcount &lt;= ($context * 2)"/></xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <!--         <xsl:text>...</xsl:text> -->
      </xsl:otherwise>
    </xsl:choose>



    </xsl:template>


  <xsl:template match="*" mode="count">
    <xsl:param name="n" select="1"/>
    <xsl:choose>
      <xsl:when test="$n > ($context * 2)">
        <!-- there are more words than double $context, exact # does not matter; return -->
        <xsl:value-of select="$n"/>        
      </xsl:when>
      <xsl:when test="local-name() = 'match'">
        <!-- hit the next match, return count (don't count current node) -->
        <xsl:value-of select="$n - 1"/>
      </xsl:when>
      <xsl:when test="following-sibling::*">
        <!-- if there are more nodes, keep counting -->
       <xsl:apply-templates select="following-sibling::*[1]" mode="count">
         <xsl:with-param name="n"><xsl:value-of select="$n + 1"/></xsl:with-param>
       </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <!-- there are no more nodes, return count -->
        <xsl:value-of select="$n"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="w" mode="kwic"/>	<!-- do nothing in kwic mode, only kwic-next & kwic-prev -->

  <!-- kwic-next & kwic-prev are two recursive templates to print a specified number of words -->

  <!-- print out count words following -->
  <xsl:template match="w" mode="kwic-next">
    <xsl:param name="count"/>
    <!--  DEBUG: in kwic-next, count is <xsl:value-of select="$count"/> -->

    <xsl:choose>
      <xsl:when test="$count > 0">
        <xsl:variable name="myword">
          <xsl:text> </xsl:text><xsl:value-of select="."/><xsl:text> </xsl:text>  
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="@rend">
            <!-- use tei style hi rend, because this will still be translated to html -->
            <hi><xsl:attribute name="rend"><xsl:value-of select="@rend"/></xsl:attribute>
            <xsl:value-of select="$myword"/></hi>
          </xsl:when>
       <xsl:when test="title"> 
	 <!-- in SC titles are sometimes marked with this element -->
	  <hi><xsl:attribute name="rend">italic</xsl:attribute><xsl:value-of select="title"/>
         <!-- make sure there are spaces around keyword -->
 	  <xsl:text> </xsl:text><xsl:apply-templates select="."/><xsl:text> </xsl:text> 
	  </hi>
       </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$myword"/>
          </xsl:otherwise>
        </xsl:choose>
        
        <xsl:apply-templates select="following-sibling::w[1]" mode="kwic-next">
          <xsl:with-param name="count"><xsl:value-of select="$count - 1"/></xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$count != 0">	<!-- don't hit edge condition in context between matches -->
        <xsl:apply-templates select="following-sibling::w[1]" mode="end"/>
      </xsl:when>
    </xsl:choose>

  </xsl:template>

  <!-- print out count words preceding -->
  <xsl:template match="w" mode="kwic-prev">
    <xsl:param name="count"/>
    <!--  DEBUG: in kwic-prev, count is <xsl:value-of select="$count"/> -->
    <xsl:choose>
      <xsl:when test="$count > 0">
        <!-- to get the words in the right order, recurse first, then print -->
        <xsl:apply-templates select="preceding-sibling::w[1]" mode="kwic-prev">
          <xsl:with-param name="count"><xsl:value-of select="$count - 1"/></xsl:with-param>
        </xsl:apply-templates>
        <!-- make sure there are spaces around each word -->
        <xsl:variable name="myword">
          <xsl:text> </xsl:text><xsl:value-of select="."/><xsl:text> </xsl:text>      
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="@rend">
            <!-- use tei style hi rend, because this will still be translated to html -->
            <hi><xsl:attribute name="rend"><xsl:value-of select="@rend"/></xsl:attribute>
            <xsl:value-of select="$myword"/></hi>
          </xsl:when>
       <xsl:when test="title"> 
	 <!-- in SC titles are sometimes marked with this element -->
	  <hi><xsl:attribute name="rend">italic</xsl:attribute><xsl:value-of select="title"/>
         <!-- make sure there are spaces around keyword -->
 	  <xsl:text> </xsl:text><xsl:apply-templates select="."/><xsl:text> </xsl:text> 
	  </hi>
       </xsl:when>

          <xsl:otherwise>
            <xsl:value-of select="$myword"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="preceding-sibling::w[1]" mode="end"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- at end of context; if there is another word, display ellipses. -->
  <xsl:template match="w" mode="end">
    <xsl:text>...</xsl:text>
  </xsl:template>


  <!-- for anything besides text, do default action -->
  <!--  <xsl:template match="context/p/*" mode="kwic">
    <xsl:apply-templates select="."/> 
  </xsl:template>-->


<!-- default template -->
<xsl:template match="@*|node()">
  <xsl:if test="name() != 'w'">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:if>
</xsl:template>


</xsl:stylesheet>

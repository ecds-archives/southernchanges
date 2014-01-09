<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:tei="http://www.tei-c.org/ns/1.0"
		xmlns:dc="http://purl.org/dc/elements/1.1/"
		xmlns:dcterms="http://purl.org/dc/terms" version="1.0"
		xmlns:exist="http://exist.sourceforge.net/NS/exist"
		>
  <!-- This stylesheet creates Dublin core metadata for the article
  level page -->
  <xsl:output method="xml" omit-xml-declaration="yes"/>

  <xsl:param name="qualified">true</xsl:param>

  <xsl:variable name="baseurl">http://beck.library.emory.edu/</xsl:variable>
  <xsl:variable name="siteurl">southernchanges</xsl:variable>

  <xsl:key name="pid" match="tei:idno" use="@n"/> <!-- use @n to match @id in div2-->

  <xsl:template match="/">
    <dc>
      <xsl:apply-templates/>
    <dc:type>Text</dc:type>
    <dc:format>text/xml</dc:format>
    </dc>
  </xsl:template>

  <xsl:template match="TEI">
    <xsl:apply-templates select=".//tei:div2"/>
    <xsl:apply-templates select=".//tei:fileDesc"/>
  </xsl:template>

  <xsl:template match="tei:div2">
    <xsl:variable name="id" select="@xml:id"/>
    <xsl:element name="dc:title">
      <xsl:apply-templates select="tei:head"/>
    </xsl:element>
      <xsl:for-each select=".//tei:docAuthor">
    <xsl:element name="dc:creator">
	<xsl:apply-templates select="tei:name//tei:reg"/>
    </xsl:element>
      </xsl:for-each> 
    <xsl:element name="dc:identifier">
     <!-- <xsl:value-of select="$baseurl"/><xsl:value-of
      select="$siteurl"/><xsl:text>/article.php?id=</xsl:text><xsl:apply-templates
      select="@id"/> -->
     <xsl:value-of select="key('pid', $id)"/>
    </xsl:element>
  </xsl:template>


  <xsl:template match="tei:fileDesc">
  <xsl:variable name="date">
    <xsl:apply-templates select=".//tei:sourceDesc/tei:bibl/tei:date"/>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="$qualified = 'true'">
     <xsl:element name="dcterms:isPartOf">
      <xsl:value-of select="tei:titleStmt/tei:title"/><xsl:text>, </xsl:text><xsl:value-of select="$date"/> 
    </xsl:element>
    <xsl:element name="dcterms:isPartOf">
      <xsl:value-of select="$baseurl"/><xsl:value-of
      select="$siteurl"/>/article-list.php?id=<xsl:value-of
      select="../../issueid/@xml:id"/>      
    </xsl:element>
    </xsl:when>
    <xsl:otherwise>
     <xsl:element name="dc:relation">
      <xsl:value-of select="tei:titleStmt/tei:title"/><xsl:text>, </xsl:text><xsl:value-of select="$date"/> 
    </xsl:element>
    <xsl:element name="dc:relation">
      <xsl:value-of select="$baseurl"/><xsl:value-of
      select="$siteurl"/>/article-list.php?id=<xsl:value-of
      select="../../issueid/@xml:id"/>      
    </xsl:element>
    </xsl:otherwise>
  </xsl:choose>
    <xsl:element name="dc:contributor">
      <xsl:text>Southern Regional Council</xsl:text>
    </xsl:element>

    <xsl:element name="dc:contributor">
      <xsl:text>Lewis H. Beck Center</xsl:text>
    </xsl:element>

    <xsl:element name="dc:publisher">
      <xsl:value-of select="tei:publicationStmt/tei:publisher"/>
    </xsl:element>

  <!-- electronic publication date: Per advice of LA -->
<xsl:if test="$qualified = 'true'">
    <xsl:element name="dcterms:issued">
      <xsl:apply-templates select="tei:publicationStmt/tei:date"/>
    </xsl:element>

    <xsl:element name="dcterms:created">
      <xsl:value-of select="tei:sourceDesc/tei:bibl/tei:date/@when"/>
    </xsl:element>
</xsl:if>

    <xsl:element name="dc:rights">
      <xsl:apply-templates select="tei:publicationStmt/tei:availability/tei:p"/>
    </xsl:element>

    <xsl:choose>
      <xsl:when test="$qualified = 'true'">
	<xsl:element name="dcterms:isPartOf">
	  <xsl:apply-templates select="tei:seriesStmt/tei:title"/>
	</xsl:element>

	<xsl:element name="dcterms:isPartOf">
	  <xsl:value-of select="$baseurl"/><xsl:value-of
	  select="$siteurl"/>      
	</xsl:element>
      </xsl:when>

      <xsl:otherwise>
	<xsl:element name="dc:relation">
	  <xsl:apply-templates select="tei:seriesStmt/tei:title"/>
	</xsl:element>

	<xsl:element name="dc:relation">
	  <xsl:value-of select="$baseurl"/><xsl:value-of
	  select="$siteurl"/>      
	</xsl:element>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:element name="dc:source">
      <!-- process all elements, in this order. -->
      <xsl:apply-templates select="tei:sourceDesc/tei:bibl/tei:title"/>
      <xsl:apply-templates select="tei:sourceDesc/tei:bibl/tei:pubPlace"/>
      <xsl:apply-templates select="tei:sourceDesc/tei:bibl/tei:publisher"/>
      <xsl:apply-templates select="tei:sourceDesc/tei:bibl/tei:biblScope[@type='volume']"/>
      <xsl:apply-templates select="tei:sourceDesc/tei:bibl/tei:biblScope[@type='issue']"/>
      <xsl:apply-templates select="tei:sourceDesc/tei:bibl/tei:date"/>
      <!-- in case source is in plain text, without tags -->
    <!--  <xsl:apply-templates select="text()"/> -->
    </xsl:element>
  </xsl:template>

  <!-- formatting for bibl elements, to generate a nice citation. -->
 
  <xsl:template match="tei:bibl/tei:title"><xsl:apply-templates/>. </xsl:template>
  <xsl:template match="tei:bibl/tei:pubPlace">
          <xsl:apply-templates/>:  </xsl:template>
  <xsl:template match="tei:bibl/tei:publisher">
      <xsl:apply-templates/>, </xsl:template>
  <xsl:template
      match="tei:bibl/tei:biblScope[@type='volume']"><xsl:apply-templates/>, </xsl:template>
  <xsl:template
      match="tei:bibl/tei:biblScope[@type='issue']"><xsl:apply-templates/>, </xsl:template>
  <xsl:template match="tei:bibl/tei:date"><xsl:apply-templates/>. </xsl:template>
  

<!-- handle multiple names -->
  <xsl:template name="multiname" match="tei:name//tei:reg">
    <xsl:choose>
      <xsl:when test="position() = 1"></xsl:when>
  <xsl:when test="position() = last()">
        <xsl:text> and </xsl:text>
      </xsl:when>
    <xsl:otherwise>
	<xsl:text>, </xsl:text>
      </xsl:otherwise>
  </xsl:choose>
  <xsl:apply-templates/>
  </xsl:template>

<!-- add a space after titles in the head -->
  <xsl:template match="tei:head/tei:title">
    <xsl:apply-templates/><xsl:text> </xsl:text>
  </xsl:template>

<!-- make a line break a space in the head -->
  <xsl:template match="tei:head/tei:lb">
    <xsl:text> </xsl:text>
  </xsl:template>

  <!-- ignore for now; do these fit anywhere? -->
  <xsl:template match="tei:publicationStmt//tei:address/tei:addrLine"/>
  <xsl:template match="tei:publicationStmt/tei:pubPlace"/>
  <xsl:template match="tei:respStmt"/>
  <xsl:template match="tei:profileDesc/tei:langUsage/tei:p"/>

  <!-- ignore these: encoding specific information -->
  <xsl:template match="tei:div2/tei:p"/>
  <xsl:template match="tei:div2/tei:div3"/>
  <xsl:template match="issue-id/tei:head"/>
  <xsl:template match="issueid/tei:head"/>
  <xsl:template match="next"/>
  <xsl:template match="prev"/>
  <xsl:template match="tei:encodingDesc/tei:projectDesc"/>
  <xsl:template match="tei:encodingDesc/tei:tagsDecl"/>
  <xsl:template match="tei:encodingDesc/tei:refsDecl"/>
  <xsl:template match="tei:encodingDesc/tei:editorialDecl"/>
  <xsl:template match="tei:revisionDesc"/>

  <!-- normalize space for all text nodes -->
  <xsl:template match="text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>

</xsl:stylesheet>

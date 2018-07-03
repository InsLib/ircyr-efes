<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- XSLT to convert index metadata and index Solr results into
       HTML. This is the common functionality for both TEI and EpiDoc
       indices. It should be imported by the specific XSLT for the
       document type (eg, indices-epidoc.xsl). -->

  <xsl:import href="to-html.xsl" />

  <xsl:template match="index_metadata" mode="title">
    <xsl:value-of select="tei:div/tei:head" />
  </xsl:template>

  <xsl:template match="index_metadata" mode="head">
    <xsl:apply-templates select="tei:div/tei:head/node()" />
  </xsl:template>

  <xsl:template match="tei:div[@type='headings']/tei:list/tei:item">
    <th scope="col">
      <xsl:apply-templates/>
    </th>
  </xsl:template>

  <xsl:template match="tei:div[@type='headings']">
    <thead>
      <tr>
        <xsl:apply-templates select="tei:list/tei:item"/>
      </tr>
    </thead>
  </xsl:template>

  <xsl:template match="result/doc">
    <tr>
      <xsl:apply-templates select="str[@name='index_item_name']" />
      <xsl:apply-templates select="str[@name='index_abbreviation_expansion']"/>
      <xsl:apply-templates select="str[@name='index_numeral_value']"/>
      <xsl:apply-templates select="arr[@name='language_code']"/>
      <xsl:apply-templates select="arr[@name='index_instance_location']" />
    </tr>
  </xsl:template>

  <xsl:template match="response/result">
    <table class="index">
      <xsl:apply-templates select="/aggregation/index_metadata/tei:div/tei:div[@type='headings']" />
      <tbody>
        <xsl:apply-templates select="doc" />
      </tbody>
    </table>
  </xsl:template>

  <xsl:template match="str[@name='index_abbreviation_expansion']">
    <td>
      <xsl:value-of select="." />
    </td>
  </xsl:template>

  
  <xsl:template match="str[@name='index_item_name']">
    <th scope="row">
      <!-- Look up the value in the RDF names, in case it's there.
        The QQQQQ string is added at time of indexing to mark instances
        of symbols that expand to abbreviations -->
      <xsl:variable name="current-marked">
        <xsl:if test="contains(current(), 'QQQQQ')">
          <xsl:value-of select="substring-before(current(), 'QQQQQ')"/>
        </xsl:if>
      </xsl:variable>
      <xsl:variable name="current-unmarked">
        <xsl:if test="not(contains(current(), 'QQQQQ'))">
          <xsl:value-of select="current()"/>
        </xsl:if>
      </xsl:variable>
      <xsl:variable name="rdf-name-marked" select="/aggregation/index_names/rdf:RDF/rdf:Description[@rdf:about=$current-marked][1]/*[@xml:lang=$language][1]" />
      <xsl:variable name="rdf-name-unmarked" select="/aggregation/index_names/rdf:RDF/rdf:Description[@rdf:about=$current-unmarked][1]/*[@xml:lang=$language][1]" />
      <xsl:choose>
        <xsl:when test="normalize-space($rdf-name-marked)">
          (<xsl:value-of select="$rdf-name-marked" />)
        </xsl:when>
        <xsl:when test="normalize-space($rdf-name-unmarked)">
          <xsl:value-of select="$rdf-name-unmarked" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </th>
  </xsl:template>
  
  

  <xsl:template match="arr[@name='index_instance_location']">
    <td>
      <ul class="index-instances inline-list">
        <xsl:apply-templates select="str" />
      </ul>
    </td>
  </xsl:template>

  <xsl:template match="str[@name='index_numeral_value']">
    <td>
      <xsl:value-of select="."/>
    </td>
  </xsl:template>

  <xsl:template match="arr[@name='language_code']">
    <td>
      <ul class="inline-list">
        <xsl:apply-templates select="str"/>
      </ul>
    </td>
  </xsl:template>

  <xsl:template match="arr[@name='language_code']/str">
    <li>
      <xsl:value-of select="."/>
    </li>
  </xsl:template>

  <xsl:template match="arr[@name='index_instance_location']/str">
    <!-- This template must be defined in the calling XSLT (eg,
         indices-epidoc.xsl) since the format of the location data is
         not universal. -->
    <xsl:call-template name="render-instance-location" />
  </xsl:template>

</xsl:stylesheet>

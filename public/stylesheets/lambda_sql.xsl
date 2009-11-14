<?xml version="1.0"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="1.0">
  <xsl:output method="xml" indent="yes" encoding="utf-8" 
	      omit-xml-declaration="no"
	      doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
	      doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>

  <xsl:param name="format"/>
  <xsl:param name="table"/>

  <xsl:include href="table.xsl"/>

  <xsl:template match="/" mode="page">
    <xsl:param name="title" select="'untitled'"/>
    <xsl:param name="onload"/>
    <html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
      <head>
	<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8" />
	<title>Lambda SQL : <xsl:value-of select="$title"/></title>
	<link href="/stylesheets/lambda_sql.css"
	      media="screen" rel="stylesheet" type="text/css" />

	<xsl:apply-templates select="." mode="page_specific_meta"/>

        <script type="text/javascript" src="/javascripts/prototype.js">
	</script>
        <script type="text/javascript" src="/javascripts/controls.js">
	</script>
        <script type="text/javascript" src="/javascripts/dragdrop.js">
	</script>
        <script type="text/javascript" src="/javascripts/effects.js">
	</script>
        <script type="text/javascript" src="/javascripts/application.js">
	</script>

      </head>
      <body onload="{$onload}; onload_app();">
	<div class="header">
	  <xsl:apply-templates select="." mode="header"/>
	  <div style="padding:0;margin;0;border:0;float:right">
	    <a href="?" id="as_xml_url">
	    [as xml]
	    </a>
	  </div>
	</div>
	<div>
	  <xsl:apply-templates select="." mode="body"/>
	</div>
	
	<div class="xml_iframe">
	  <iframe id="as_xml_iframe" height="500" width="100%" src=""/>
	</div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="*" mode="tabs">
    lambda_sql.xsl default tabs
  </xsl:template>

  <xsl:template match="*" mode="header">
    lambda_sql.xsl default header
  </xsl:template>

  <xsl:template match="*" mode="header_main">
    <xsl:apply-templates 
       select="ancestor-or-self::view/metadata/tables/table" 
       mode="link"/>
  </xsl:template>
  
  <xsl:template match="table" mode="link">
    <xsl:variable name="link"><xsl:choose>
	<xsl:when test="$table">table=<xsl:value-of select="$table"/>&amp;join1=<xsl:value-of select="@name"/></xsl:when>
	<xsl:otherwise>table=<xsl:value-of select="@name"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <a href="?{$link}"><xsl:value-of select="@name"/></a>
  </xsl:template>

  <xsl:template match="*" mode="body">
    lambda_sql.xsl default body
  </xsl:template>

  <xsl:template match="*" mode="dropdown">
    <xsl:param name="top"/>
    <xsl:param name="selected"/>
    <xsl:param name="filterby"/>
    <xsl:param name="form_input_name"/>
    <xsl:param name="table_alias"/>
    <select name="{$form_input_name}" onchange="submit()">
      <xsl:copy-of select="$top"/>
      <xsl:apply-templates mode="option">
	<xsl:with-param name="filterby" select="$filterby"/>
	<xsl:with-param name="selected" select="$selected"/>
	<xsl:with-param name="table_alias" select="$table_alias"/>
      </xsl:apply-templates>
    </select>
  </xsl:template>

  <xsl:template match="*" mode="option">
    <xsl:param name="selected"/>
    <option>
      <xsl:if test="$selected = @name">
	<xsl:attribute name="selected">selected</xsl:attribute>
      </xsl:if>
      <xsl:value-of select="@name"/>
    </option>
  </xsl:template>

</xsl:stylesheet>

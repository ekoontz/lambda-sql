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

  <xsl:template match="/" mode="page">
    <xsl:param name="title" select="'untitled'"/>
    <xsl:param name="onload"/>
    <html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
      <head>
	<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8" />
	<title>Lambda SQL:<xsl:value-of select="$title"/></title>
	<link href="/stylesheets/lambda_sql.css"
	      media="screen" rel="stylesheet" type="text/css" />

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
      <body onload="{$onload}">
	<div class="header">
	  <xsl:apply-templates select="." mode="header"/>
	</div>
	<div>
	  <xsl:apply-templates select="." mode="body"/>
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
    <a href="/business_unit">business units</a>
    <a href="/person">people</a>
    <a href="/project">projects</a>
  </xsl:template>

  <xsl:template match="*" mode="body">
    lambda_sql.xsl default body
  </xsl:template>

  <xsl:template match="*" mode="table">
    <div class="table">
      <table>
	<thead>
	  <xsl:apply-templates select="*[position() = 1]" mode="thead">
	  </xsl:apply-templates>
	</thead>
	<tbody>
	  <xsl:apply-templates select="*" mode="tbody"/>
	</tbody>
      </table>
    </div>

  </xsl:template>

  <xsl:template match="*" mode="thead">
    <tr>
      <th/>
      <xsl:apply-templates select="@*" mode="th"/>
    </tr>
  </xsl:template>

  <xsl:template match="@*" mode="th">
    <th><xsl:value-of select="name()"/></th>
  </xsl:template>

  <xsl:template match="*" mode="tbody">
    <tr class="row_{position() mod 2}">
      <th><xsl:value-of select="position()"/></th>
      <xsl:apply-templates select="@*" mode="td"/>
    </tr>
  </xsl:template>

  <xsl:template match="@*" mode="td">
    <td><xsl:value-of select="."/></td>
  </xsl:template>


</xsl:stylesheet>

<?xml version="1.0"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="1.0">

  <xsl:include href="public/stylesheets/lambda_sql.xsl"/>

  <xsl:template match="/">
    <xsl:apply-templates select="." mode="page">
      <xsl:with-param name="title">SQL View List</xsl:with-param>
      <xsl:with-param name="onload"></xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="*" mode="header">
    <xsl:apply-templates select="." mode="header_main"/>
    <h2>SQL views</h2>

  </xsl:template>

  <xsl:template match="view" mode="body">

    <h3>Query Controller</h3>
    <form action="?" method="get">
      <div>
	<table>
	  <tr>
	    <td>
	      <xsl:apply-templates select="metadata/tables" mode="dropdown">
		<xsl:with-param name="name" select="'table'"/>
	      </xsl:apply-templates>
	    </td>
	    <td>join on:</td>
	    <td>
	      <select name="join1">
		<option/>
		<option>
		  <xsl:if test="params/@join1 = 'business_units'">
		    <xsl:attribute name="selected">selected</xsl:attribute>
		  </xsl:if>
		    business_units
		  </option>
		<option>
		  <xsl:if test="params/@join1 = 'people'">
		    <xsl:attribute name="selected">selected</xsl:attribute>
		  </xsl:if>
		  people</option>
	      </select>
	    </td>
	    <td>
	      <input type="submit"/>
	    </td>
	  </tr>
	</table>
      </div>
    </form>

    <h3>Current SQL View:</h3>
    <div>
      <div class="pre">
	<xsl:value-of select="rows/@sql"/>
      </div>
      
      <xsl:apply-templates select="rows" mode="table"/>
    </div>
  </xsl:template>

  <xsl:template match="tables" mode="dropdown">
    <xsl:param name="name"/>
    <select name="{$name}">
      <xsl:apply-templates select="table" mode="option"/>
      <option>
	<xsl:if test="params/@table = 'business_units'">
	  <xsl:attribute name="selected">selected</xsl:attribute>
	</xsl:if>
	business_units
      </option>
      <option>
	<xsl:if test="params/@table = 'people'">
	  <xsl:attribute name="selected">selected</xsl:attribute>
		  </xsl:if>
	people</option>
    </select>
  </xsl:template>

  <xsl:template match="table" mode="option">
    <option>
      <xsl:if test="ancestor::view/params/@table = @tablename">
	<xsl:attribute name="selected">selected</xsl:attribute>
      </xsl:if>
      <xsl:value-of select="@tablename"/>
    </option>
  </xsl:template>


</xsl:stylesheet>
  

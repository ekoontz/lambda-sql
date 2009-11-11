<?xml version="1.0"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="1.0">

  <xsl:include href="public/stylesheets/lambda_sql.xsl"/>

  <xsl:template match="*" mode="page_specific_meta">
    <link href="/stylesheets/sql_view.css"
	  media="screen" rel="stylesheet" type="text/css" />
  </xsl:template>

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
    <form action="?" method="get">
      <div>
	<table>
	  <tr>
	    <td>
	      <xsl:apply-templates select="metadata/tables" mode="dropdown">
		<xsl:with-param name="form_input_name" select="'table'"/>
		<xsl:with-param name="selected" select="params/@table"/>
	      </xsl:apply-templates>
	    </td>
	    <td>one</td>
	    <td>
	      <xsl:apply-templates select="metadata/joindirs" mode="dropdown">
		<xsl:with-param name="form_input_name" select="'joindir'"/>
		<xsl:with-param name="selected" select="params/@joindir"/>
	      </xsl:apply-templates>
	    </td>
	    <td>JOIN</td>
	    <td>
	      <xsl:apply-templates select="metadata/tables" mode="dropdown">
		<xsl:with-param name="form_input_name" select="'join1'"/>
		<xsl:with-param name="selected" select="params/@join1"/>
	      </xsl:apply-templates>
	    </td>
	    <td>two</td>
	    <td>ON</td>
	    <td>
	      <xsl:apply-templates select="metadata/columns" mode="dropdown">
		<xsl:with-param name="form_input_name" select="'jc1'"/>
		  <xsl:with-param name="selected" select="params/@jc1"/>
		  <xsl:with-param name="filterby" select="params/@table"/>
		  <xsl:with-param name="table_alias" select="'one'"/>
	      </xsl:apply-templates>
	    </td>
	    <td>
	      <select name="joinop1" onchange="submit()">
		<option>=</option>
		<option>&lt;</option>
		<option>&lt;&gt;</option>
		<option>&gt;</option>
	      </select>
	    </td>
	    <td>
	      <xsl:apply-templates select="metadata/columns" mode="dropdown">
		<xsl:with-param name="form_input_name" select="'jc2'"/>
		<xsl:with-param name="selected" select="params/@jc2"/>
		<xsl:with-param name="filterby" select="params/@join1"/>
		<xsl:with-param name="table_alias" select="'two'"/>
	      </xsl:apply-templates>
	    </td>
	  </tr>
	</table>
      </div>
    </form>

    <div>
      <div class="pre">
	<xsl:value-of select="rows/@sql"/>
      </div>
	
      <xsl:apply-templates select="rows" mode="table"/>
    </div>
  </xsl:template>

  <xsl:template match="*" mode="dropdown">
    <xsl:param name="selected"/>
    <xsl:param name="filterby"/>
    <xsl:param name="form_input_name"/>
    <xsl:param name="table_alias"/>
    <select name="{$form_input_name}" onchange="submit()">
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

  <xsl:template match="column" mode="option">
    <xsl:param name="filterby"/>
    <xsl:param name="table_alias"/>
    <xsl:if test="@table_name = $filterby">
      <option><xsl:value-of select="$table_alias"/>.<xsl:value-of select="@name"/></option>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
  
